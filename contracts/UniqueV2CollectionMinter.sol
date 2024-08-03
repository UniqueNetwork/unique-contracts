// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {CollectionHelpers, CreateCollectionData, CollectionMode} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import "./UniqueV2MetadataManager.sol";

/**
 * @title UniqueV2CollectionMinter
 * @dev Abstract contract for minting collections in the Unique V2 Schema.
 */
abstract contract UniqueV2CollectionMinter is UniqueV2MetadataManager {
    CollectionHelpers internal constant COLLECTION_HELPERS =
        CollectionHelpers(0x6C4E9fE1AE37a41E93CEE429e8E1881aBdcbb54F);

    /**
     * @dev Initializes the contract with default property permissions.
     * @param _mutable Boolean indicating if properties are mutable by default.
     * @param _tokenOwner Boolean indicating if the token owner has permissions by default.
     * @param _admin Boolean indicating if the collection admin has permissions by default.
     */
    constructor(
        bool _mutable,
        bool _tokenOwner,
        bool _admin
    ) UniqueV2MetadataManager(_mutable, _tokenOwner, _admin) {}

    /**
     * @dev Internal function to create a new collection.
     * @param _name Name of the collection.
     * @param _description Description of the collection.
     * @param _symbol Symbol prefix for the tokens in the collection.
     * @param _collectionCover URL of the cover image for the collection.
     * @param _customCollectionProperties Array of custom properties for the collection.
     * @param _customTokenPropertyPermissions Array of custom token property permissions.
     * @return Address of the created collection.
     */
    function _createCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover,
        Property[] memory _customCollectionProperties,
        // CollectionMode mode,
        // CollectionNestingAndPermission nesting_settings,
        // CrossAddress memory _pending_sponsor,
        TokenPropertyPermission[] memory _customTokenPropertyPermissions
    ) internal returns (address) {
        CreateCollectionData memory data;
        data.name = _name;
        data.description = _description;
        data.mode = CollectionMode.Nonfungible;
        data.token_prefix = _symbol;
        data.token_property_permissions = withTokenPropertyPermissionsUniqueV2(
            _customTokenPropertyPermissions
        );
        data.properties = withCollectionPropertiesUniqueV2(
            _collectionCover,
            _customCollectionProperties
        );

        address collection = COLLECTION_HELPERS.createCollection{
            value: COLLECTION_HELPERS.collectionCreationFee()
        }(data);
        return collection;
    }
}
