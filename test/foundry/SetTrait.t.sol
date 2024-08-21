// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../contracts/test/Test__AttributesManager.sol";

contract SetTraitTest is Test {
    Test__AttributesManager attributesManager;
    bytes constant attributes =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"array","value":["first","second"]},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );

    bytes constant EXPECTED_ATTR_SET_BEGINNING =
        bytes(
            '{"trait_type":"age","value":"12"},{"trait_type":"array","value":["first","second"]},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );
    bytes constant EXPECTED_ATTR_SET_END =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"array","value":["first","second"]},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"Alex"}'
        );
    bytes constant EXPECTED_ATTR_SET_MID =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"array","value":["first","second"]},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"power","value":"42"},{"trait_type":"name","value":"John"}'
        );
    bytes constant EXPECTED_ATTR_SET_OBJ =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"array","value":["first","second"]},{"trait_type":"object","value":{"newKey1":"newValue1","newKey2":{"deepKey":"deepValue"}},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );
    bytes constant EXPECTED_ATTR_SET_ARR =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"array","value":["completely","new"]},{"trait_type":"object","value":{"key1":"value1","key2":"value2"}},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );

    function setUp() public {
        attributesManager = new Test__AttributesManager();
    }

    function test_SetTraitFromBeginning() public view {
        bytes memory newAttributes = attributesManager.setTrait(
            attributes,
            "age",
            "12"
        );

        assertEq(newAttributes, EXPECTED_ATTR_SET_BEGINNING);
    }

    function test_SetTraitFromTheMiddle() public view {
        bytes memory newAttributes = attributesManager.setTrait(
            attributes,
            "power",
            "42"
        );

        assertEq(newAttributes, EXPECTED_ATTR_SET_MID);
    }

    function test_SetTraitFromTheEnd() public view {
        bytes memory newAttributes = attributesManager.setTrait(
            attributes,
            "name",
            "Alex"
        );

        assertEq(newAttributes, EXPECTED_ATTR_SET_END);
    }

    function test_SetTraitArray() public view {
        bytes memory newAttributes = attributesManager.setTrait(
            attributes,
            "array",
            '["completely","new"]'
        );

        assertEq(newAttributes, EXPECTED_ATTR_SET_ARR);
    }

    function test_SetTraitObject() public view {
        bytes memory newAttributes = attributesManager.setTrait(
            attributes,
            "object",
            '{"newKey1":"newValue1","newKey2":{"deepKey":"deepValue"}}'
        );

        assertEq(newAttributes, EXPECTED_ATTR_SET_OBJ);
    }
}
