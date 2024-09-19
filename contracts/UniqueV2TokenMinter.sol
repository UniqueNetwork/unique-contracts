// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueNFT, CrossAddress, Property} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";

/**
 * @dev Struct to represent an attribute of a token.
 * @param trait_type Type of the attribute.
 * @param value Value of the attribute.
 */
struct Attribute {
    string trait_type;
    string value;
}

/**
 * @title UniqueV2TokenMinter
 * @dev Abstract contract for minting tokens in the Unique V2 Schema.
 */
abstract contract UniqueV2TokenMinter {
    /**
     * @dev Internal function to create a new token.
     * @param _collectionAddress Address of the collection to mint the token in.
     * @param _to CrossAddress to mint the token to.
     * @param _image URL of the token image.
     * @param _attributes Array of attributes for the token.
     */
    function _createToken(
        address _collectionAddress,
        string memory _image,
        Attribute[] memory _attributes,
        CrossAddress memory _to
    ) internal returns (uint256) {
        UniqueNFT nft = UniqueNFT(_collectionAddress);

        Property memory tokenData = Property({key: "tokenData", value: _buildTokenData(_attributes, _image)});

        Property[] memory properties = new Property[](3);
        properties[0] = Property({key: "schemaName", value: "unique"});
        properties[1] = Property({key: "schemaVersion", value: "2.0.0"});
        properties[2] = tokenData;

        return nft.mintCross(_to, properties);
    }

    /**
     * @dev Builds tokenData attribute JSON string from attributes and image.
     * @param _attributes Array of attributes for the token.
     * @param _image URL of the token image.
     * @return Token data JSON string in bytes.
     */
    function _buildTokenData(Attribute[] memory _attributes, string memory _image) private pure returns (bytes memory) {
        return
            abi.encodePacked(
                '{"schemaName":"unique","schemaVersion":"2.0.0","image":"',
                _image,
                '",',
                _buildAttributes(_attributes),
                "}"
            );
    }

    /**
     * @dev Builds attributes JSON string from array of attributes.
     * @param _attributes Array of attributes for the token.
     * @return Attributes JSON string.
     */
    function _buildAttributes(Attribute[] memory _attributes) private pure returns (bytes memory) {
        bytes memory attributesBytes = '"attributes":[';

        for (uint256 i = 0; i < _attributes.length; i++) {
            attributesBytes = abi.encodePacked(
                attributesBytes,
                '{"trait_type":"',
                _attributes[i].trait_type,
                '","value":"',
                _attributes[i].value,
                '"}'
            );
            if (i < _attributes.length - 1) {
                attributesBytes = abi.encodePacked(attributesBytes, ",");
            }
        }
        return abi.encodePacked(attributesBytes, "]");
    }
}
