use MintableToken::{
    MintableToken, IMintableTokenDispatcher, IMintableTokenDispatcherTrait
};
use openzeppelin::access::ownable::interface::{
    IOwnableDispatcher, IOwnableDispatcherTrait
};


use openzeppelin::token::erc20::interface::{
    IERC20Dispatcher, IERC20DispatcherTrait,
    IERC20MetadataDispatcher, IERC20MetadataDispatcherTrait
};
use snforge_std::{
    ContractClassTrait, declare, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address, CheatTarget, spy_events, EventSpyAssertionsTrait
};
use starknet::ContractAddress;

const INITIAL_SUPPLY: u256 = 100000;

fn OWNER() -> ContractAddress {
    starknet::contract_address_const::<0x123>()
}

fn USER1() -> ContractAddress {
    starknet::contract_address_const::<0x456>()
}

fn __deploy__(initial_supply: u256) -> (IMintableTokenDispatcher, IOwnableDispatcher, IERC20Dispatcher, IERC20MetadataDispatcher) {
    let contract_class = declare("MintableToken").unwrap().contract_class();
    let mut calldata: Array<felt252> = array![];
    let low: felt252 = initial_supply.low.into();
    let high: felt252 = initial_supply.high.into();
    calldata.append(low);
    calldata.append(high);
    OWNER().serialize(ref calldata);
    let (contract_address, _) = contract_class.deploy(@calldata).unwrap();
    let token = IMintableTokenDispatcher { contract_address };
    let ownable = IOwnableDispatcher { contract_address };
    let erc20 = IERC20Dispatcher { contract_address };
    let erc20_metadata = IERC20MetadataDispatcher { contract_address };
    (token, ownable, erc20, erc20_metadata)
}

fn setup_token_holder(token: IMintableTokenDispatcher, erc20: IERC20Dispatcher, recipient: ContractAddress, amount: u256) {
    start_cheat_caller_address(token.contract_address, OWNER());
    erc20.transfer(recipient, amount);
    stop_cheat_caller_address(token.contract_address);
    assert(erc20.balance_of(recipient) == amount, 'Transfer failed');
    assert(erc20.balance_of(OWNER()) == INITIAL_SUPPLY - amount, 'Owner balance incorrect');
}

#[test]
fn test_mintable_token_deploy() {
    let (token, ownable, _, _) = __deploy__(INITIAL_SUPPLY);
    let total = token.get_total_minted();
    assert(total == INITIAL_SUPPLY, 'initial supply mismatch');
    let owner = ownable.owner();
    assert(owner == OWNER(), 'owner mismatch');
}

#[test]
fn test_token_metadata() {
    let (_, _, _, erc20_metadata) = __deploy__(INITIAL_SUPPLY);
    const EXPECTED_NAME: ByteArray = "MintableToken";
    const EXPECTED_SYMBOL: ByteArray = "MNT";
    const EXPECTED_DECIMALS: u8 = 18;
    assert(erc20_metadata.name() == EXPECTED_NAME, 'Name mismatch');
    assert(erc20_metadata.symbol() == EXPECTED_SYMBOL, 'Symbol mismatch');
    assert(erc20_metadata.decimals() == EXPECTED_DECIMALS, 'Decimals mismatch');
}

#[test]
fn test_owner_can_mint() {
    let (token, _, erc20, _) = __deploy__(INITIAL_SUPPLY);
    let prev_total_minted: u256 = token.get_total_minted();
    let recipient = OWNER();
    let mint_amount: u256 = 1000;
    start_cheat_caller_address(token.contract_address, OWNER());
    token.mint(recipient, mint_amount);
    stop_cheat_caller_address(token.contract_address);
    let latest_total_minted: u256 = token.get_total_minted();
    assert(prev_total_minted + mint_amount == latest_total_minted, 'Owner cannot mint');
    assert(erc20.balance_of(recipient) == INITIAL_SUPPLY + mint_amount, 'Balance mismatch');
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn non_owner_cannot_mint() {
    let (token, _, _, _) = __deploy__(INITIAL_SUPPLY);
    let recipient = OWNER();
    let mint_amount: u256 = 1000;
    start_cheat_caller_address(token.contract_address, USER1());
    token.mint(recipient, mint_amount);
    stop_cheat_caller_address(token.contract_address);
}

#[test]
#[should_panic(expected: ('ERC20: insufficient balance',))]
fn test_burn_insufficient_balance() {
    let (token, _, _, _) = __deploy__(INITIAL_SUPPLY);
    let burning_amount: u256 = 200;
    start_cheat_caller_address(token.contract_address, USER1());
    token.burn(burning_amount);
    stop_cheat_caller_address(token.contract_address);
}

#[test]
fn test_token_holder_can_burn() {
    let (token, _, erc20, _) = __deploy__(INITIAL_SUPPLY);
    let transfer_amount: u256 = 1300;
    let burning_amount: u256 = 200;
    setup_token_holder(token, erc20, USER1(), transfer_amount);
    let total_supply_before_burn: u256 = erc20.total_supply();
    start_cheat_caller_address(token.contract_address, USER1());
    token.burn(burning_amount);
    stop_cheat_caller_address(token.contract_address);
    let total_supply_after_burn: u256 = erc20.total_supply();
    assert(total_supply_after_burn == total_supply_before_burn - burning_amount, 'Issue in burning');
    assert(erc20.balance_of(OWNER()) == INITIAL_SUPPLY - transfer_amount, 'Owner balance changed');
    assert(erc20.balance_of(USER1()) == transfer_amount - burning_amount, 'User1 balance incorrect');
}

#[test]
#[should_panic(expected: ('Minting is paused',))]
fn test_only_owner_can_pause() {
    let (token, _, _, _) = __deploy__(INITIAL_SUPPLY);
    start_cheat_caller_address(token.contract_address, OWNER());
    token.pause();
    token.mint(OWNER(), 10);
    stop_cheat_caller_address(token.contract_address);
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn test_only_owner_can_unpause() {
    let (token, _, _, _) = __deploy__(INITIAL_SUPPLY);
    start_cheat_caller_address(token.contract_address, USER1());
    token.unpause();
    stop_cheat_caller_address(token.contract_address);
}

#[test]
fn test_unpausing_allows_minting_again() {
    let (token, _, _, _) = __deploy__(INITIAL_SUPPLY);
    start_cheat_caller_address(token.contract_address, OWNER());
    token.pause();
    token.unpause();
    token.mint(OWNER(), 10);
    stop_cheat_caller_address(token.contract_address);
}

#[test]
fn test_custom_mint_event_emitted() {
    let (token, _, _, _) = __deploy__(INITIAL_SUPPLY);
    let mut spy = spy_events();
    start_cheat_caller_address(token.contract_address, OWNER());
    token.mint(OWNER(), 10);
    stop_cheat_caller_address(token.contract_address);
    spy.assert_emitted(
        @array![(
            token.contract_address,
            MintableToken::Event::CustomMinted(MintableToken::CustomMinted { to: OWNER(), amount: 10 }),
        )]
    );
}