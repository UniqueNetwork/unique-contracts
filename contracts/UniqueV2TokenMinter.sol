// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {UniqueNFT, CrossAddress, Property} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";

struct Attribute {
    string trait_type;
    string value;
}

abstract contract UniqueV2TokenMinter {
    function _createToken(
        address _collectionAddress,
        CrossAddress memory _to,
        string memory _image,
        Attribute[] memory _attributes
    ) internal {
        UniqueNFT nft = UniqueNFT(_collectionAddress);

        Property memory tokenData = Property({
            key: "tokenData",
            value: _tokenDataBuilder(_attributes, _image)
        });

        Property[] memory properties = new Property[](3);
        properties[0] = Property({key: "schemaName", value: "unique"});
        properties[1] = Property({key: "schemaVersion", value: "2.0.0"});
        properties[2] = tokenData;

        nft.mintCross(_to, properties);
    }

    function _tokenDataBuilder(
        Attribute[] memory _attributes,
        string memory _image
    ) private pure returns (bytes memory) {
        string
            memory tokenData1 = '{"schemaName":"unique","schemaVersion":"2.0.0","image":"';
        string memory tokenData2 = string.concat(
            '",',
            _attributesBuilder(_attributes)
        );

        return bytes(string.concat(tokenData1, _image, tokenData2));
    }

    function _attributesBuilder(
        Attribute[] memory _attributes
    ) private pure returns (string memory) {
        string memory attributesString = '"attributes":[';
        for (uint i = 0; i < _attributes.length; i++) {
            attributesString = string.concat(
                attributesString,
                '{"trait_type":"',
                _attributes[i].trait_type,
                '","value":"',
                _attributes[i].value,
                '"}'
            );
            if (i < _attributes.length - 1) {
                attributesString = string.concat(attributesString, ",");
            }
        }
        attributesString = string.concat(attributesString, "]");
        return attributesString;
    }

    function _traitBuilder(
        Attribute memory _attribute
    ) private pure returns (string memory) {
        return
            string.concat(
                '{"trait_type":"',
                _attribute.trait_type,
                '","value":"',
                _attribute.value
            );
    }
}
