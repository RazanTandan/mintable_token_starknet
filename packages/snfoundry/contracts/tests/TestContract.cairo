use contracts::MintableToken::{
    MintableToken,IMintableTokenDispatcher, IMintableTokenDispatcherTrait
};

use openzeppelin_access::ownable::interface::{
    IOwnableDispatcher, IOwnableDispatcherTrait, 
};

use openzeppelin_token::erc20::interface::{
    IERC20Dispatcher, IERC20DispatcherTrait,IERC20MetadataDispatcher, IERC20MetadataDispatcherTrait,
};

use snforge_std::{
    ContractClassTrait, declare, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address, EventSpyAssertionsTrait, spy_events,
};

use starknet::ContractAddress;

const INITIAL_SUPPLY: u256 = 100000;

fn OWNER() -> ContractAddress {
    'OWNER'.try_into().unwrap()
}

fn USER1() -> ContractAddress {
    'USER1'.try_into().unwrap()
}


fn __deploy__(initial_supply: u256) -> (IMintableTokenDispatcher, IOwnableDispatcher, IERC20Dispatcher) {
    let contract_class = declare("MintableToken").unwrap().contract_class();

    let mut calldata: Array<felt252> = array![];

    // For u256, you need to add its low and high parts separately
    // The U256 type itself has `low` and `high` fields
    let low: felt252 = initial_supply.low.into();
    let high: felt252 = initial_supply.high.into();

    calldata.append(low);
    calldata.append(high);
    
    // For ContractAddress, it's just one felt252
    OWNER().serialize(ref calldata); // This is fine, as ContractAddress serializes to one felt252

    let (contract_address, _) = contract_class.deploy(@calldata).unwrap();

    let token = IMintableTokenDispatcher { contract_address };
    let ownable = IOwnableDispatcher { contract_address };
    let erc20 = IERC20Dispatcher {contract_address};


    (token, ownable, erc20)
}

#[test]
fn test_mintable_token_deploy() {
    let (token, ownable, _) = __deploy__(INITIAL_SUPPLY);

    let total = token.get_total_minted();
    assert(total == INITIAL_SUPPLY, 'initial supply mismatch');

    println!("I am runnning");
    let owner = ownable.owner();
    assert(owner == OWNER(), 'owner mismatch');
}

#[test]
fn test_token_metadata() {
    let (token, _, _) = __deploy__(INITIAL_SUPPLY); 

    // needed erc20 metadata interface because name(), symbol(), decimals() are there
    let erc20_metadata = IERC20MetadataDispatcher { contract_address: token.contract_address };
    
    let expected_name: ByteArray = "MintableToken";
    let expected_symbol: ByteArray = "MNT";
    let expected_decimals: u8 = 18;

    assert(erc20_metadata.name() == expected_name, 'Name mismatch');
    assert(erc20_metadata.symbol() == expected_symbol, 'Symbol mismatch');
    assert(erc20_metadata.decimals() == expected_decimals, 'Decimals mismatch');
}

#[test]
fn test_owner_can_mint() { 
    let (token, _, _) = __deploy__(INITIAL_SUPPLY); 

    let prev_total_minted:u256 = token.get_total_minted(); 
    let recipient = OWNER();
    let mint_amount: u256 = 1000;  

    start_cheat_caller_address(token.contract_address, OWNER());
    token.mint(recipient, mint_amount);
    stop_cheat_caller_address(token.contract_address);

    let latest_total_minted: u256 = token.get_total_minted(); 
    assert(prev_total_minted + mint_amount == latest_total_minted, 'Owner cannot mint'); 
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn non_owner_cannot_mint() { 
    let (token, _, _) = __deploy__(INITIAL_SUPPLY); 

    let recipient = OWNER();
    let mint_amount: u256 = 1000;  

    start_cheat_caller_address(token.contract_address, USER1());
    token.mint(recipient, mint_amount);
    stop_cheat_caller_address(token.contract_address);
}


#[test]
#[should_panic(expected: 'ERC20: insufficient balance')]
fn test_burn_insufficient_balance() { 
    let (token, _, _) = __deploy__(INITIAL_SUPPLY);
    let burning_amount: u256 = 200; 

    start_cheat_caller_address(token.contract_address, USER1());
    token.burn(burning_amount); // USER1 has 0 tokens
    stop_cheat_caller_address(token.contract_address);
}


fn setup_token_holder(token: IMintableTokenDispatcher, erc20: IERC20Dispatcher, recipient: ContractAddress, amount: u256) {
    start_cheat_caller_address(token.contract_address, OWNER());
    erc20.transfer(recipient, amount);
    stop_cheat_caller_address(token.contract_address);
    assert(erc20.balance_of(recipient) == amount, 'Transfer failed');
    assert(erc20.balance_of(OWNER()) == INITIAL_SUPPLY - amount, 'Owner balance incorrect');
}

#[test]
fn test_token_holder_can_burn() { 
    let (token, _, erc20 ) = __deploy__(INITIAL_SUPPLY);
    let transfer_amount: u256 = 1300; 
    let burning_amount: u256 = 200; 

    // setting up USER1 as token holder
    setup_token_holder(token, erc20, USER1(), transfer_amount);

    let total_supply_before_burning: u256 = erc20.total_supply();

    start_cheat_caller_address(token.contract_address, USER1());
    token.burn(burning_amount);
    stop_cheat_caller_address(token.contract_address); 

    let total_supply_after_burning: u256 = erc20.total_supply();

    //Verifying total supply
    assert(total_supply_after_burning == total_supply_before_burning - burning_amount, 'Issue in burning');
    
    //Verifying balance of owner
    assert(erc20.balance_of(OWNER()) == INITIAL_SUPPLY - transfer_amount, 'Owner balance changed');

    //Verifying User1 balance after burning
    assert(erc20.balance_of(USER1()) == transfer_amount - burning_amount, 'User1 balance incorrect');
}

#[test]
#[should_panic(expected: "Minting is paused")]
fn test_only_owner_can_pause(){
    let (token, _, _ ) = __deploy__(INITIAL_SUPPLY);

    start_cheat_caller_address(token.contract_address, OWNER());
    token.pause();
    token.mint(OWNER(), 10);
    stop_cheat_caller_address(token.contract_address);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn test_only_owner_can_unpause(){ 
    let (token, _, _) = __deploy__(INITIAL_SUPPLY);

    start_cheat_caller_address(token.contract_address, USER1());
    token.pause();
    stop_cheat_caller_address(token.contract_address);
}

#[test]
fn test_unpausing_allows_minting_again() {
    let (token, _, _) = __deploy__(INITIAL_SUPPLY);

    start_cheat_caller_address(token.contract_address, OWNER());
    token.pause();
    token.unpause(); 
    token.mint(OWNER(), 10);
    stop_cheat_caller_address(token.contract_address);
}

#[test]
fn test_custom_mint_event_emitted() { 
    let (token, _, _) = __deploy__(INITIAL_SUPPLY);
    let mut spy = spy_events(); 

    // mock a caller
    start_cheat_caller_address(token.contract_address, OWNER());
    token.mint(OWNER(), 10);
    stop_cheat_caller_address(token.contract_address);

    spy
        .assert_emitted(
            @array![
                (
                    token.contract_address,
                    MintableToken::Event::CustomMinted(MintableToken::CustomMinted { to: OWNER(), amount: 10}),
                ),
            ],
        );
}