// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../libraries/AttributeUtils.sol";

contract Test__AttributesManager {
    using AttributeUtils for *;

    function removeTrait(bytes memory _attributes, string memory _trait) public pure returns (bytes memory) {
        return _attributes.dangerRemoveTrait(_trait);
    }

    function setTrait(
        bytes memory _str,
        string memory _traitType,
        string memory _newValue
    ) public pure returns (bytes memory) {
        return _str.dangerSetTraitValue(_traitType, _newValue);
    }
}
