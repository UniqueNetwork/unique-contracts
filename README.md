# Unique Network | Contracts

[![npm version](https://img.shields.io/npm/v/@unique-nft/contracts.svg)](https://www.npmjs.com/package/@unique-nft/contracts)

This repository contains smart contracts for minting collections and tokens using Solidity in the [Unique Schema V2](https://docs.uniquenetwork.dev/reference/schemas).

- [Unique Network | Contracts](#unique-network--contracts)
  - [Installation and configuration](#installation-and-configuration)
  - [API](#api)
    - [Structs](#structs)
      - [Attribute](#attribute)
      - [CrossAddress](#crossaddress)
    - [Contracts](#contracts)
      - [`CollectionMinter.sol`](#collectionmintersol)
      - [`TokenMinter.sol`](#tokenmintersol)
      - [`TokenManager.sol`](#tokenmanagersol)
      - [`AddressValidator.sol`](#addressvalidatorsol)
  - [Example Usage](#example-usage)
  - [Run tests](#run-tests)

## Installation and configuration

Install packages:

```sh
npm install @unique-nft/contracts
```

Find the RPC endpoint in the [official documentation](https://docs.unique.network/reference). You can get `OPL` (Opal testnet) tokens for free at https://t.me/unique2faucet_opal_bot

> [!IMPORTANT]
> Configure your project:
>
> 1. Compatible Solidity versions are `>=0.8.18 <=0.8.24`
> 2. Use via-IR compilation pipeline.
>
> In hardhat.config file set:
>
> ```ts
>   solidity: {
>     version: "0.8.24",
>     settings: { viaIR: true },
>  },
> ```

## API

### Structs

#### Attribute

Represents an attribute of a token.

| Parameter  | Type     | Description             |
| ---------- | -------- | ----------------------- |
| trait_type | `string` | Type of the attribute.  |
| value      | `string` | Value of the attribute. |

#### CrossAddress

Represents ethereum or substrate account. Only one property can be filled out to consider the structure valid. Learn more about EVM in Unique Network and compatibility with substrate accounts in the [official documentation](https://docs.unique.network/build/evm/).

The `AddressUtils` library provides helper methods to work with the `CrossAddress` struct.

| Parameter | Type      | Description                                                         |
| --------- | --------- | ------------------------------------------------------------------- |
| eth       | `address` | Ethereum address or `address(0)` if the origin is substrate account |
| sub       | `uin256`  | Substrate public key or `0` if the caller is ethereum account       |

### Contracts

#### [`CollectionMinter.sol`](https://github.com/UniqueNetwork/unique-contracts/blob/main/contracts/CollectionMinter.sol)

`import "@unique-nft/contracts/CollectionMinter.sol";`

Provides functions to create collections in the Unique Schema V2.

---

`constructor(bool _mutable, bool _admin, bool _tokenOwner)`

Initializes the contract and sets the default permissions for token properties mutation

---

`_createCollection(string _name, string _description, string _symbol, string _collectionCover)`

Creates a collection with specified name, description, symbol, collection cover, and allowed nesting permissions.

---

#### [`TokenMinter.sol`](https://github.com/UniqueNetwork/unique-contracts/blob/main/contracts/TokenMinter.sol)

`import "@unique-nft/contracts/TokenMinter.sol";`

Provides functions to create tokens in the Unique Schema V2.

---

`_createToken(address _collectionAddress, string _image, Attribute[] _attributes, CrossAddress _to) internal returns (uint256)`

Internal function to create a new token with specified image and attributes in a given collection.

---

#### [`TokenManager.sol`](https://github.com/UniqueNetwork/unique-contracts/blob/main/contracts/TokenManager.sol)

`import "@unique-nft/contracts/TokenManager.sol";`

Provides utility functions for managing token data, such as setting and retrieving images and traits for tokens within a collection.

---

`_setImage(address _collection, uint256 _tokenId, bytes memory _newImage) internal`

Sets a new image for a specific token in a collection.

---

`_setTrait(address _collection, uint256 _tokenId, bytes memory _traitType, bytes memory _traitValue) internal`

Sets a new trait (attribute) for a specific token in a collection.

---

`_getImage(address _collection, uint256 _tokenId) internal view returns (bytes memory)`

Retrieves the image data of a specific token in a collection.

---

`_getTraitValue(address _collection, uint256 _tokenId, bytes memory _traitType) internal view returns (bytes memory)`

Retrieves the value of a specific trait for a token in a collection.

---

#### [`AddressValidator.sol`](https://github.com/UniqueNetwork/unique-contracts/blob/main/contracts/AddressValidator.sol)

`import "@unique-nft/contracts/AddressValidator.sol";`

Provides modifiers for validating addresses in token-related operations, ensuring that the caller is authorized.

---

`onlyTokenOwner(uint256 _tokenId, address collectionAddress`

Restricts access to the owner of the token with ID `_tokenId` in the collection at `collectionAddress`. Reverts if `msg.sender` is not the token owner.

---

`onlyMessageSender(CrossAddress memory _crossAddress)`

Restricts access to the address represented by `_crossAddress`. Reverts if `_crossAddress` does not match `msg.sender`.

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
