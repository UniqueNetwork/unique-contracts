// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "@unique-nft/solidity-interfaces/contracts/CollectionHelpers.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./UniqueV2MetadataManager.sol";

contract CollectionMinter is UniqueV2MetadataManager, Ownable {
    CollectionHelpers private constant COLLECTION_HELPERS =
        CollectionHelpers(0x6C4E9fE1AE37a41E93CEE429e8E1881aBdcbb54F);

    uint256 private s_collectionCreationFee;

    constructor(
        bool _mutable,
        bool _tokenOwner,
        bool _admin
    )
        payable
        UniqueV2MetadataManager(_mutable, _tokenOwner, _admin)
        Ownable(msg.sender)
    {
        s_collectionCreationFee = 2e18;
    }

    receive() external payable {}

    function changeCollectionCreationFee(uint256 _newFee) external onlyOwner {
        s_collectionCreationFee = _newFee;
    }

    function _createCollection(
        string memory _name,
        string memory _description,
        string memory _symbol,
        string memory _collectionCover,
        // CollectionMode mode,
        // CrossAddress memory _pending_sponsor,
        TokenPropertyPermission[] memory _token_property_permissions
    ) internal returns (address) {
        CreateCollectionData memory data;
        data.name = _name;
        data.description = _description;
        data.mode = CollectionMode.Nonfungible;
        data.token_prefix = _symbol;
        data.token_property_permissions = getTokenPropertyPermissionsV2(
            _token_property_permissions
        );
        data.properties = getCollectionPropertiesV2(_collectionCover);

        address collection = COLLECTION_HELPERS.createCollection{value: 2e18}(
            data
        );
        return collection;
    }
}
