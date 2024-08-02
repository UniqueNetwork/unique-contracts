// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {UniqueNFT} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
import {UniqueV2CollectionMinter, CollectionMode, TokenPropertyPermission} from "../UniqueV2CollectionMinter.sol";
import {UniqueV2TokenMinter, Attribute, CrossAddress} from "../UniqueV2TokenMinter.sol";

contract Minter is UniqueV2CollectionMinter, UniqueV2TokenMinter {
    event CollectionCreated(address collectionAddress, uint256 collectionId);

    constructor() payable UniqueV2CollectionMinter(true, false, true) {}

    receive() external payable {}

    function mintCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover
    ) external payable {
        address collectionAddress = _createCollection(
            _name,
            _description,
            _symbol,
            _collectionCover,
            new TokenPropertyPermission[](0)
        );

        emit CollectionCreated(
            collectionAddress,
            COLLECTION_HELPERS.collectionId(collectionAddress)
        );
    }

    function mintToken(
        uint32 _collectionId,
        string memory _image,
        Attribute[] memory _attributes
    ) external {
        address collectionAddress = COLLECTION_HELPERS.collectionAddress(
            _collectionId
        );
        _createToken(
            collectionAddress,
            CrossAddress({eth: msg.sender, sub: 0}),
            _image,
            _attributes
        );
    }
}
