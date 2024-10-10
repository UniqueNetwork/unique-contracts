// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <=0.8.24;

import {CollectionHelpers} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import {ContractHelpers} from "@unique-nft/solidity-interfaces/contracts/ContractHelpers.sol";

/**
 * @title UniquePrecompiles
 * @dev Abstract contract to provide access to Unique Network precompiled contracts.
 */
abstract contract UniquePrecompiles {
    CollectionHelpers internal constant COLLECTION_HELPERS =
        CollectionHelpers(0x6C4E9fE1AE37a41E93CEE429e8E1881aBdcbb54F);

    ContractHelpers internal constant CONTRACT_HELPERS = ContractHelpers(0x842899ECF380553E8a4de75bF534cdf6fBF64049);
}
