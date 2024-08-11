// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../libraries/AttributesManager.sol";

contract Test__AttributesManager {
    using AttributesManager for *;

    function removeAttribute(
        bytes memory _attributes,
        string memory _trait
    ) public pure returns (bytes memory) {
        return _attributes.removeTrait(_trait);
    }
}
