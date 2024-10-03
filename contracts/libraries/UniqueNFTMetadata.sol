// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <=0.8.24;

import {UniqueNFT, Property} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
import "./utils/TokenDataUtils.sol";

library UniqueNFTMetadata {
    using TokenDataUtils for bytes;

    function setImage(address _collection, uint256 _tokenId, bytes memory _newImage) internal {
        bytes memory tokenData = UniqueNFT(_collection).property(_tokenId, "tokenData");
        bytes memory newTokenData = tokenData.setTokenImage(_newImage);

        _setTokenData(_collection, _tokenId, newTokenData);
    }

    function setTrait(
        address _collection,
        uint256 _tokenId,
        bytes memory _traitType,
        bytes memory _traitValue
    ) internal {
        bytes memory tokenData = UniqueNFT(_collection).property(_tokenId, "tokenData");
        bytes memory newTokenData = tokenData.setTrait(_traitType, _traitValue);

        _setTokenData(_collection, _tokenId, newTokenData);
    }

    function getImage(address _collection, uint256 _tokenId) internal view returns (bytes memory) {
        bytes memory tokenData = UniqueNFT(_collection).property(_tokenId, "tokenData");
        return tokenData.getImage();
    }

    function getTraitValue(
        address _collection,
        uint256 _tokenId,
        bytes memory _traitType
    ) internal view returns (bytes memory) {
        bytes memory tokenData = UniqueNFT(_collection).property(_tokenId, "tokenData");
        return tokenData.getTraitValue(_traitType);
    }

    function _setTokenData(address _collection, uint256 _tokenId, bytes memory _newTokenData) internal {
        Property[] memory updatedProperty = new Property[](1);
        updatedProperty[0] = Property("tokenData", _newTokenData);
        UniqueNFT(_collection).setProperties(_tokenId, updatedProperty);
    }
}
