// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../contracts/test/Test__AttributesManager.sol";

contract RemoveTraitTest is Test {
    Test__AttributesManager attributesManager;
    bytes constant attributes2 =
        bytes(
            '{"trait_type":"age","value":"5"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}'
        );

    bytes constant attributes =
        bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

    function setUp() public {
        attributesManager = new Test__AttributesManager();
    }

    function test_RemoveTraitFromTheBeginning() public view {
        bytes memory newAttributes = attributesManager.removeTrait(attributes, "age");

        assertEq(
            newAttributes,
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
    }

    function test_RemoveTraitFromTheMiddle() public view {
        bytes memory newAttributes = attributesManager.removeTrait(attributes, "power");

        assertEq(
            newAttributes,
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
    }

    function test_RemoveTraitFromTheEnd() public view {
        bytes memory newAttributes = attributesManager.removeTrait(attributes, "name");

        assertEq(
            newAttributes,
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
    }

    function test_RemoveNonExistingTrait() public view {
        bytes memory newAttributes = attributesManager.removeTrait(attributes, "nonexistent");

        assertEq(newAttributes, attributes);
    }

    function test_RemoveOnlyTrait() public view {
        bytes memory attributesWithSingleTrait = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory EXPECTED_EMPTY_ATTRIBUTES = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newAttributes = attributesManager.removeTrait(attributesWithSingleTrait, "age");

        assertEq(newAttributes, EXPECTED_EMPTY_ATTRIBUTES);
    }

    function test_RemoveTraitFromEmptyAttributes() public view {
        bytes memory emptyAttributes = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/image.png","attributes":[],"royalties":[{"address":"someaddress","percent":"5"}]}'
        );

        bytes memory newAttributes = attributesManager.removeTrait(emptyAttributes, "age");

        // Expect the attributes to remain unchanged since there's nothing to remove
        assertEq(newAttributes, emptyAttributes);
    }

    function test_RemoveTraitWithDuplicateTraitTypes() public view {
        bytes memory attributesWithDuplicates = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"age","value":"15"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"15"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newAttributes = attributesManager.removeTrait(attributesWithDuplicates, "age");

        // Expect that only the first occurrence of "age" is removed
        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }

    function test_RemoveTraitWithSpecialCharactersInValue() public view {
        bytes memory attributesWithSpecialTrait = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"nickname","value":"He said \\"Hello\\""},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory EXPECTED_ATTRIBUTES_AFTER_REMOVAL = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newAttributes = attributesManager.removeTrait(attributesWithSpecialTrait, "nickname");

        assertEq(newAttributes, EXPECTED_ATTRIBUTES_AFTER_REMOVAL);
    }

    function test_RemoveTraitWithSpecialCharactersInTraitType() public view {
        bytes memory attributesWithSpecialTraitType = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"spe\\cial"trait","value":"special value"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"name","value":"John"}]}'
        );

        // Note: The trait_type contains special characters like backslash and double quotes
        bytes memory newAttributes = attributesManager.removeTrait(attributesWithSpecialTraitType, 'spe\\cial"trait');

        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }

    function test_RemoveTraitWhenAttributesArrayIsMissing() public view {
        bytes memory attributesWithoutAttributesArray = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/image.png","royalties":[{"address":"someaddress","percent":"5"}]}'
        );

        bytes memory newAttributes = attributesManager.removeTrait(attributesWithoutAttributesArray, "age");

        // Expect the original attributes since there is no attributes array
        assertEq(newAttributes, attributesWithoutAttributesArray);
    }

    function test_RemoveTraitWhenTraitTypeIsSubstringOfAnotherTraitType() public view {
        bytes memory attributesWithSimilarTraitTypes = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age_group","value":"adult"},{"trait_type":"age","value":"12"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age_group","value":"adult"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newAttributes = attributesManager.removeTrait(attributesWithSimilarTraitTypes, "age");

        // Ensure that only the "age" trait is removed, not "age_group"
        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }

    function test_RemoveTraitWhenTraitTypeIsNestedInValue() public view {
        bytes memory attributesWithTraitTypeInValue = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"description","value":"age is just a number"},{"trait_type":"age","value":"30"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"description","value":"age is just a number"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newAttributes = attributesManager.removeTrait(attributesWithTraitTypeInValue, "age");

        // Ensure that only the trait with "trait_type":"age" is removed, not where "age" is in the value
        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }

    function test_RemoveTraitWithEmptyTraitType() public view {
        bytes memory attributesWithEmptyTraitType = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"","value":"empty trait type"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newAttributes = attributesManager.removeTrait(attributesWithEmptyTraitType, "");

        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }
}
