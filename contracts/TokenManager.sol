// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <=0.8.24;

import {UniqueNFT, Property} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
import "./libraries/TokenDataUtils.sol";

/**
 * @title TokenManager
 * @dev Abstract contract providing utility functions to manage token data such as images and traits.
 */
abstract contract TokenManager {
    using TokenDataUtils for bytes;

    /**
     * @notice Sets a new image for a specific token in a collection.
     * @dev Updates the 'tokenData' property of the token with the new image.
     * @param _collection The address of the collection contract.
     * @param _tokenId The ID of the token to update.
     * @param _newImage The new image data to set for the token.
     */
    function _setImage(address _collection, uint256 _tokenId, bytes memory _newImage) internal {
        bytes memory tokenData = UniqueNFT(_collection).property(_tokenId, "tokenData");
        bytes memory newTokenData = tokenData.setTokenImage(_newImage);

        _setTokenData(_collection, _tokenId, newTokenData);
    }

    /**
     * @notice Sets a new trait for a specific token in a collection.
     * @dev Updates the 'tokenData' property of the token with the new trait.
     * @param _collection The address of the collection contract.
     * @param _tokenId The ID of the token to update.
     * @param _traitType The type of the trait to set.
     * @param _traitValue The value of the trait to set.
     */
    function _setTrait(
        address _collection,
        uint256 _tokenId,
        bytes memory _traitType,
        bytes memory _traitValue
    ) internal {
        bytes memory tokenData = UniqueNFT(_collection).property(_tokenId, "tokenData");
        bytes memory newTokenData = tokenData.setTrait(_traitType, _traitValue);

        _setTokenData(_collection, _tokenId, newTokenData);
    }

    /**
     * @notice Retrieves the image data of a specific token in a collection.
     * @param _collection The address of the collection contract.
     * @param _tokenId The ID of the token to query.
     * @return The image data of the token.
     */
    function _getImage(address _collection, uint256 _tokenId) internal view returns (bytes memory) {
        bytes memory tokenData = UniqueNFT(_collection).property(_tokenId, "tokenData");
        return tokenData.getImage();
    }

    /**
     * @notice Retrieves the value of a specific trait for a token in a collection.
     * @param _collection The address of the collection contract.
     * @param _tokenId The ID of the token to query.
     * @param _traitType The type of the trait to retrieve.
     * @return The value of the specified trait.
     */
    function _getTraitValue(
        address _collection,
        uint256 _tokenId,
        bytes memory _traitType
    ) internal view returns (bytes memory) {
        bytes memory tokenData = UniqueNFT(_collection).property(_tokenId, "tokenData");
        return tokenData.getTraitValue(_traitType);
    }

    /**
     * @dev function to update the 'tokenData' property of a token.
     * @param _collection The address of the collection contract.
     * @param _tokenId The ID of the token to update.
     * @param _newTokenData The new token data to set.
     */
    function _setTokenData(address _collection, uint256 _tokenId, bytes memory _newTokenData) private {
        Property[] memory updatedProperty = new Property[](1);
        updatedProperty[0] = Property("tokenData", _newTokenData);
        UniqueNFT(_collection).setProperties(_tokenId, updatedProperty);
    }
}
