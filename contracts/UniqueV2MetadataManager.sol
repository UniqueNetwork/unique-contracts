// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {PropertyPermission, TokenPropertyPermission, TokenPermissionField, Property} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";

/**
 * @title UniqueV2MetadataManager
 * @dev Abstract contract for managing metadata and permissions in the Unique V2 Schema.
 */
abstract contract UniqueV2MetadataManager {
    /// @notice Default Token Property Permissions
    PropertyPermission[] private s_defaultTPP;

    /**
     * @dev Initializes the contract with default property permissions.
     * @param _defaultMutable Boolean indicating if properties are mutable by default.
     * @param _defaultTokenOwner Boolean indicating if the token owner has permissions by default.
     * @param _defaultCollectionAdmin Boolean indicating if the collection admin has permissions by default.
     */
    constructor(
        bool _defaultMutable,
        bool _defaultTokenOwner,
        bool _defaultCollectionAdmin
    ) {
        s_defaultTPP.push(
            PropertyPermission({
                code: TokenPermissionField.TokenOwner,
                value: _defaultTokenOwner
            })
        );
        s_defaultTPP.push(
            PropertyPermission({
                code: TokenPermissionField.CollectionAdmin,
                value: _defaultCollectionAdmin
            })
        );
        s_defaultTPP.push(
            PropertyPermission({
                code: TokenPermissionField.Mutable,
                value: _defaultMutable
            })
        );
    }

    /**
     * @dev Extends default token property permissions with custom permissions.
     * @param _customTPPs Array of custom Token Property Permissions.
     * @return Array of extended Token Property Permissions.
     */
    function withTokenPropertyPermissionsUniqueV2(
        TokenPropertyPermission[] memory _customTPPs
    ) internal view returns (TokenPropertyPermission[] memory) {
        uint256 tppLength = _customTPPs.length + 8;
        TokenPropertyPermission[]
            memory extendedTPPs = new TokenPropertyPermission[](tppLength);

        PropertyPermission[] memory defaultTPP = s_defaultTPP;
        extendedTPPs[0] = TokenPropertyPermission({
            key: "URI",
            permissions: defaultTPP
        });

        extendedTPPs[1] = TokenPropertyPermission({
            key: "URISuffix",
            permissions: defaultTPP
        });

        extendedTPPs[2] = TokenPropertyPermission({
            key: "customizing_overrides",
            permissions: defaultTPP
        });

        extendedTPPs[3] = TokenPropertyPermission({
            key: "overrides",
            permissions: defaultTPP
        });

        extendedTPPs[4] = TokenPropertyPermission({
            key: "royalties",
            permissions: defaultTPP
        });

        extendedTPPs[5] = TokenPropertyPermission({
            key: "schemaName",
            permissions: defaultTPP
        });

        extendedTPPs[6] = TokenPropertyPermission({
            key: "schemaVersion",
            permissions: defaultTPP
        });

        extendedTPPs[7] = TokenPropertyPermission({
            key: "tokenData",
            permissions: defaultTPP
        });

        // Add custom tokenPropertyPermissions permissions
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
    function withCollectionPropertiesUniqueV2(
        string memory coverImage,
        Property[] memory customCollectionProperties
    ) internal pure returns (Property[] memory) {
        uint256 totalPropertiesLength = customCollectionProperties.length + 3;
        Property[] memory propertiesV2 = new Property[](totalPropertiesLength);

        // set properties related to Unique Schema 2.0
        propertiesV2[0] = Property({key: "schemaName", value: "unique"});
        propertiesV2[1] = Property({key: "schemaVersion", value: "2.0.0"});

        string
            memory collectionInfoPart1 = '{"schemaName":"unique","schemaVersion":"2.0.0","cover_image":{"url":"';
        string memory collectionInfoPart2 = '"}}';

        propertiesV2[2] = Property({
            key: "collectionInfo",
            value: bytes(
                string.concat(
                    collectionInfoPart1,
                    coverImage,
                    collectionInfoPart2
                )
            )
        });

        // set custom collection properties
        for (uint256 i = 0; i < customCollectionProperties.length; i++) {
            propertiesV2[3 + i] = customCollectionProperties[i];
        }

        return propertiesV2;
    }
}
