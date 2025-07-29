// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TokenAddress} from "../../contracts/libraries/TokenAddress.sol";

contract TokenAddressTest is Test {
    using TokenAddress for uint256;

    struct TestCase {
        uint256 collectionId;
        uint256 tokenId;
        address expectedResult;
    }

    function setUp() public {}

    function testGetAddressFromId() public {
        TestCase[30] memory testCases = [
            TestCase(467849, 437615, 0xf8238ccFff8ED887463fD5E0000723890006Ad6f),
            TestCase(629300, 801551, 0xf8238CCfff8ed887463fd5E000099a34000C3B0f),
            TestCase(596073, 182912, 0xF8238ccfFf8ed887463fd5e0000918690002ca80),
            TestCase(119983, 432329, 0xF8238CcFff8ED887463Fd5E00001d4Af000698c9),
            TestCase(859686, 865563, 0xf8238CCFfF8ED887463Fd5e0000d1E26000D351B),
            TestCase(605551, 420201, 0xf8238ccFFf8Ed887463fD5E000093d6F00066969),
            TestCase(440451, 977301, 0xF8238cCffF8Ed887463Fd5e00006b883000Ee995),
            TestCase(543225, 720379, 0xF8238CCfFF8Ed887463fD5e0000849f9000AfDFB),
            TestCase(43436, 76923, 0xf8238cCFFf8ed887463fD5E00000a9ac00012C7B),
            TestCase(598840, 310483, 0xf8238cCfFF8ed887463FD5e0000923380004BCd3),
            TestCase(467411, 167910, 0xF8238cCffF8Ed887463fD5e0000721d300028fe6),
            TestCase(10567, 812253, 0xF8238CCFff8Ed887463fd5e000002947000C64dD),
            TestCase(465294, 16972, 0xf8238CcFFf8ed887463Fd5e00007198E0000424c),
            TestCase(787520, 312313, 0xf8238CcfFf8ED887463Fd5e0000C04400004c3f9),
            TestCase(18071, 156537, 0xF8238cCfff8Ed887463FD5e00000469700026379),
            TestCase(248075, 196114, 0xF8238ccFFf8ED887463fD5e00003C90B0002FE12),
            TestCase(100579, 93412, 0xF8238ccfff8Ed887463FD5E0000188E300016Ce4),
            TestCase(406074, 257917, 0xf8238CcFFF8Ed887463fd5E00006323A0003Ef7D),
            TestCase(109021, 421857, 0xf8238cCfFf8eD887463fD5e00001A9dd00066fE1),
            TestCase(313061, 930808, 0xf8238CCFff8ED887463fd5E00004C6E5000E33f8),
            TestCase(966912, 438882, 0xF8238cCfFf8eD887463fd5e0000EC1000006b262),
            TestCase(826204, 113400, 0xF8238CcfFF8ED887463FD5e0000c9B5c0001bAF8),
            TestCase(795073, 245173, 0xF8238CcFFF8ed887463fD5e0000C21C10003Bdb5),
            TestCase(298964, 375307, 0xF8238cCFFf8eD887463Fd5e000048fd40005ba0b),
            TestCase(997667, 503629, 0xF8238cCfFf8eD887463FD5E0000F39230007Af4d),
            TestCase(574522, 567857, 0xf8238cCFFF8ed887463fd5e00008c43a0008aa31),
            TestCase(504444, 328201, 0xf8238CcFfF8eD887463fd5e00007B27C00050209),
            TestCase(503660, 652158, 0xf8238ccFff8eD887463Fd5e00007af6c0009F37E),
            TestCase(432131, 897759, 0xF8238CCFff8eD887463fd5E000069803000DB2Df),
            TestCase(460003, 312902, 0xF8238CcFFF8Ed887463fD5e0000704e30004C646)
        ];

        for (uint256 i = 0; i < testCases.length; i++) {
            TestCase memory testCase = testCases[i];
            address result = TokenAddress.fromId(testCase.collectionId, testCase.tokenId);

            assertEq(
                result,
                testCase.expectedResult,
                string(
                    abi.encodePacked(
                        "Test case ",
                        vm.toString(i),
                        " failed: collectionId=",
                        vm.toString(testCase.collectionId),
                        ", tokenId=",
                        vm.toString(testCase.tokenId)
                    )
                )
            );
        }
    }

    function testGasUsage() public {
        uint256 gasBefore = gasleft();
        TokenAddress.fromId(467849, 437615);
        uint256 gasUsed = gasBefore - gasleft();

        assertTrue(gasUsed < 1000, "Function should use minimal gas");
    }
}
