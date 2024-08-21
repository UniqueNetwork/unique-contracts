// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../contracts/test/Test__AttributesManager.sol";

contract RemoveTraitTest is Test {
    Test__AttributesManager attributesManager;
    bytes constant attributes =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"array","value":["first","second"]},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );

    bytes constant EXPECTED_ATTR_REMOVE_BEGINNING =
        bytes(
            '{"trait_type":"array","value":["first","second"]},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );
    bytes constant EXPECTED_ATTR_REMOVE_END =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"array","value":["first","second"]},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"power","value":"10"}'
        );
    bytes constant EXPECTED_ATTR_REMOVE_MID =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"array","value":["first","second"]},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"name","value":"John"}'
        );
    bytes constant EXPECTED_ATTR_REMOVE_OBJ =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"array","value":["first","second"]},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );
    bytes constant EXPECTED_ATTR_REMOVE_ARR =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );

    function setUp() public {
        attributesManager = new Test__AttributesManager();
    }

    function test_RemoveTraitFromTheBeginning() public view {
        bytes memory newAttributes = attributesManager.removeTrait(attributes, "age");

        assertEq(newAttributes, EXPECTED_ATTR_REMOVE_BEGINNING);
    }

    function test_RemoveTraitFromTheMiddle() public view {
        bytes memory newAttributes = attributesManager.removeTrait(attributes, "power");

        assertEq(newAttributes, EXPECTED_ATTR_REMOVE_MID);
    }

    function test_RemoveTraitFromTheEnd() public view {
        bytes memory newAttributes = attributesManager.removeTrait(attributes, "name");

        assertEq(newAttributes, EXPECTED_ATTR_REMOVE_END);
    }

    function test_RemoveTraitArray() public view {
        bytes memory newAttributes = attributesManager.removeTrait(attributes, "array");

        assertEq(newAttributes, EXPECTED_ATTR_REMOVE_ARR);
    }

    function test_RemoveTraitObject() public view {
        bytes memory newAttributes = attributesManager.removeTrait(attributes, "object");

        assertEq(newAttributes, EXPECTED_ATTR_REMOVE_OBJ);
    }
}
