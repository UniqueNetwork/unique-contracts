// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../contracts/test/Test__AttributesManager.sol";

contract AttributesManagerTest is Test {
    Test__AttributesManager attributesManager;
    bytes attributes;

    function setUp() public {
        attributesManager = new Test__AttributesManager();
        attributes = bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );
    }

    function test_RemoveTraitFromTheBeginning() public view {
        bytes memory EXPECTED_ATTRIBTUES = bytes(
            '{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );

        bytes memory newAttributes = attributesManager.removeAttribute(
            attributes,
            "age"
        );

        assertEq(newAttributes, EXPECTED_ATTRIBTUES);
    }

    function test_RemoveTraitFromTheMiddle() public view {
        bytes memory EXPECTED_ATTRIBTUES = bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"name","value":"John"}'
        );

        bytes memory newAttributes = attributesManager.removeAttribute(
            attributes,
            "power"
        );

        assertEq(newAttributes, EXPECTED_ATTRIBTUES);
    }

    function test_RemoveTraitFromTheEnd() public view {
        bytes memory EXPECTED_ATTRIBTUES = bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"power","value":"10"}'
        );

        bytes memory newAttributes = attributesManager.removeAttribute(
            attributes,
            "name"
        );

        assertEq(newAttributes, EXPECTED_ATTRIBTUES);
    }
}
