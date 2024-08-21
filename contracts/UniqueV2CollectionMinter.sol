// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {CollectionHelpers, CreateCollectionData, CollectionMode, CollectionLimitValue, CollectionNestingAndPermission} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import "./libraries/UniquePrecompiles.sol";
import "./libraries/UniqueV2Metadata.sol";

/**
 * @title UniqueV2CollectionMinter
 * @dev Abstract contract for minting collections in the Unique V2 Schema.
 */
abstract contract UniqueV2CollectionMinter is UniquePrecompiles {
    using UniqueV2Metadata for *;

    /**
     * @dev Initializes the contract with default property permissions.
     * @param _mutable Boolean indicating if properties are mutable by default.
     * @param _tokenOwner Boolean indicating if the token owner has permissions by default.
     * @param _admin Boolean indicating if the collection admin has permissions by default.
     */
    constructor(bool _mutable, bool _tokenOwner, bool _admin) {}

    /**
     * @dev Internal function to create a new collection with default settings.
     *
     * This function simplifies the process of creating a new collection by using default values for
     * nesting and permission settings, as well as empty arrays for limits, properties, and token property
     * permissions. It returns the address of the newly created collection.
     *
     * @param _name The name of the collection to be created.
     * @param _description A brief description of the collection.
     * @param _symbol The symbol prefix that will be used for the tokens in this collection.
     * @param _collectionCover A URL pointing to the cover image of the collection.
     *
     * @return address The address of the newly created collection.
     */
    function _createCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover
    ) internal returns (address) {
        return
            _createCollection(
                _name,
                _description,
                _symbol,
                _collectionCover,
                CollectionNestingAndPermission({
                    token_owner: true,
                    collection_admin: true,
                    restricted: new address[](0)
                }),
                new CollectionLimitValue[](0),
                new Property[](0),
                new TokenPropertyPermission[](0)
            );
    }

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
        CollectionNestingAndPermission memory nesting_settings,
        CollectionLimitValue[] memory _limits,
        Property[] memory _customCollectionProperties,
        // CollectionMode mode,
        // CrossAddress memory _pending_sponsor,
        TokenPropertyPermission[] memory _customTokenPropertyPermissions
    ) internal returns (address) {
        CreateCollectionData memory data;
        data.name = _name;
        data.description = _description;
        data.mode = CollectionMode.Nonfungible;
        data.token_prefix = _symbol;
        data.limits = _limits;
        data.nesting_settings = nesting_settings;
        data.token_property_permissions = _customTokenPropertyPermissions.withUniqueV2TokenPropertyPermissions(
            true,
            false,
            true
        );
        data.properties = _customCollectionProperties.withUniqueV2CollectionProperties(_collectionCover);

        address collection = COLLECTION_HELPERS.createCollection{value: COLLECTION_HELPERS.collectionCreationFee()}(
            data
        );
        return collection;
    }
}
