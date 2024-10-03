// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <=0.8.24;

import {CollectionHelpers, CreateCollectionData, CollectionMode, CollectionLimitValue, CollectionNestingAndPermission, Property, TokenPropertyPermission, PropertyPermission, TokenPermissionField} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import "./libraries/UniquePrecompiles.sol";
import "./libraries/UniqueV2Metadata.sol";
import {CrossAddress} from "./UniqueV2TokenMinter.sol";

struct DefaultTokenPropertyPermission {
    bool isMutable;
    bool collectionAdmin;
    bool tokenOwner;
}

/**
 * @title UniqueV2CollectionMinter
 * @dev Abstract contract for minting collections in the Unique V2 Schema.
 */
abstract contract UniqueV2CollectionMinter is UniquePrecompiles {
    DefaultTokenPropertyPermission private s_defaultTokemPropertyPermissions;

    /**
     * @dev Initializes the contract with default property permissions.
     * @param _mutable Boolean indicating if properties are mutable by default.
     * @param _tokenOwner Boolean indicating if the token owner has permissions by default.
     * @param _admin Boolean indicating if the collection admin has permissions by default.
     */
    constructor(bool _mutable, bool _admin, bool _tokenOwner) {
        s_defaultTokemPropertyPermissions = DefaultTokenPropertyPermission(_mutable, _admin, _tokenOwner);
    }

    /**
     * @dev Internal function to create a new collection with default settings.
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
        string memory _collectionCover,
        CrossAddress memory _pending_sponsor
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
                _pending_sponsor,
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
     * @param _pending_sponsor Collection sponsor address
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
        CrossAddress memory _pending_sponsor,
        TokenPropertyPermission[] memory _customTokenPropertyPermissions
    ) internal returns (address) {
        CreateCollectionData memory data;
        data.name = _name;
        data.description = _description;
        data.mode = CollectionMode.Nonfungible;
        data.token_prefix = _symbol;
        data.limits = _limits;
        data.nesting_settings = nesting_settings;
        data.pending_sponsor.eth = _pending_sponsor.eth;
        data.pending_sponsor.sub = _pending_sponsor.sub;

        DefaultTokenPropertyPermission memory defaultTPPs = s_defaultTokemPropertyPermissions;

        data.token_property_permissions = _withUniqueV2TokenPropertyPermissions(
            _customTokenPropertyPermissions,
            defaultTPPs.isMutable,
            defaultTPPs.collectionAdmin,
            defaultTPPs.tokenOwner
        );
        data.properties = _withUniqueV2CollectionProperties(_customCollectionProperties, _collectionCover);

        address collection = COLLECTION_HELPERS.createCollection{value: COLLECTION_HELPERS.collectionCreationFee()}(
            data
        );
        return collection;
    }

    /**
     * @dev Extends default token property permissions with custom permissions.
     * @param _customTPPs Array of custom Token Property Permissions.
     * @return Array of extended Token Property Permissions.
     */
    function _withUniqueV2TokenPropertyPermissions(
        TokenPropertyPermission[] memory _customTPPs,
        bool _defaultMutable,
        bool _defaultCollectionAdmin,
        bool _defaultTokenOwner
    ) internal pure returns (TokenPropertyPermission[] memory) {
        uint256 tppLength = _customTPPs.length + 8;
        TokenPropertyPermission[] memory extendedTPPs = new TokenPropertyPermission[](tppLength);

        PropertyPermission[] memory defaultTPP = _getDefaultTokenPropertyPermission(
            _defaultMutable,
            _defaultTokenOwner,
            _defaultCollectionAdmin
        );

        // Add unique-v2 metadata attributes
        extendedTPPs[0] = TokenPropertyPermission({key: "URI", permissions: defaultTPP});
        extendedTPPs[1] = TokenPropertyPermission({key: "URISuffix", permissions: defaultTPP});
        extendedTPPs[2] = TokenPropertyPermission({key: "customizing_overrides", permissions: defaultTPP});
        extendedTPPs[3] = TokenPropertyPermission({key: "overrides", permissions: defaultTPP});
        extendedTPPs[4] = TokenPropertyPermission({key: "royalties", permissions: defaultTPP});
        extendedTPPs[5] = TokenPropertyPermission({key: "schemaName", permissions: defaultTPP});
        extendedTPPs[6] = TokenPropertyPermission({key: "schemaVersion", permissions: defaultTPP});
        extendedTPPs[7] = TokenPropertyPermission({key: "tokenData", permissions: defaultTPP});

        // Add custom tokenPropertyPermissions
        for (uint256 i = 0; i < _customTPPs.length; i++) {
            extendedTPPs[8 + i] = _customTPPs[i];
        }

        return extendedTPPs;
    }

    /**
     * @dev Constructs collection properties with Unique Schema 2.0 specifications.
     * @param coverImage URL of the cover image.
     * @param customCollectionProperties Array of custom collection properties.
     * @return Array of collection properties including Unique Schema 2.0 specifications.
     */
    function _withUniqueV2CollectionProperties(
        Property[] memory customCollectionProperties,
        string memory coverImage
    ) internal pure returns (Property[] memory) {
        uint256 totalPropertiesLength = customCollectionProperties.length + 3;
        Property[] memory propertiesV2 = new Property[](totalPropertiesLength);

        // Set properties related to Unique Schema 2.0
        propertiesV2[0] = Property({key: "schemaName", value: "unique"});
        propertiesV2[1] = Property({key: "schemaVersion", value: "2.0.0"});

        string memory collectionInfo = string(
            abi.encodePacked('{"schemaName":"unique","schemaVersion":"2.0.0","cover_image":{"url":"', coverImage, '"}}')
        );

        propertiesV2[2] = Property({key: "collectionInfo", value: bytes(collectionInfo)});

        // Set custom collection properties
        for (uint256 i = 0; i < customCollectionProperties.length; i++) {
            propertiesV2[3 + i] = customCollectionProperties[i];
        }

        return propertiesV2;
    }

    /**
     * @dev Generates default token property permissions.
     * @param _defaultMutable Whether properties are mutable by default.
     * @param _defaultCollectionAdmin Whether the collection admin has permissions by default.
     * @param _defaultTokenOwner Whether the token owner has permissions by default.
     * @return Array of default PropertyPermissions.
     */
    function _getDefaultTokenPropertyPermission(
        bool _defaultMutable,
        bool _defaultCollectionAdmin,
        bool _defaultTokenOwner
    ) private pure returns (PropertyPermission[] memory) {
        PropertyPermission[] memory defaultPropertyPermissions = new PropertyPermission[](3);

        defaultPropertyPermissions[0] = PropertyPermission({
            code: TokenPermissionField.Mutable,
            value: _defaultMutable
        });

        defaultPropertyPermissions[1] = PropertyPermission({
            code: TokenPermissionField.TokenOwner,
            value: _defaultCollectionAdmin
        });

        defaultPropertyPermissions[2] = PropertyPermission({
            code: TokenPermissionField.CollectionAdmin,
            value: _defaultTokenOwner
        });

        return defaultPropertyPermissions;
    }
}
