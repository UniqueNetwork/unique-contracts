// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {PropertyPermission, TokenPropertyPermission, TokenPermissionField, Property} from "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";

abstract contract UniqueV2MetadataManager {
    PropertyPermission[] private s_defaultTPP;
    TokenPropertyPermission[] private s_uniqueMetadataPermissionsV2;
    Property[] private s_uniquePropertiesV2;

    constructor(
        bool _defaultMutable,
        bool _defaultTokenOwner,
        bool _defaultCollectionAdmin
    ) {
        s_defaultTPP.push(
            PropertyPermission({
                code: TokenPermissionField.TokenOwner,
                value: _defaultMutable
            })
        );
        s_defaultTPP.push(
            PropertyPermission({
                code: TokenPermissionField.CollectionAdmin,
                value: _defaultTokenOwner
            })
        );
        s_defaultTPP.push(
            PropertyPermission({
                code: TokenPermissionField.Mutable,
                value: _defaultCollectionAdmin
            })
        );
    }

    function getTokenPropertyPermissionsV2(
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

        // Add the predefined permissions
        for (uint256 i = 0; i < _customTPPs.length; i++) {
            extendedTPPs[
                s_uniqueMetadataPermissionsV2.length + i
            ] = _customTPPs[i];
        }

        return extendedTPPs;
    }

    function getCollectionPropertiesV2(
        string memory coverImage
    ) internal pure returns (Property[] memory) {
        Property[] memory propertiesV2 = new Property[](3);
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

        return propertiesV2;
    }
}
