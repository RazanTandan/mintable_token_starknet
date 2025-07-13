use starknet::ContractAddress; 

#[starknet::interface]
pub trait IMintableToken<TContractState> {
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn burn(ref self: TContractState, amount: u256);
    fn get_total_minted(self: @TContractState) -> u256;
    fn pause(ref self: TContractState);
    fn unpause(ref self: TContractState);
}

#[starknet::contract]
pub mod MintableToken {
    use super::IMintableToken; 
    use starknet::ContractAddress; 

    use openzeppelin_access::ownable::OwnableComponent;
    use openzeppelin_token::erc20::{DefaultConfig, ERC20Component, ERC20HooksEmptyImpl};
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>; // for access of internal funcs
    
    // ERC20 Mixin
    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage{ 
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        total_minted: u256,
        paused: bool, 
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event { 
        #[flat]
        OwnableEvent: OwnableComponent::Event, 
        #[flat]
        ERC20Event: ERC20Component::Event,
        CustomMinted: CustomMinted,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CustomMinted {
        #[key]
        pub to: ContractAddress, 
        pub amount: u256,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_supply: u256, owner: ContractAddress){ 
        let name: ByteArray = "MintableToken";
        let symbol: ByteArray = "MNT"; 

        self.erc20.initializer(name, symbol); 
        self.ownable.initializer(owner);
        self.erc20.mint(owner, initial_supply);
        self.total_minted.write(initial_supply);
        self.paused.write(false);
    }

    #[abi(embed_v0)]
    impl MintableTokenImpl of IMintableToken<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) { 
            // Only Owner can mint new tokens
            self.ownable.assert_only_owner(); 
            assert!(!self.paused.read(), "Minting is paused");
            self.erc20.mint(recipient, amount);
            self.total_minted.write(self.total_minted.read() + amount);
            self.emit(CustomMinted { to: recipient, amount});
        }
    
        fn burn(ref self: ContractState, amount: u256) { 
            // Any token holder can burn their own tokens
            let caller = starknet::get_caller_address(); 
            self.erc20.burn(caller, amount); 
        }

        fn get_total_minted(self: @ContractState) -> u256 { 
            self.total_minted.read()
        }

    
        fn pause(ref self: ContractState) { 
            self.ownable.assert_only_owner(); 
            self.paused.write(true);
        }

        fn unpause(ref self: ContractState) { 
            self.ownable.assert_only_owner(); 
            self.paused.write(false);
        }
    }
}
