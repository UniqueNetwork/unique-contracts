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

    function test_RemoveTraitWithSpecialCharacters() public view {
        bytes memory attributesWithSpecialTrait = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"nickname","value":"He said \\"Hello\\""},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory EXPECTED_ATTRIBUTES_AFTER_REMOVAL = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://stage-ipfs.unique.network/ipfs/QmaztXF7WjQAUSjpcDc46VBhgcTKa3d9eWiWszq3LVdf3p","attributes":[{"trait_type":"age","value":"12"},{"trait_type":"name","value":"John"}],"royalties":[{"address":"uneiqi1AaN5sP9Gqd476uJckgwwtuqTWbGU2pQ1JgsaDekziT","percent":"5"}]}'
        );

        bytes memory newAttributes = attributesManager.removeTrait(attributesWithSpecialTrait, "nickname");

        assertEq(newAttributes, EXPECTED_ATTRIBUTES_AFTER_REMOVAL);
    }
}
