// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../contracts/libraries/AttributeUtils.sol";

contract SetTokenDataTest is Test {
    using AttributeUtils for *;
    bytes constant tokenData =
        bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

    function test_CanSetTraitFromBeginning() public pure {
        bytes memory EXPECTED_ATTR_SET_BEGINNING = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"33"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("age", "33");

        assertEq(newAttributes, EXPECTED_ATTR_SET_BEGINNING);
    }

    function test_CanSetTraitFromTheMiddle() public pure {
        bytes memory EXPECTED_ATTR_SET_MID = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"42"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("power", "42");

        assertEq(newAttributes, EXPECTED_ATTR_SET_MID);
    }

    function test_CanSetTraitFromTheEnd() public pure {
        bytes memory EXPECTED_ATTR_SET_END = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"Alex"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("name", "Alex");

        assertEq(newAttributes, EXPECTED_ATTR_SET_END);
    }

    function test_SetNonExistingTrait() public pure {
        bytes memory EXPECTED_ATTR_SET_NONEXISTENT = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"nickname","value":"Vitalik777"},{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("nickname", "Vitalik777");

        assertEq(newAttributes, EXPECTED_ATTR_SET_NONEXISTENT);
    }

    function test_SetNonExistingTraitWhenNoTraits() public pure {
        bytes memory TOKEN_DATA_NO_ATTRIBUTES = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory EXPECTED_ATTR_SET_NONEXISTENT_NO_ATTRIBUTES = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"nickname","value":"Vitalik777"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newAttributes = TOKEN_DATA_NO_ATTRIBUTES.setTrait("nickname", "Vitalik777");
        assertEq(newAttributes, EXPECTED_ATTR_SET_NONEXISTENT_NO_ATTRIBUTES);
    }

    function test_SetTraitWithSimilarTraitType1() public pure {
        // Existing trait_type is "age", we attempt to set "agee"
        bytes memory EXPECTED_ATTR_SET_SIMILAR = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"agee","value":"33"},{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newTokenData = tokenData.setTrait("agee", "33");

        assertEq(newTokenData, EXPECTED_ATTR_SET_SIMILAR);
    }

    function test_SetTraitWithSimilarTraitType2() public pure {
        // Existing trait_type is "age", we attempt to set "ag"
        bytes memory EXPECTED_ATTR_SET_SIMILAR = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"ag","value":"33"},{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newTokenData = tokenData.setTrait("ag", "33");

        assertEq(newTokenData, EXPECTED_ATTR_SET_SIMILAR);
    }

    function test_SetTraitWithEmptyValue() public pure {
        bytes memory EXPECTED_ATTR_SET_EMPTY_VALUE = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":""},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("age", "");

        assertEq(newAttributes, EXPECTED_ATTR_SET_EMPTY_VALUE);
    }

    function test_SetTraitWithSpecialCharactersInValue() public pure {
        bytes memory EXPECTED_ATTR_SET_SPECIAL = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"He said \\"Hello\\""},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("age", bytes('He said "Hello"'));

        assertEq(newAttributes, EXPECTED_ATTR_SET_SPECIAL);
    }

    function test_SetTraitWithSpecialCharactersInTraitType() public pure {
        bytes memory EXPECTED_ATTR_SET_SPECIAL_TRAIT_TYPE = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"He said \\"Hello\\"","value":"42"},{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait(bytes('He said "Hello"'), "42");

        assertEq(newAttributes, EXPECTED_ATTR_SET_SPECIAL_TRAIT_TYPE);
    }

    function test_SetTraitWithBackslashInTraitType() public pure {
        bytes memory EXPECTED_ATTR_SET_BACKSLASH = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"C:\\\\Users\\\\User","value":"age"},{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("C:\\Users\\User", bytes("age"));

        assertEq(newAttributes, EXPECTED_ATTR_SET_BACKSLASH);
    }

    function test_SetTraitWithBackslashInValue() public pure {
        bytes memory EXPECTED_ATTR_SET_BACKSLASH = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"C:\\\\Users\\\\User"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("age", bytes("C:\\Users\\User"));

        assertEq(newAttributes, EXPECTED_ATTR_SET_BACKSLASH);
    }

    function test_SetTraitWithNewlineInValue() public pure {
        bytes memory EXPECTED_ATTR_SET_NEWLINE = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"Line1\\nLine2"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("age", bytes("Line1\nLine2"));

        assertEq(newAttributes, EXPECTED_ATTR_SET_NEWLINE);
    }

    function test_SetTraitWithTabInValue() public pure {
        bytes memory EXPECTED_ATTR_SET_TAB = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"Value\\tWith\\tTabs"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("age", bytes("Value\tWith\tTabs"));

        assertEq(newAttributes, EXPECTED_ATTR_SET_TAB);
    }

    function test_SetTraitWhenAttributesFieldIsMissing() public pure {
        bytes memory tokenDataWithoutAttributes = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/image.png","royalties":[{"address":"address","percent":"5"}]}'
        );

        // Since attributes field is missing, we expect the original token data to remain unchanged
        bytes memory expectedTokenData = tokenDataWithoutAttributes;

        bytes memory newTokenData = tokenDataWithoutAttributes.setTrait("age", "33");

        assertEq(newTokenData, expectedTokenData);
    }

    function test_SetTraitWhenTokenDataIsEmpty() public pure {
        bytes memory emptyTokenData = bytes("");

        // Since token data is empty, we expect the original token data to remain unchanged
        bytes memory expectedTokenData = emptyTokenData;

        bytes memory newTokenData = emptyTokenData.setTrait("age", "33");

        assertEq(newTokenData, expectedTokenData);
    }

    function test_SetTraitWithEmptyTraitType() public pure {
        bytes memory EXPECTED_ATTR_SET_EMPTY_TRAIT_TYPE = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"","value":"SomeValue"},{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
        bytes memory newAttributes = tokenData.setTrait("", "SomeValue");

        assertEq(newAttributes, EXPECTED_ATTR_SET_EMPTY_TRAIT_TYPE);
    }

    function test_SetMultipleTraits() public pure {
        bytes memory EXPECTED_ATTR_SET_MULTIPLE = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"nickname","value":"Wonderland"},{"trait_type":"age","value":"30"},{"trait_type":"power","value":"50"},{"trait_type":"name","value":"Alice"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newTokenData = tokenData;

        newTokenData = newTokenData.setTrait("age", "30");
        newTokenData = newTokenData.setTrait("power", "50");
        newTokenData = newTokenData.setTrait("name", "Alice");
        newTokenData = newTokenData.setTrait("nickname", "Wonderland");

        assertEq(newTokenData, EXPECTED_ATTR_SET_MULTIPLE);
    }

    function test_SetTraitWithUnicodeCharacters() public pure {
        // Unicode characters in trait_type and value
        bytes memory unicodeTraitType = bytes(unicode"名字");
        bytes memory unicodeValue = bytes(unicode"测试");

        bytes memory EXPECTED_ATTR_SET_UNICODE = bytes(
            unicode'{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"名字","value":"测试"},{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newAttributes = tokenData.setTrait(unicodeTraitType, unicodeValue);

        assertEq(newAttributes, EXPECTED_ATTR_SET_UNICODE);
    }

    function test_SetTraitWhenMultipleSameTraitTypesExist() public pure {
        // Token data with duplicate trait_types
        bytes memory tokenDataWithDuplicates = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"age","value":"15"}]}'
        );

        // We attempt to set "age" to "33"; the function should replace the first occurrence
        bytes memory EXPECTED_ATTR_SET_DUPLICATE = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"33"},{"trait_type":"power","value":"10"},{"trait_type":"age","value":"15"}]}'
        );

        bytes memory newTokenData = tokenDataWithDuplicates.setTrait("age", "33");

        assertEq(newTokenData, EXPECTED_ATTR_SET_DUPLICATE);
    }

    function test_SetTraitWhenAttributesIsNotArray() public pure {
        // Token data where attributes is a string, not an array
        bytes memory tokenDataWithInvalidAttributes = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":{"trait_type":"age","value":"18"}}'
        );

        // Since attributes is not an array, we expect the original token data to remain unchanged
        bytes memory expectedTokenData = tokenDataWithInvalidAttributes;

        bytes memory newTokenData = tokenDataWithInvalidAttributes.setTrait("age", "33");

        assertEq(newTokenData, expectedTokenData);
    }
}
