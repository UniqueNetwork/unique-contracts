// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueNFT} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
import {Property, CollectionMode, TokenPropertyPermission, CollectionLimitValue, CollectionLimitField} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import {UniqueV2CollectionMinter} from "../UniqueV2CollectionMinter.sol";
import {UniqueV2TokenMinter, Attribute, CrossAddress} from "../UniqueV2TokenMinter.sol";

struct EventToken {
    string image;
    Attribute[] attributes;
}

struct EventDuration {
    uint256 startTimestamp;
    uint256 endTimestamp;
}

contract POAP is UniqueV2CollectionMinter, UniqueV2TokenMinter {
    uint256 public constant ACCOUNT_TOKEN_LIMIT = 1;
    uint256 private s_collectionCreationFee;

    mapping(address collection => CrossAddress owner)
        private s_collectionOwnerOf;

    mapping(address collection => EventDuration) s_collectionEvent;

    event CollectionCreated(uint256 collectionId, address collectionAddress);
    event TokenCreated(
        CrossAddress indexed owner,
        uint256 colletionId,
        uint256 tokenId
    );

    error Poap__IncorrectFee();
    error Poap__EventNotStarted();
    error Poap__EventFinished();

    constructor(
        uint256 _collectionCreationFee
    ) UniqueV2CollectionMinter(true, false, true) {
        s_collectionCreationFee = _collectionCreationFee;
    }

    receive() external payable {}

    function createCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover,
        uint256 _startEventTimestamp,
        uint256 _endEventTimestamp,
        CrossAddress memory _owner
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

        // Set collection sponsorship to the contract address
        collection.setCollectionSponsorCross(
            CrossAddress({eth: address(this), sub: 0})
        );
        // Confirm the collection sponsorship
        collection.confirmCollectionSponsorship();

        s_collectionOwnerOf[collectionAddress] = _owner;
        s_collectionEvent[collectionAddress] = EventDuration({
            startTimestamp: _startEventTimestamp,
            endTimestamp: _endEventTimestamp
        });

        emit CollectionCreated(
            COLLECTION_HELPERS.collectionId(collectionAddress),
            collectionAddress
        );
    }

    function createToken(
        address _collectionAddress,
        CrossAddress memory _owner
    ) external {
        EventDuration memory collectionEvent = s_collectionEvent[
            _collectionAddress
        ];
        if (block.timestamp < collectionEvent.startTimestamp)
            revert Poap__EventNotStarted();
        if (block.timestamp > collectionEvent.endTimestamp)
            revert Poap__EventFinished();

        // // Pick pseudo random NFT from possible NFTs
        // uint256 pseudoRandomIndex = uint256(
        //     keccak256(
        //         abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)
        //     )
        // ) % collectionEvent.possibleTokens.length;
        // EventToken memory tokenToMint = collectionEvent.possibleTokens[
        //     pseudoRandomIndex
        // ];

        // // Mint an NFT
        // uint256 tokenId = _createToken(
        //     _collectionAddress,
        //     _owner,
        //     tokenToMint.image,
        //     tokenToMint.attributes
        // );

        // emit TokenCreated(
        //     _owner,
        //     COLLECTION_HELPERS.collectionId(_collectionAddress),
        //     tokenId
        // );
    }

    // function setCollectionCreationFee() external onlyOwner {...}
    // function claimCollectionOwnership() external onlyCollectionOwner {...}
}
