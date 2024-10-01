// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <=0.8.24;

library Converter {
    function str2uint(string memory _a) internal pure returns (uint256) {
        bytes memory bresult = bytes(_a);
        uint256 result = 0;
        for (uint256 i = 0; i < bresult.length; i++) {
            uint8 digit = uint8(bresult[i]) - 48;
            require(digit <= 9, "Invalid character in string");
            result = result * 10 + digit;
        }
        return result;
    }

    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 temp = _i;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_i != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_i % 10)));
            _i /= 10;
        }
        return string(buffer);
    }

    function uint2bytes(uint256 i) internal pure returns (bytes memory) {
        return bytes(uint2str(i));
    }
}
