// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../contracts/libraries/utils/TokenDataUtils.sol";

contract RemoveTraitTest is Test {
    using TokenDataUtils for *;

    bytes constant attributes =
        bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

    function test_RemoveTraitFromTheBeginning() public pure {
        bytes memory newAttributes = attributes.removeTrait("age");

        assertEq(
            newAttributes,
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"power","value":"10"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
    }

    function test_RemoveTraitFromTheMiddle() public pure {
        bytes memory newAttributes = attributes.removeTrait("power");

        assertEq(
            newAttributes,
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
    }

    function test_RemoveTraitFromTheEnd() public pure {
        bytes memory newAttributes = attributes.removeTrait("name");

        assertEq(
            newAttributes,
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"power","value":"10"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );
    }

    function test_RemoveNonExistingTrait() public pure {
        bytes memory newAttributes = attributes.removeTrait("nonexistent");

        assertEq(newAttributes, attributes);
    }

    function test_RemoveOnlyTrait() public pure {
        bytes memory attributesWithSingleTrait = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory EXPECTED_EMPTY_ATTRIBUTES = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newAttributes = attributesWithSingleTrait.removeTrait("age");

        assertEq(newAttributes, EXPECTED_EMPTY_ATTRIBUTES);
    }

    function test_RemoveTraitFromEmptyAttributes() public pure {
        bytes memory emptyAttributes = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/image.png","attributes":[],"royalties":[{"address":"someaddress","percent":"5"}]}'
        );

        bytes memory newAttributes = emptyAttributes.removeTrait("age");

        // Expect the attributes to remain unchanged since there's nothing to remove
        assertEq(newAttributes, emptyAttributes);
    }

    function test_RemoveTraitWithDuplicateTraitTypes() public pure {
        bytes memory attributesWithDuplicates = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"age","value":"15"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"15"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newAttributes = attributesWithDuplicates.removeTrait("age");

        // Expect that only the first occurrence of "age" is removed
        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }

    function test_RemoveTraitWithSpecialCharactersInValue() public pure {
        bytes memory attributesWithSpecialTrait = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"nickname","value":"He said \\"Hello\\""},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory EXPECTED_ATTRIBUTES_AFTER_REMOVAL = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newAttributes = attributesWithSpecialTrait.removeTrait("nickname");

        assertEq(newAttributes, EXPECTED_ATTRIBUTES_AFTER_REMOVAL);
    }

    function test_RemoveTraitWithSpecialCharactersInTraitType() public pure {
        bytes memory attributesWithSpecialTraitType = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"spe\\cial"trait","value":"special value"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"name","value":"John"}]}'
        );

        // Note: The trait_type contains special characters like backslash and double quotes
        bytes memory newAttributes = attributesWithSpecialTraitType.removeTrait('spe\\cial"trait');

        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }

    function test_RemoveTraitWhenAttributesArrayIsMissing() public pure {
        bytes memory attributesWithoutAttributesArray = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/image.png","royalties":[{"address":"someaddress","percent":"5"}]}'
        );

        bytes memory newAttributes = attributesWithoutAttributesArray.removeTrait("age");

        // Expect the original attributes since there is no attributes array
        assertEq(newAttributes, attributesWithoutAttributesArray);
    }

    function test_RemoveTraitWhenTraitTypeIsSubstringOfAnotherTraitType() public pure {
        bytes memory attributesWithSimilarTraitTypes = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age_group","value":"adult"},{"trait_type":"age","value":"12"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age_group","value":"adult"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newAttributes = attributesWithSimilarTraitTypes.removeTrait("age");

        // Ensure that only the "age" trait is removed, not "age_group"
        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }

    function test_RemoveTraitWhenTraitTypeIsNestedInValue() public pure {
        bytes memory attributesWithTraitTypeInValue = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"description","value":"age is just a number"},{"trait_type":"age","value":"30"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"description","value":"age is just a number"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newAttributes = attributesWithTraitTypeInValue.removeTrait("age");

        // Ensure that only the trait with "trait_type":"age" is removed, not where "age" is in the value
        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }

    function test_RemoveTraitWithEmptyTraitType() public pure {
        bytes memory attributesWithEmptyTraitType = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"","value":"empty trait type"},{"trait_type":"name","value":"John"}]}'
        );

        bytes memory expectedAttributesAfterRemoval = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newAttributes = attributesWithEmptyTraitType.removeTrait("");

        assertEq(newAttributes, expectedAttributesAfterRemoval);
    }

    function test_RemoveTraitWithTraitTypeImage() public pure {
        bytes memory attributesWithImageTrait = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"image","value":"http://localhost"},{"trait_type":"name","value":"John"}]}'
        );

        // we check that removed trait, not image outside the attributes
        bytes memory newAttributes = attributesWithImageTrait.removeTrait("image");

        assertEq(
            newAttributes,
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"name","value":"John"}]}'
        );
    }
}
