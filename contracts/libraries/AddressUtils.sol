// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <=0.8.24;

import {UniqueNFT, CrossAddress} from "@unique-nft/solidity-interfaces/contracts/UniqueNFT.sol";

library AddressUtils {
    function isValid(CrossAddress memory _crossAddress) internal pure returns (bool) {
        if (_crossAddress.eth == address(0) && _crossAddress.sub == 0) return false;
        if (_crossAddress.eth != address(0) && _crossAddress.sub != 0) return false;
        return true;
    }

    function isMessageSender(CrossAddress memory _crossAddress) internal view returns (bool) {
        if (!isValid(_crossAddress)) return false;
        if (_crossAddress.eth == msg.sender) return true;
        if (substratePublicKeyToAddress(_crossAddress.sub) == msg.sender) return true;
        return false;
    }

    function messageSenderIsTokenOwner(address _collection, uint256 _tokenId) internal view returns (bool) {
        CrossAddress memory tokenOwner = UniqueNFT(_collection).ownerOfCross(_tokenId);

        return isMessageSender(tokenOwner);
    }

    function substratePublicKeyToAddress(uint256 _pubkey) internal pure returns (address) {
        return address(uint160(_pubkey >> 96));
    }
}
