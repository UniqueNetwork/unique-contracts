// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/test/Test__AttributesManager.sol";

contract SetTokenDataTest is Test {
    Test__AttributesManager attributesManager;
    bytes constant tokenData =
        bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

    function setUp() public {
        attributesManager = new Test__AttributesManager();
    }

    function test_CanSetTraitFromBeginning() public view {
        bytes memory EXPECTED_ATTR_SET_BEGINNING = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"33"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = attributesManager.setTrait(tokenData, "age", "33");

        assertEq(newAttributes, EXPECTED_ATTR_SET_BEGINNING);
    }

    function test_CanSetTraitFromTheMiddle() public view {
        bytes memory EXPECTED_ATTR_SET_MID = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"42"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = attributesManager.setTrait(tokenData, "power", "42");

        assertEq(newAttributes, EXPECTED_ATTR_SET_MID);
    }

    function test_CanSetTraitFromTheEnd() public view {
        bytes memory EXPECTED_ATTR_SET_END = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"Alex"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = attributesManager.setTrait(tokenData, "name", "Alex");

        assertEq(newAttributes, EXPECTED_ATTR_SET_END);
    }

    function test_SetNonExistingTrait() public view {
        bytes memory EXPECTED_ATTR_SET_NONEXISTENT = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"nickname","value":"Vitalik777"},{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = attributesManager.setTrait(tokenData, "nickname", "Vitalik777");

        assertEq(newAttributes, EXPECTED_ATTR_SET_NONEXISTENT);
    }

    function test_SetNonExistingTrait_NoTraits() public view {
        bytes memory TOKEN_DATA_NO_ATTRIBUTES = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory EXPECTED_ATTR_SET_NONEXISTENT_NO_ATTRIBUTES = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"nickname","value":"Vitalik777"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newAttributes = attributesManager.setTrait(TOKEN_DATA_NO_ATTRIBUTES, "nickname", "Vitalik777");
        assertEq(newAttributes, EXPECTED_ATTR_SET_NONEXISTENT_NO_ATTRIBUTES);
    }

    function test_SetTraitWithEmptyValue() public view {
        bytes memory EXPECTED_ATTR_SET_EMPTY_VALUE = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":""},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = attributesManager.setTrait(tokenData, "age", "");

        assertEq(newAttributes, EXPECTED_ATTR_SET_EMPTY_VALUE);
    }

    function test_SetTraitWithSpecialCharacters() public view {
        bytes memory specialValue = bytes('He said "Hello"');
        bytes memory EXPECTED_ATTR_SET_SPECIAL = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"He said \\"Hello\\""},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = attributesManager.setTrait(tokenData, "age", specialValue);

        assertEq(newAttributes, EXPECTED_ATTR_SET_SPECIAL);
    }

    function test_SetTraitWhenAttributesFieldIsMissing() public view {
        bytes memory tokenDataWithoutAttributes = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/image.png","royalties":[{"address":"address","percent":"5"}]}'
        );

        // Since attributes field is missing, we expect the original token data to remain unchanged
        bytes memory expectedTokenData = tokenDataWithoutAttributes;

        bytes memory newTokenData = attributesManager.setTrait(tokenDataWithoutAttributes, "age", "33");

        assertEq(newTokenData, expectedTokenData);
    }

    function test_SetTraitWhenTokenDataIsEmpty() public view {
        bytes memory emptyTokenData = bytes("");

        // Since token data is empty, we expect the original token data to remain unchanged
        bytes memory expectedTokenData = emptyTokenData;

        bytes memory newTokenData = attributesManager.setTrait(emptyTokenData, "age", "33");

        assertEq(newTokenData, expectedTokenData);
    }

    function test_SetMultipleTraits() public view {
        bytes memory EXPECTED_ATTR_SET_MULTIPLE = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/image.png","attributes":[{"trait_type":"age","value":"30"},{"trait_type":"power","value":"50"},{"trait_type":"name","value":"Alice"},{"trait_type":"nickname","value":"Wonderland"}],"royalties":[{"address":"address","percent":"5"}]}'
        );

        bytes memory newTokenData = tokenData;

        newTokenData = attributesManager.setTrait(newTokenData, "age", "30");
        newTokenData = attributesManager.setTrait(newTokenData, "power", "50");
        newTokenData = attributesManager.setTrait(newTokenData, "name", "Alice");
        newTokenData = attributesManager.setTrait(newTokenData, "nickname", "Wonderland");

        assertEq(newTokenData, EXPECTED_ATTR_SET_MULTIPLE);
    }
}
