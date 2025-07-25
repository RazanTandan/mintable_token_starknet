/**
 * This file is autogenerated by Scaffold-Stark.
 * You should not edit it manually or your changes might be overwritten.
 */

const deployedContracts = {
  devnet: {
    MintableToken: {
      address:
        "0x5a5b879e2ca46b6967223ba0bddbec378336cd9709b539c61d8578fe404d162",
      abi: [
        {
          type: "impl",
          name: "MintableTokenImpl",
          interface_name: "contracts::MintableToken::IMintableToken",
        },
        {
          type: "struct",
          name: "core::integer::u256",
          members: [
            {
              name: "low",
              type: "core::integer::u128",
            },
            {
              name: "high",
              type: "core::integer::u128",
            },
          ],
        },
        {
          type: "interface",
          name: "contracts::MintableToken::IMintableToken",
          items: [
            {
              type: "function",
              name: "mint",
              inputs: [
                {
                  name: "recipient",
                  type: "core::starknet::contract_address::ContractAddress",
                },
                {
                  name: "amount",
                  type: "core::integer::u256",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "burn",
              inputs: [
                {
                  name: "amount",
                  type: "core::integer::u256",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "get_total_minted",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "pause",
              inputs: [],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "unpause",
              inputs: [],
              outputs: [],
              state_mutability: "external",
            },
          ],
        },
        {
          type: "impl",
          name: "OwnableMixinImpl",
          interface_name: "openzeppelin_access::ownable::interface::OwnableABI",
        },
        {
          type: "interface",
          name: "openzeppelin_access::ownable::interface::OwnableABI",
          items: [
            {
              type: "function",
              name: "owner",
              inputs: [],
              outputs: [
                {
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "transfer_ownership",
              inputs: [
                {
                  name: "new_owner",
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "renounce_ownership",
              inputs: [],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "transferOwnership",
              inputs: [
                {
                  name: "newOwner",
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              outputs: [],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "renounceOwnership",
              inputs: [],
              outputs: [],
              state_mutability: "external",
            },
          ],
        },
        {
          type: "impl",
          name: "ERC20MixinImpl",
          interface_name: "openzeppelin_token::erc20::interface::IERC20Mixin",
        },
        {
          type: "enum",
          name: "core::bool",
          variants: [
            {
              name: "False",
              type: "()",
            },
            {
              name: "True",
              type: "()",
            },
          ],
        },
        {
          type: "struct",
          name: "core::byte_array::ByteArray",
          members: [
            {
              name: "data",
              type: "core::array::Array::<core::bytes_31::bytes31>",
            },
            {
              name: "pending_word",
              type: "core::felt252",
            },
            {
              name: "pending_word_len",
              type: "core::integer::u32",
            },
          ],
        },
        {
          type: "interface",
          name: "openzeppelin_token::erc20::interface::IERC20Mixin",
          items: [
            {
              type: "function",
              name: "total_supply",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "balance_of",
              inputs: [
                {
                  name: "account",
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "allowance",
              inputs: [
                {
                  name: "owner",
                  type: "core::starknet::contract_address::ContractAddress",
                },
                {
                  name: "spender",
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "transfer",
              inputs: [
                {
                  name: "recipient",
                  type: "core::starknet::contract_address::ContractAddress",
                },
                {
                  name: "amount",
                  type: "core::integer::u256",
                },
              ],
              outputs: [
                {
                  type: "core::bool",
                },
              ],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "transfer_from",
              inputs: [
                {
                  name: "sender",
                  type: "core::starknet::contract_address::ContractAddress",
                },
                {
                  name: "recipient",
                  type: "core::starknet::contract_address::ContractAddress",
                },
                {
                  name: "amount",
                  type: "core::integer::u256",
                },
              ],
              outputs: [
                {
                  type: "core::bool",
                },
              ],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "approve",
              inputs: [
                {
                  name: "spender",
                  type: "core::starknet::contract_address::ContractAddress",
                },
                {
                  name: "amount",
                  type: "core::integer::u256",
                },
              ],
              outputs: [
                {
                  type: "core::bool",
                },
              ],
              state_mutability: "external",
            },
            {
              type: "function",
              name: "name",
              inputs: [],
              outputs: [
                {
                  type: "core::byte_array::ByteArray",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "symbol",
              inputs: [],
              outputs: [
                {
                  type: "core::byte_array::ByteArray",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "decimals",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u8",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "totalSupply",
              inputs: [],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "balanceOf",
              inputs: [
                {
                  name: "account",
                  type: "core::starknet::contract_address::ContractAddress",
                },
              ],
              outputs: [
                {
                  type: "core::integer::u256",
                },
              ],
              state_mutability: "view",
            },
            {
              type: "function",
              name: "transferFrom",
              inputs: [
                {
                  name: "sender",
                  type: "core::starknet::contract_address::ContractAddress",
                },
                {
                  name: "recipient",
                  type: "core::starknet::contract_address::ContractAddress",
                },
                {
                  name: "amount",
                  type: "core::integer::u256",
                },
              ],
              outputs: [
                {
                  type: "core::bool",
                },
              ],
              state_mutability: "external",
            },
          ],
        },
        {
          type: "constructor",
          name: "constructor",
          inputs: [
            {
              name: "initial_supply",
              type: "core::integer::u256",
            },
            {
              name: "owner",
              type: "core::starknet::contract_address::ContractAddress",
            },
          ],
        },
        {
          type: "event",
          name: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferred",
          kind: "struct",
          members: [
            {
              name: "previous_owner",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "new_owner",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
          ],
        },
        {
          type: "event",
          name: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferStarted",
          kind: "struct",
          members: [
            {
              name: "previous_owner",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "new_owner",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
          ],
        },
        {
          type: "event",
          name: "openzeppelin_access::ownable::ownable::OwnableComponent::Event",
          kind: "enum",
          variants: [
            {
              name: "OwnershipTransferred",
              type: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferred",
              kind: "nested",
            },
            {
              name: "OwnershipTransferStarted",
              type: "openzeppelin_access::ownable::ownable::OwnableComponent::OwnershipTransferStarted",
              kind: "nested",
            },
          ],
        },
        {
          type: "event",
          name: "openzeppelin_token::erc20::erc20::ERC20Component::Transfer",
          kind: "struct",
          members: [
            {
              name: "from",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "to",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "value",
              type: "core::integer::u256",
              kind: "data",
            },
          ],
        },
        {
          type: "event",
          name: "openzeppelin_token::erc20::erc20::ERC20Component::Approval",
          kind: "struct",
          members: [
            {
              name: "owner",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "spender",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "value",
              type: "core::integer::u256",
              kind: "data",
            },
          ],
        },
        {
          type: "event",
          name: "openzeppelin_token::erc20::erc20::ERC20Component::Event",
          kind: "enum",
          variants: [
            {
              name: "Transfer",
              type: "openzeppelin_token::erc20::erc20::ERC20Component::Transfer",
              kind: "nested",
            },
            {
              name: "Approval",
              type: "openzeppelin_token::erc20::erc20::ERC20Component::Approval",
              kind: "nested",
            },
          ],
        },
        {
          type: "event",
          name: "contracts::MintableToken::MintableToken::CustomMinted",
          kind: "struct",
          members: [
            {
              name: "to",
              type: "core::starknet::contract_address::ContractAddress",
              kind: "key",
            },
            {
              name: "amount",
              type: "core::integer::u256",
              kind: "data",
            },
          ],
        },
        {
          type: "event",
          name: "contracts::MintableToken::MintableToken::Event",
          kind: "enum",
          variants: [
            {
              name: "OwnableEvent",
              type: "openzeppelin_access::ownable::ownable::OwnableComponent::Event",
              kind: "flat",
            },
            {
              name: "ERC20Event",
              type: "openzeppelin_token::erc20::erc20::ERC20Component::Event",
              kind: "flat",
            },
            {
              name: "CustomMinted",
              type: "contracts::MintableToken::MintableToken::CustomMinted",
              kind: "nested",
            },
          ],
        },
      ],
      classHash:
        "0x17f5000f414cb39d3012e7e922f8099c30b1daf2304a54edc3dd15bccc921cc",
    },
  },
} as const;

export default deployedContracts;
