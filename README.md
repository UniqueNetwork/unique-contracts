# Unique Network | Contracts

## Overview

This repository contains example smart contracts for minting collections and tokens in the [Unique Schema V2](https://docs.uniquenetwork.dev/reference/schemas) using Solidity.

## Install

With Foundry

```sh
forge install UniqueNetwork/unique-contracts
```

When working with Hardhat projects, you'll need to copy the entire contracts directory and manually install `@unique-nft/solidity-interfaces`. This process is going to be refined shortly.

## Contract Description

### Contracts

- [`UniqueV2CollectionMinter.sol`](./contracts/UniqueV2CollectionMinter.sol): provides functionality to create collections in the Unique Schema V2.
- [`UniqueV2TokenMinter.sol`](./contracts/UniqueV2TokenMinter.sol): provides functionality to create tokens in the Unique Schema V2.

### Example Usage

- [`Minter.sol`](./contracts/recipes/Minter.sol): Demonstrates how to create a gasless experience for minting collections and NFTs.
- [`POAP.sol`](./contracts/recipes/POAP.sol): Demonstrates how to create a POAP contract. Tokens minting sponsored by the POAP contract itself. Every account can mint only one NFT and cannot transfer it.

## Run tests

1. Install packages and compile contracts

```bash
yarn
npx hardhat compile
```

2. Create `.env` file from `.env.example`
3. Set at least two private keys with `OPL` balance to `TEST_ACCOUNTS_ETH` env. You can get `OPL` tokens for free https://t.me/unique2faucet_opal_bot

4. Run tests

```bash
yarn test
```
