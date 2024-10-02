// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <=0.8.24;

/**
 * @title BytesUtils
 * @dev Library for common byte array operations used in manipulating strings and bytes.
 */
library BytesUtils {
    /**
     * @notice Searches for the first occurrence of `needle` within `haystack`, starting from the `start` index.
     * @dev It returns -1 if the `needle` is not found in the `haystack` after the `start` index.
     * @param haystack The byte array to search within.
     * @param needle The byte array to search for.
     * @param start The index within `haystack` to start searching from.
     * @return index The index of the first occurrence of `needle` within `haystack` after `start`, or -1 if not found.
     */
    function indexOfFrom(
        bytes memory haystack,
        bytes memory needle,
        uint256 start
    ) internal pure returns (int256 index) {
        assembly {
            let hlen := mload(haystack)
            let nlen := mload(needle)
            let ptr := add(add(haystack, 32), start)
            let nptr := add(needle, 32)

            index := not(0) // Initialize to -1

            if iszero(gt(add(nlen, start), hlen)) {
                let end := add(add(haystack, 32), sub(hlen, nlen))
                end := add(end, 1) // Adjust end to be inclusive

                for {

                } lt(ptr, end) {
                    ptr := add(ptr, 1)
                } {
                    if eq(keccak256(ptr, nlen), keccak256(nptr, nlen)) {
                        index := sub(ptr, add(haystack, 32))
                        // Break out of the loop
                        ptr := end
                    }
                }
            }
        }
    }

    /**
     * @notice Escapes special characters in a JSON string according to JSON encoding rules.
     * @dev Special characters such as quotes, backslashes, and control characters are escaped.
     * @param input The byte array representing the string to escape.
     * @return The escaped string as a byte array.
     */
    function escapeString(bytes memory input) internal pure returns (bytes memory) {
        uint256 length = input.length;
        if (length == 0) {
            return input;
        }

        // Maximum possible length is length * 6 (worst case)
        uint256 maxLength = length * 6;
        bytes memory escaped = new bytes(maxLength);

        uint256 j = 0;

        for (uint256 i = 0; i < length; i++) {
            bytes1 char = input[i];

            if (char == '"' || char == "\\") {
                escaped[j++] = "\\";
                escaped[j++] = char;
            } else if (char == bytes1(uint8(8))) {
                escaped[j++] = "\\";
                escaped[j++] = "b";
            } else if (char == bytes1(uint8(12))) {
                escaped[j++] = "\\";
                escaped[j++] = "f";
            } else if (char == bytes1(uint8(10))) {
                escaped[j++] = "\\";
                escaped[j++] = "n";
            } else if (char == bytes1(uint8(13))) {
                escaped[j++] = "\\";
                escaped[j++] = "r";
            } else if (char == bytes1(uint8(9))) {
                escaped[j++] = "\\";
                escaped[j++] = "t";
            } else if (uint8(char) < 0x20) {
                // Escape control characters as \u00XX
                escaped[j++] = "\\";
                escaped[j++] = "u";
                escaped[j++] = "0";
                escaped[j++] = "0";

                uint8 code = uint8(char);
                bytes1 hex1 = hexChar(uint8(code) >> 4);
                bytes1 hex2 = hexChar(uint8(code) & 0x0F);

                escaped[j++] = hex1;
                escaped[j++] = hex2;
            } else {
                escaped[j++] = char;
            }
        }

        // Adjust the length of the escaped bytes array to the actual length
        assembly {
            mstore(escaped, j)
        }

        return escaped;
    }

    /**
     * @notice Converts a nibble (4 bits) to its ASCII hexadecimal character representation.
     * @dev Used internally by `escapeString` to convert control characters to their hex representation.
     *      For example, nibble 10 becomes 'a', nibble 15 becomes 'f'.
     * @param nibble The nibble to convert (value between 0 and 15).
     * @return The ASCII character representing the hexadecimal value of the nibble.
     */
    function hexChar(uint8 nibble) internal pure returns (bytes1) {
        if (nibble < 10) {
            return bytes1(nibble + 48); // ASCII '0' = 48
        } else {
            return bytes1(nibble + 87); // ASCII 'a' = 97
        }
    }

    /**
     * @notice Copies `len` bytes from memory address `src` to memory address `dest`.
     * @dev The memory regions should not overlap.
     *      It copies word-sized chunks (32 bytes) where possible, and handles remaining bytes at the end.
     * @param dest The destination memory address where bytes will be copied to.
     * @param src The source memory address where bytes will be copied from.
     * @param len The number of bytes to copy from `src` to `dest`.
     */
    function memcpy(uint256 dest, uint256 src, uint256 len) internal pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
        // Copy remaining bytes
        if (len > 0) {
            uint256 mask = 256 ** (32 - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
}
