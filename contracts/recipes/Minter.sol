// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueNFT} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
import {Property, CollectionLimitValue} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import {UniqueV2CollectionMinter, CollectionMode, TokenPropertyPermission} from "../UniqueV2CollectionMinter.sol";
import {UniqueV2TokenMinter, Attribute, CrossAddress} from "../UniqueV2TokenMinter.sol";

/**
 * @title Minter
 * @notice ❗️DISCLAIMER: This contract is provided as an example and is not production-ready.
 * It is intended for educational and testing purposes only. Use at your own risk.
 *
 * @dev Contract for minting collections and tokens in the Unique Schema V2.
 * It sets sponsoring for each collection to create a gasless experience for end users.
 * Inherits from UniqueV2CollectionMinter and UniqueV2TokenMinter.
 * See the example in tests https://github.com/UniqueNetwork/unique-contracts/blob/main/test/minter.spec.ts
 */
contract Minter is UniqueV2CollectionMinter, UniqueV2TokenMinter {
    /// @dev Event emitted when a new collection is created.
    event CollectionCreated(address collectionAddress);

    /**
     * @dev Constructor that sets default property permissions and allows the contract to receive UNQ.
     * This contract sponsors every collection and token minting which is why it should have a balance of UNQ
     * Sets properties as
     * - mutable
     * - token owner has no default permissions to change properties
     * - collectionAdmin has default permissions to change properties.
     */
    constructor() payable UniqueV2CollectionMinter(true, false, true) {}

    receive() external payable {}

    /**
     * @dev Function to mint a new collection.
     * @param _name Name of the collection.
     * @param _description Description of the collection.
     * @param _symbol Symbol prefix for the tokens in the collection.
     * @param _collectionCover URL of the cover image for the collection.
     * @return Address of the created collection.
     */
    function mintCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover
    ) external payable returns (address) {
        address collectionAddress = _createCollection(
            _name,
            _description,
            _symbol,
            _collectionCover,
            new CollectionLimitValue[](0),
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
        // Sponsor every transaction

        // Set this contract as an admin
        // Because the minted collection will be owned by the user this contract
        // has to be set as a collection admin in order to be able to mint NFTs
        collection.addCollectionAdminCross(
            CrossAddress({eth: address(this), sub: 0})
        );

        // Transfer ownership of the collection to the contract caller
        collection.changeCollectionOwnerCross(
            CrossAddress({eth: msg.sender, sub: 0})
        );

        emit CollectionCreated(collectionAddress);

        return collectionAddress;
    }

    /**
     * @dev Function to mint a new token within a collection.
     * @param collectionAddress Address of the collection in which to mint the token. The contract should be an admin for the collection
     * @param _image URL of the token image.
     * @param _attributes Array of attributes for the token.
     */
    function mintToken(
        address collectionAddress,
        string memory _image,
        Attribute[] memory _attributes
    ) external {
        _createToken(
            collectionAddress,
            _image,
            _attributes,
            CrossAddress({eth: msg.sender, sub: 0})
        );
    }
}
