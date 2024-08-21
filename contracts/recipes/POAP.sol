// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueNFT} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
import {Property, CollectionMode, TokenPropertyPermission, CollectionLimitValue, CollectionLimitField, CollectionNestingAndPermission} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import {UniqueV2CollectionMinter} from "../UniqueV2CollectionMinter.sol";
import {UniqueV2TokenMinter, Attribute, CrossAddress} from "../UniqueV2TokenMinter.sol";

/**
 * @notice This struct represents an event configuration for POAP tokens.
 * - NFTs cannot be minted if block.timestamp < startTimestamp.
 * - NFTs cannot be minted if block.timestamp > endTimestamp.
 * - Every token will have a tokenImage.
 * - Every token will have specified attributes.
 */
struct EventConfig {
    uint256 startTimestamp;
    uint256 endTimestamp;
    string tokenImage;
    Attribute[] attributes;
}

/**
 * @title POAP
 * @notice ❗️DISCLAIMER: This contract is provided as an example and is not production-ready.
 * It is intended for educational and testing purposes only.
 *
 * This contract demonstrates a possible approach to Proof of Attendance NFTs (POAP).
 * Anyone can pay the collection creation fee and start a POAP event.
 * Token minting transactions are completely free for end users and sponsored by this contract.
 * This contract should have some UNQ on its balance in order to sponsor transactions.
 * This contract is supposed to be sponsored:
 * See the example in tests https://github.com/UniqueNetwork/unique-contracts/blob/main/test/poap.spec.ts
 */
contract POAP is UniqueV2CollectionMinter, UniqueV2TokenMinter {
    /// @notice Only one NFT per account can be minted.
    uint256 public constant ACCOUNT_TOKEN_LIMIT = 1;

    /// @dev Everyone who wants to create an event should pay this fee.
    uint256 private s_collectionCreationFee;

    /// @dev When a collection is created by POAP, its configuration is stored here.
    mapping(address collection => EventConfig) s_collectionEvent;

    event CollectionCreated(uint256 collectionId, address collectionAddress);
    event TokenCreated(CrossAddress indexed owner, uint256 indexed colletionId, uint256 tokenId);

    error Poap__IncorrectFee();
    error Poap__EventNotStarted();
    error Poap__EventFinished();

    /**
     * @dev Sets default property permissions and allows the contract to receive UNQ.
     * This contract sponsors every collection and token minting, which is why it should have a balance of UNQ.
     * Sets properties as:
     * - mutable
     * - token owner has no permissions to change properties
     * - collection admin has permissions to change properties.
     * @param _collectionCreationFee The fee required to create a collection.
     */
    constructor(uint256 _collectionCreationFee) payable UniqueV2CollectionMinter(true, false, true) {
        s_collectionCreationFee = _collectionCreationFee;
    }

    receive() external payable {}

    /**
     * @notice Creates a new collection. The collection creation fee must be paid.
     * @param _name Name of the collection.
     * @param _description Description of the collection.
     * @param _symbol Symbol prefix for the tokens in the collection.
     * @param _collectionCover URL of the cover image for the collection.
     * @param _eventConfig Configuration of the event.
     */
    function createCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover,
        EventConfig memory _eventConfig
    ) external payable {
        if (msg.value != s_collectionCreationFee) revert Poap__IncorrectFee();

        // 1. Set collection limits
        CollectionLimitValue[] memory collectionLimits = new CollectionLimitValue[](2);
        // 1.1. Every account can own only 1 NFT (ACCOUNT_TOKEN_LIMIT)
        collectionLimits[0] = CollectionLimitValue({
            field: CollectionLimitField.AccountTokenOwnership,
            value: ACCOUNT_TOKEN_LIMIT
        });

        // 1.2 Transfers are not allowed
        collectionLimits[1] = CollectionLimitValue({field: CollectionLimitField.TransferEnabled, value: 0});

        // 2. Create a collection
        address collectionAddress = _createCollection(
            _name,
            _description,
            _symbol,
            _collectionCover,
            CollectionNestingAndPermission({token_owner: false, collection_admin: false, restricted: new address[](0)}),
            collectionLimits,
            new Property[](0),
            new TokenPropertyPermission[](0)
        );

        UniqueNFT collection = UniqueNFT(collectionAddress);

        // 3. Set collection sponsorship
        // Every transaction will be paid by the POAP-contract
        collection.setCollectionSponsorCross(CrossAddress({eth: address(this), sub: 0}));
        // 3.1 Confirm collection sponsorship
        collection.confirmCollectionSponsorship();

        // 4. Set event configuration
        s_collectionEvent[collectionAddress].startTimestamp = _eventConfig.startTimestamp;
        s_collectionEvent[collectionAddress].endTimestamp = _eventConfig.endTimestamp;
        s_collectionEvent[collectionAddress].tokenImage = _eventConfig.tokenImage;

        for (uint i = 0; i < _eventConfig.attributes.length; i++) {
            s_collectionEvent[collectionAddress].attributes.push(_eventConfig.attributes[i]);
        }

        emit CollectionCreated(COLLECTION_HELPERS.collectionId(collectionAddress), collectionAddress);
    }

    /**
     * @notice Creates a token. This transaction will be free for the end user.
     * Only one NFT can be minted for each account. This rule is enforced by the collection limit: AccountTokenOwnership.
     * @param _collectionAddress The address of the collection created by this contract.
     * @param _owner CrossAddress of the NFT owner. It can be both an EVM or Substrate account.
     */
    function createToken(address _collectionAddress, CrossAddress memory _owner) external {
        EventConfig memory collectionEvent = s_collectionEvent[_collectionAddress];

        // 1. Check if the event has started and not finished yet
        if (block.timestamp < collectionEvent.startTimestamp) revert Poap__EventNotStarted();
        if (block.timestamp > collectionEvent.endTimestamp) revert Poap__EventFinished();

        // 2. Create NFT
        uint256 tokenId = _createToken(
            _collectionAddress,
            collectionEvent.tokenImage,
            collectionEvent.attributes,
            _owner
        );

        emit TokenCreated(_owner, COLLECTION_HELPERS.collectionId(_collectionAddress), tokenId);
    }

    /// For testing purposes only
    function timestampNow() external view returns (uint256) {
        return block.timestamp;
    }
}
