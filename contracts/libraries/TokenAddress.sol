// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TokenAddress {
    // uint of 0xF8238ccFFF8ED887463Fd5e00000000000000000
    uint256 private constant BASE_PATTERN = 1416622503744436009685648840408396639672171757568;

    function fromId(uint256 collectionId, uint256 tokenId) internal pure returns (address result) {
        assembly {
            let combined := or(shl(32, collectionId), tokenId)
            result := or(BASE_PATTERN, combined)
        }
    }
}
