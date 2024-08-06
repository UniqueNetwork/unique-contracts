// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueNFT} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
import {Property, CollectionMode, TokenPropertyPermission, CollectionLimitValue, CollectionLimitField} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import {UniqueV2CollectionMinter} from "../UniqueV2CollectionMinter.sol";
import {UniqueV2TokenMinter, Attribute, CrossAddress} from "../UniqueV2TokenMinter.sol";

struct EventConfig {
    uint256 startTimestamp;
    uint256 endTimestamp;
    string tokenImage;
    Attribute[] attributes;
}

contract POAP is UniqueV2CollectionMinter, UniqueV2TokenMinter {
    uint256 public constant ACCOUNT_TOKEN_LIMIT = 1;

    uint256 private s_collectionCreationFee;
    mapping(address collection => EventConfig) s_collectionEvent;

    event CollectionCreated(uint256 collectionId, address collectionAddress);
    event TokenCreated(
        CrossAddress indexed owner,
        uint256 indexed colletionId,
        uint256 tokenId
    );

    error Poap__IncorrectFee();
    error Poap__EventNotStarted();
    error Poap__EventFinished();

    constructor(
        uint256 _collectionCreationFee
    ) UniqueV2CollectionMinter(true, false, true) payable {
        s_collectionCreationFee = _collectionCreationFee;
    }

    receive() external payable {}

    function createCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover,
        EventConfig memory _eventConfig
    ) external payable {
        if (msg.value != s_collectionCreationFee) revert Poap__IncorrectFee();

        // Every account can own only 1 NFT (ACCOUNT_TOKEN_LIMIT)
        CollectionLimitValue[]
            memory collectionLimits = new CollectionLimitValue[](2);
        collectionLimits[0] = CollectionLimitValue({
            field: CollectionLimitField.AccountTokenOwnership,
            value: ACCOUNT_TOKEN_LIMIT
        });

        // Transfers are not allowed
        collectionLimits[1] = CollectionLimitValue({
            field: CollectionLimitField.TransferEnabled,
            value: 0
        });

        // Create a collection
        address collectionAddress = _createCollection(
            _name,
            _description,
            _symbol,
            _collectionCover,
            collectionLimits,
            new Property[](0),
            new TokenPropertyPermission[](0)
        );

        UniqueNFT collection = UniqueNFT(collectionAddress);

        // Set collection sponsorship
        // every transaction with be paid by POAP-contract address
        collection.setCollectionSponsorCross(
            CrossAddress({eth: address(this), sub: 0})
        );
        // ...confirm collection sponsorship
        collection.confirmCollectionSponsorship();

        s_collectionEvent[collectionAddress].startTimestamp = _eventConfig
            .startTimestamp;
        s_collectionEvent[collectionAddress].endTimestamp = _eventConfig
            .endTimestamp;
        s_collectionEvent[collectionAddress].tokenImage = _eventConfig
            .tokenImage;

        for (uint i = 0; i < _eventConfig.attributes.length; i++) {
            s_collectionEvent[collectionAddress].attributes.push(
                _eventConfig.attributes[i]
            );
        }

        emit CollectionCreated(
            COLLECTION_HELPERS.collectionId(collectionAddress),
            collectionAddress
        );
    }

    function createToken(
        address _collectionAddress,
        CrossAddress memory _owner
    ) external {
        EventConfig memory collectionEvent = s_collectionEvent[
            _collectionAddress
        ];
        if (block.timestamp < collectionEvent.startTimestamp)
            revert Poap__EventNotStarted();
        if (block.timestamp > collectionEvent.endTimestamp)
            revert Poap__EventFinished();

        uint256 tokenId = _createToken(
            _collectionAddress,
            collectionEvent.tokenImage,
            collectionEvent.attributes,
            _owner
        );
        emit TokenCreated(
            _owner,
            COLLECTION_HELPERS.collectionId(_collectionAddress),
            tokenId
        );
    }

    function timestampNow() external view returns (uint256) {
        return block.timestamp;
    }
}
