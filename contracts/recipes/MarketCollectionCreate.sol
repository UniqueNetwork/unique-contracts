// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueNFT, CollectionLimit} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";
import {Property, TokenPropertyPermission, CollectionLimitValue, CollectionLimitField, CollectionNestingAndPermission} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import {UniqueV2CollectionMinter} from "../UniqueV2CollectionMinter.sol";
import {CrossAddress} from "../UniqueV2TokenMinter.sol";

/**
 * @title MarketCollectionCreate
 * @notice This contract integrates collection creation using Ethereum wallets on a marketplace.
 */
contract MarketCollectionCreate is UniqueV2CollectionMinter {

    event CollectionCreated(uint256 collectionId, address collectionAddress);

    error IncorrectFee();

    constructor() payable UniqueV2CollectionMinter(true, true, true) {}

    receive() external payable {}

    /**
     * @notice Creates a new collection. The collection creation fee must be paid.
     * @param _name The name of the collection.
     * @param _description A brief description of the collection.
     * @param _symbol The symbol or prefix for tokens in the collection.
     * @param _collectionCover A URL pointing to the cover image for the collection.
     * @param _transferEnabled Boolean flag indicating if token transfers are allowed.
     * @param _tokenLimit The maximum number of tokens that can be minted in the collection.
     * @param _accountTokenOwnership The maximum number of tokens one account can own in the collection.
     * @param _nestingPermissionsTokenOwner Boolean flag indicating if the token owner has nesting permissions.
     * @param _nestingPermissionsCollectionAdmin Boolean flag indicating if the collection admin has nesting permissions.
     */
    function createCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover,
        bool _transferEnabled,
        uint256 _tokenLimit,
        uint256 _accountTokenOwnership,
        bool _nestingPermissionsTokenOwner,
        bool _nestingPermissionsCollectionAdmin
    ) external payable {
        if (msg.value != COLLECTION_HELPERS.collectionCreationFee()) revert IncorrectFee();

        // 1. Set collection limits
        CollectionLimitValue[] memory collectionLimits = new CollectionLimitValue[](3);
        // 1.1. set account token limit
        if (_accountTokenOwnership > 0) {
            collectionLimits[0] = CollectionLimitValue({
                field: CollectionLimitField.AccountTokenOwnership,
                value: _accountTokenOwnership
            });
        }

        // 1.2. Set collection token limit
        if (_tokenLimit > 0) {
            collectionLimits[1] = CollectionLimitValue({
                field: CollectionLimitField.TokenLimit,
                value: _tokenLimit
            });
        }
        
        // 1.3 Transfers are not allowed
        collectionLimits[2] = CollectionLimitValue({
            field: CollectionLimitField.TransferEnabled,
            value: _transferEnabled ? 1 : 0
        });

        // 2. Create a collection
        address collectionAddress = _createCollection(
            _name,
            _description,
            _symbol,
            _collectionCover,
            CollectionNestingAndPermission({
                token_owner: _nestingPermissionsTokenOwner,
                collection_admin: _nestingPermissionsCollectionAdmin,
                restricted: new address[](0) 
            }),
            collectionLimits,
            new Property[](0),
            CrossAddress({eth: address(msg.sender), sub: 0}),
            new TokenPropertyPermission[](0)
        );

        UniqueNFT collection = UniqueNFT(collectionAddress);
        COLLECTION_HELPERS.makeCollectionERC721MetadataCompatible(collectionAddress, _collectionCover);
        collection.changeCollectionOwnerCross(CrossAddress(msg.sender, 0));

        emit CollectionCreated(COLLECTION_HELPERS.collectionId(collectionAddress), collectionAddress);
    }
}
