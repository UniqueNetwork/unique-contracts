# Unique Network | Contracts

## Overview

This repository contains example smart contracts for minting collections and tokens using Solidity in the [Unique Schema V2](https://docs.uniquenetwork.dev/reference/schemas).

## Install

```sh
npm install @unique-nft/contracts
```

## Structs

### Attribute

Represents an attribute of a token.

| Parameter  | Type     | Description             |
| ---------- | -------- | ----------------------- |
| trait_type | `string` | Type of the attribute.  |
| value      | `string` | Value of the attribute. |

### CrossAddress

Represents ethereum or substrate account. Only one property can be filled out to consider the structure valid. Learn more about EVM in Unique Network and compatibility with substrate accounts in the [official documentation](https://docs.unique.network/build/evm/).

The `AddressUtils` library provides helper methods to work with the `CrossAddress` struct.

| Parameter | Type      | Description                                                         |
| --------- | --------- | ------------------------------------------------------------------- |
| eth       | `address` | Ethereum address or `address(0)` if the origin is substrate account |
| sub       | `uin256`  | Substrate public key or `0` if the caller is ethereum account       |

## Contracts

### [`UniqueV2CollectionMinter.sol`](https://github.com/UniqueNetwork/unique-contracts/blob/main/contracts/UniqueV2CollectionMinter.sol)

`import "@unique-nft/contracts/UniqueV2CollectionMinter";`

Provides functions to create collections in the Unique Schema V2.

| Function                                                                                        |                                                                                                                   |
| ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `constructor(bool _mutable, bool _admin, bool _tokenOwner)`                                     | Initializes the contract and sets the default permissions for token properties mutation                           |
| `_createCollection(string _name, string _description, string _symbol, string _collectionCover)` | Creates a collection with specified name, description, symbol, collection cover, and allowed nesting permissions. |

### [`UniqueV2TokenMinter.sol`](https://github.com/UniqueNetwork/unique-contracts/blob/main/contracts/UniqueV2TokenMinter.sol)

`import "@unique-nft/contracts/UniqueV2TokenMinter";`

Provides functions to create tokens in the Unique Schema V2.

| Function                                                                                                                          |                                                                                                    |
| --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `_createToken(address _collectionAddress, string _image, Attribute[] _attributes, CrossAddress _to) internal returns (uint256)  ` | Internal function to create a new token with specified image and attributes in a given collection. |

## Example Usage

- [`Minter.sol`](https://github.com/UniqueNetwork/unique-contracts/blob/main/contracts/recipes/Minter.sol): Demonstrates how to create a gasless experience for minting collections and NFTs.
- [`POAP.sol`](https://github.com/UniqueNetwork/unique-contracts/blob/main/contracts/recipes/POAP.sol): Demonstrates how to create a POAP contract. Tokens minting sponsored by the POAP contract itself. Every account can mint only one NFT that cannot be transferred.
- [`BreedingGame.sol`](https://github.com/UniqueNetwork/unique-contracts/blob/main/contracts/recipes/BreedingGame.sol): Demonstrates how contracts can mutate token's attributes and image.

## Run tests

1. Install packages and compile contracts

```bash
yarn
yarn compile
```

2. Create `.env` file from `.env.example`
3. Set at least two private keys with `OPL` balance to `TEST_ACCOUNTS_ETH` env. You can get `OPL` tokens for free at https://t.me/unique2faucet_opal_bot

4. Run tests

```bash
yarn test
```
