// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../contracts/libraries/TokenDataUtils.sol";

contract SetTokenDataTest is Test {
    using TokenDataUtils for *;

    function test_SetTokenImage_AddNew_SimpleURL() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"12"}]}'
        );

        bytes memory newImage = bytes("https://example.com/image.png");

        bytes memory expectedMetadata = bytes(
            '{"image":"https://example.com/image.png","schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"age","value":"12"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_AddNew_URLWithQueryParams() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"power","value":"10"}]}'
        );

        bytes memory newImage = bytes("https://example.com/image.png?size=large&format=webp");

        bytes memory expectedMetadata = bytes(
            '{"image":"https://example.com/image.png?size=large&format=webp","schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"power","value":"10"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_AddNew_URLWithSpecialCharacters() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newImage = bytes("https://example.com/image name@123.png");

        bytes memory expectedMetadata = bytes(
            '{"image":"https://example.com/image name@123.png","schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"name","value":"John"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_AddNew_URLWithEscapedCharacters() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"rarity","value":"legendary"}]}'
        );

        bytes memory newImage = bytes("https://example.com/image%20with%20spaces.png");

        bytes memory expectedMetadata = bytes(
            '{"image":"https://example.com/image%20with%20spaces.png","schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"rarity","value":"legendary"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_AddNew_URLWithUnicodeCharacters() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"category","value":"art"}]}'
        );

        bytes memory newImage = bytes(unicode"https://例子.测试/图片.png");

        bytes memory expectedMetadata = bytes(
            unicode'{"image":"https://例子.测试/图片.png","schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"category","value":"art"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_AddNew_URLWithFragment() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"level","value":"5"}]}'
        );

        bytes memory newImage = bytes("https://example.com/image.png#section");

        bytes memory expectedMetadata = bytes(
            '{"image":"https://example.com/image.png#section","schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"level","value":"5"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_AddNew_URLWithPortNumber() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"edition","value":"first"}]}'
        );

        bytes memory newImage = bytes("https://example.com:8080/image.png");

        bytes memory expectedMetadata = bytes(
            '{"image":"https://example.com:8080/image.png","schemaName":"unique","schemaVersion":"2.0.0","attributes":[{"trait_type":"edition","value":"first"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_AddNew_DataURL() public pure {
        bytes memory metadata = bytes('{"schemaName":"unique","schemaVersion":"2.0.0","attributes":[]}');

        bytes memory newImage = bytes("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA");

        bytes memory expectedMetadata = bytes(
            '{"image":"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA","schemaName":"unique","schemaVersion":"2.0.0","attributes":[]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    ///////// UPDATE IMAGE ///////////

    function test_SetTokenImage_UpdateExisting_SimpleURL() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/old-image.png","attributes":[{"trait_type":"age","value":"12"}]}'
        );

        bytes memory newImage = bytes("https://example.com/new-image.png");

        bytes memory expectedMetadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/new-image.png","attributes":[{"trait_type":"age","value":"12"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_UpdateExisting_URLWithQueryParams() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/old-image.png?version=1","attributes":[{"trait_type":"power","value":"10"}]}'
        );

        bytes memory newImage = bytes("https://example.com/new-image.png?size=large&format=webp");

        bytes memory expectedMetadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/new-image.png?size=large&format=webp","attributes":[{"trait_type":"power","value":"10"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_UpdateExisting_URLWithSpecialCharacters() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/old image@123.png","attributes":[{"trait_type":"name","value":"John"}]}'
        );

        bytes memory newImage = bytes("https://example.com/new image@456.png");

        bytes memory expectedMetadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/new image@456.png","attributes":[{"trait_type":"name","value":"John"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_UpdateExisting_URLWithEscapedCharacters() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/old%20image.png","attributes":[{"trait_type":"rarity","value":"legendary"}]}'
        );

        bytes memory newImage = bytes("https://example.com/new%20image.png");

        bytes memory expectedMetadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/new%20image.png","attributes":[{"trait_type":"rarity","value":"legendary"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_UpdateExisting_URLWithUnicodeCharacters() public pure {
        bytes memory metadata = bytes(
            unicode'{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://例子.测试/旧图片.png","attributes":[{"trait_type":"category","value":"art"}]}'
        );

        bytes memory newImage = bytes(unicode"https://例子.测试/新图片.png");

        bytes memory expectedMetadata = bytes(
            unicode'{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://例子.测试/新图片.png","attributes":[{"trait_type":"category","value":"art"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_UpdateExisting_URLWithFragment() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/old-image.png#oldsection","attributes":[{"trait_type":"level","value":"5"}]}'
        );

        bytes memory newImage = bytes("https://example.com/new-image.png#newsection");

        bytes memory expectedMetadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com/new-image.png#newsection","attributes":[{"trait_type":"level","value":"5"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_UpdateExisting_URLWithPortNumber() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com:8080/old-image.png","attributes":[{"trait_type":"edition","value":"first"}]}'
        );

        bytes memory newImage = bytes("https://example.com:9090/new-image.png");

        bytes memory expectedMetadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"https://example.com:9090/new-image.png","attributes":[{"trait_type":"edition","value":"first"}]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_UpdateExisting_DataURL() public pure {
        bytes memory metadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"data:image/png;base64,oldData","attributes":[]}'
        );

        bytes memory newImage = bytes("data:image/png;base64,newData");

        bytes memory expectedMetadata = bytes(
            '{"schemaName":"unique","schemaVersion":"2.0.0","image":"data:image/png;base64,newData","attributes":[]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }

    function test_SetTokenImage_IfTraitImageExists() public pure {
        bytes memory metadata = bytes(
            '{"attributes":[{"trait_type":"image","value":"http://img.com/img.png"}]},"schemaName":"unique","schemaVersion":"2.0.0","image":"http://old.image.png","attributes":[]}'
        );

        bytes memory newImage = bytes("http://new.image.png");

        bytes memory expectedMetadata = bytes(
            '{"attributes":[{"trait_type":"image","value":"http://img.com/img.png"}]},"schemaName":"unique","schemaVersion":"2.0.0","image":"http://new.image.png","attributes":[]}'
        );

        bytes memory updatedMetadata = metadata.setTokenImage(newImage);

        assertEq(updatedMetadata, expectedMetadata);
    }
}
