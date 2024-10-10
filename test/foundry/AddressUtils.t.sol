// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../../contracts/libraries/AddressUtils.sol";

contract AddressUtilsTest is Test {
    using AddressUtils for *;

    AddressUtilsExposed addressUtils;

    // Alice: 5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY
    // 95984986718144069210823521919159854647677841531438818243411586941956215644797
    address aliceEth = 0xd43593c715Fdd31c61141ABd04a99FD6822c8558;
    address random = makeAddr("random");
    uint256 aliceSub = 95984986718144069210823521919159854647677841531438818243411586941956215644797;

    CrossAddress aliceEthCross = CrossAddress({eth: aliceEth, sub: 0});
    CrossAddress aliceSubCross = CrossAddress({eth: address(0), sub: aliceSub});

    function setUp() public {
        addressUtils = new AddressUtilsExposed();
    }

    function test_ValidCrossAddressEth() public view {
        assertTrue(aliceEthCross.isValid());
    }

    function test_ValidCrossAddressSub() public view {
        assertTrue(aliceSubCross.isValid());
    }

    function test_NonValidCrossAddressFilledBoth() public view {
        assertFalse(CrossAddress({eth: aliceEth, sub: aliceSub}).isValid());
    }

    function test_NonValidCrossAddressEmptyBoth() public pure {
        assertFalse(CrossAddress({eth: address(0), sub: 0}).isValid());
    }

    function test_CrossAddressEthIsMsgSender() public {
        vm.prank(aliceEth);
        assertTrue(addressUtils.isMessageSender(aliceEthCross));
    }

    function test_CrossAddressSubIsMsgSender() public {
        vm.prank(aliceEth);
        assertTrue(addressUtils.isMessageSender(aliceSubCross));
    }

    function test_CrossAddressEthIsNotMsgSender() public {
        vm.prank(random);
        assertFalse(addressUtils.isMessageSender(aliceEthCross));
    }

    function test_CrossAddressSubIsNotMsgSender() public {
        vm.prank(random);
        assertFalse(addressUtils.isMessageSender(aliceSubCross));
    }

    function test_NonValidCrossAddressIsNotMsgSender() public {
        vm.prank(aliceEth);
        assertFalse(addressUtils.isMessageSender(CrossAddress({eth: aliceEth, sub: aliceSub})));
    }

    function test_ConverSubstratePubkeyToAddress() public view {
        assertTrue(addressUtils.substratePublicKeyToAddress(aliceSub) == aliceEth);
    }
}

contract AddressUtilsExposed {
    using AddressUtils for *;

    function isValid(CrossAddress memory _crossAddress) public pure returns (bool) {
        return _crossAddress.isValid();
    }

    function isMessageSender(CrossAddress memory _crossAddress) public view returns (bool) {
        return _crossAddress.isMessageSender();
    }

    function substratePublicKeyToAddress(uint256 _pubkey) public pure returns (address) {
        return AddressUtils.substratePublicKeyToAddress(_pubkey);
    }
}
