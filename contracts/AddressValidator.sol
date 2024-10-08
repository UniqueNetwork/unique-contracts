// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <=0.8.24;

import "./libraries/AddressUtils.sol";

/**
 * @title AddressValidator
 * @dev Abstract contract providing address validation modifiers for token operations.
 */
abstract contract AddressValidator {
    using AddressUtils for *;

    /**
     * @notice Ensures that the caller is the owner of the specified token.
     * @dev Checks if `msg.sender` is the owner of the NFT with `_tokenId` in the collection at `collectionAddress`.
     * Reverts with an error message if the caller is not the owner.
     * @param _tokenId The ID of the token to validate ownership.
     * @param collectionAddress The address of the collection containing the token.
     */
    modifier onlyTokenOwner(uint256 _tokenId, address collectionAddress) {
        require(
            AddressUtils.messageSenderIsTokenOwner(collectionAddress, _tokenId),
            "AddressValidator: msg.sender is not the token owner"
        );
        _;
    }

    /**
     * @notice Ensures that the caller matches the provided CrossAddress address.
     * @dev Validates that `msg.sender` corresponds to the `_crossAddress`.
     * Reverts with an error message if the caller does not match.
     * @param _crossAddress The `CrossAddress` struct representing the expected caller's address.
     */
    modifier onlyMessageSender(CrossAddress memory _crossAddress) {
        require(_crossAddress.isMessageSender(), "AddressValidator: msg.sender is not the owner");
        _;
    }
}
