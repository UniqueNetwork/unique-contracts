// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {PropertyPermission, TokenPropertyPermission, TokenPermissionField, Property} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";

/**
 * @title UniqueV2Metadata
 * @dev Abstract contract for managing metadata and permissions in the Unique V2 Schema.
 */
library UniqueV2Metadata {
    /**
     * @dev Extends default token property permissions with custom permissions.
     * @param _customTPPs Array of custom Token Property Permissions.
     * @return Array of extended Token Property Permissions.
     */
    function withUniqueV2TokenPropertyPermissions(
        TokenPropertyPermission[] memory _customTPPs,
        bool _defaultMutable,
        bool _defaultTokenOwner,
        bool _defaultCollectionAdmin
    ) internal pure returns (TokenPropertyPermission[] memory) {
        uint256 tppLength = _customTPPs.length + 8;
        TokenPropertyPermission[] memory extendedTPPs = new TokenPropertyPermission[](tppLength);

        PropertyPermission[] memory defaultTPP = getDefaultTokenPropertyPermission(
            _defaultMutable,
            _defaultTokenOwner,
            _defaultCollectionAdmin
        );

        extendedTPPs[0] = TokenPropertyPermission({key: "URI", permissions: defaultTPP});

        extendedTPPs[1] = TokenPropertyPermission({key: "URISuffix", permissions: defaultTPP});

        extendedTPPs[2] = TokenPropertyPermission({key: "customizing_overrides", permissions: defaultTPP});

        extendedTPPs[3] = TokenPropertyPermission({key: "overrides", permissions: defaultTPP});

        extendedTPPs[4] = TokenPropertyPermission({key: "royalties", permissions: defaultTPP});

        extendedTPPs[5] = TokenPropertyPermission({key: "schemaName", permissions: defaultTPP});

        extendedTPPs[6] = TokenPropertyPermission({key: "schemaVersion", permissions: defaultTPP});

        extendedTPPs[7] = TokenPropertyPermission({key: "tokenData", permissions: defaultTPP});

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
    function withUniqueV2CollectionProperties(
        Property[] memory customCollectionProperties,
        string memory coverImage
    ) internal pure returns (Property[] memory) {
        uint256 totalPropertiesLength = customCollectionProperties.length + 3;
        Property[] memory propertiesV2 = new Property[](totalPropertiesLength);

        // set properties related to Unique Schema 2.0
        propertiesV2[0] = Property({key: "schemaName", value: "unique"});
        propertiesV2[1] = Property({key: "schemaVersion", value: "2.0.0"});

        string memory collectionInfoPart1 = '{"schemaName":"unique","schemaVersion":"2.0.0","cover_image":{"url":"';
        string memory collectionInfoPart2 = '"}}';

        propertiesV2[2] = Property({
            key: "collectionInfo",
            value: bytes(string.concat(collectionInfoPart1, coverImage, collectionInfoPart2))
        });

        // set custom collection properties
        for (uint256 i = 0; i < customCollectionProperties.length; i++) {
            propertiesV2[3 + i] = customCollectionProperties[i];
        }

        return propertiesV2;
    }

    function getDefaultTokenPropertyPermission(
        bool _defaultMutable,
        bool _defaultTokenOwner,
        bool _defaultCollectionAdmin
    ) private pure returns (PropertyPermission[] memory) {
        PropertyPermission[] memory defaultPropertyPermissions = new PropertyPermission[](3);

        defaultPropertyPermissions[0] = PropertyPermission({
            code: TokenPermissionField.Mutable,
            value: _defaultMutable
        });

        defaultPropertyPermissions[1] = PropertyPermission({
            code: TokenPermissionField.TokenOwner,
            value: _defaultTokenOwner
        });

        defaultPropertyPermissions[2] = PropertyPermission({
            code: TokenPermissionField.CollectionAdmin,
            value: _defaultCollectionAdmin
        });

        return defaultPropertyPermissions;
    }
}
