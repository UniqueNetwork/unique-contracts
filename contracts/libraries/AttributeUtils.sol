// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library AttributeUtils {
    bytes private constant ATTRIBUTES_PATTERN = '"attributes":[';
    bytes private constant VALUE_PATTERN = '"value":"';

    function dangerSetTraitValue(
        bytes memory _strBytes,
        bytes memory _trait_type,
        bytes memory _value
    ) public pure returns (bytes memory) {
        int256 indexOfAttributes = _indexOfFrom(_strBytes, ATTRIBUTES_PATTERN, 0);
        if (indexOfAttributes == -1) return _strBytes;

        bytes memory traitTypePattern = abi.encodePacked(bytes('"trait_type":"'), _trait_type, bytes('"'));
        int256 index = _indexOfFrom(_strBytes, traitTypePattern, uint256(indexOfAttributes));

        if (index >= 0) {
            // Trait exists, replace the value
            uint256 traitIndex = uint256(index);

            // Find the index of '"value":"' after trait_type
            int256 valueIndex = _indexOfFrom(_strBytes, VALUE_PATTERN, traitIndex);

            if (valueIndex == -1) return _strBytes;

            uint256 valueStart = uint256(valueIndex) + VALUE_PATTERN.length;
            uint256 valueEnd = valueStart;
            while (valueEnd < _strBytes.length && _strBytes[valueEnd] != '"') {
                unchecked {
                    valueEnd++;
                }
            }

            // Escape _value
            bytes memory escapedValue = _escapeString(_value);

            // Calculate new length
            uint256 newLength = _strBytes.length - (valueEnd - valueStart) + escapedValue.length;
            bytes memory newStrBytes = new bytes(newLength);

            uint256 dest;
            uint256 src;
            uint256 len;

            assembly {
                dest := add(newStrBytes, 32)
                src := add(_strBytes, 32)
            }

            // Copy the first part
            len = valueStart;
            _memcpy(dest, src, len);
            dest += len;

            // Copy the escapedValue
            assembly {
                src := add(escapedValue, 32)
                len := mload(escapedValue)
            }
            _memcpy(dest, src, len);
            dest += len;

            // Copy the rest
            uint256 restLen = _strBytes.length - valueEnd;
            assembly {
                src := add(add(_strBytes, 32), valueEnd)
            }
            _memcpy(dest, src, restLen);

            return newStrBytes;
        } else {
            uint256 startAttributesIndex = uint256(indexOfAttributes) + ATTRIBUTES_PATTERN.length;
            string memory endOfNewTrait = _strBytes[startAttributesIndex] == "]" ? '"}' : '"},';

            bytes memory escapedTraitType = _escapeString(_trait_type);
            bytes memory escapedValue = _escapeString(_value);

            // Trait does not exist, add new trait
            bytes memory newTrait = abi.encodePacked(
                '{"trait_type":"',
                escapedTraitType,
                '","value":"',
                escapedValue,
                endOfNewTrait
            );

            // Calculate new length
            uint256 newLength = _strBytes.length + newTrait.length;
            bytes memory newStrBytes = new bytes(newLength);

            uint256 dest;
            uint256 src;
            uint256 len;

            assembly {
                dest := add(newStrBytes, 32)
                src := add(_strBytes, 32)
            }

            // Copy the first part
            len = startAttributesIndex;
            _memcpy(dest, src, len);
            dest += len;

            // Copy newTrait
            assembly {
                src := add(newTrait, 32)
                len := mload(newTrait)
            }
            _memcpy(dest, src, len);
            dest += len;

            // Copy the rest
            uint256 restLen = _strBytes.length - startAttributesIndex;
            assembly {
                src := add(add(_strBytes, 32), startAttributesIndex)
            }
            _memcpy(dest, src, restLen);

            return newStrBytes;
        }
    }

    function dangerRemoveTrait(bytes memory _strBytes, bytes memory _trait_type) public pure returns (bytes memory) {
        bytes memory traitTypePattern = abi.encodePacked(bytes('"trait_type":"'), _trait_type, bytes('"'));
        int256 index = _indexOfFrom(_strBytes, traitTypePattern, 0);

        if (index >= 0) {
            uint256 objectStart = uint256(index);

            // Find the start of the trait object '{'
            while (_strBytes[objectStart - 1] != "{") {
                objectStart--;
            }
            objectStart--; // Include the '{'

            // Find the end of the trait object '}'
            uint256 objectEnd = uint256(index);

            uint256 strBytesLength = _strBytes.length;

            unchecked {
                while (objectEnd < strBytesLength && _strBytes[objectEnd] != "}") {
                    objectEnd++;
                }
                objectEnd++; // Include the '}'
            }

            uint256 removeStart = objectStart;
            uint256 removeEnd = objectEnd;

            // Decide whether to remove the comma before or after
            if (removeEnd < strBytesLength && _strBytes[removeEnd] == ",") {
                unchecked {
                    removeEnd++;
                } // Include the comma after
            } else if (removeStart > 0 && _strBytes[removeStart - 1] == ",") {
                unchecked {
                    removeStart--; // Include the comma before
                }
            }

            // Handle the case when the array becomes empty
            uint256 arrayStart = 0;
            if (_strBytes[0] == "[") {
                arrayStart = 1;
            }
            uint256 arrayEnd = strBytesLength;
            if (_strBytes[strBytesLength - 1] == "]") {
                arrayEnd = strBytesLength - 1;
            }

            bool isOnlyTrait = (removeStart <= arrayStart) && (removeEnd >= arrayEnd);

            bytes memory newStrBytes;

            if (isOnlyTrait) {
                // Return empty array
                newStrBytes = "[]";
            } else {
                // Construct new bytes
                uint256 newLength = strBytesLength - (removeEnd - removeStart);
                newStrBytes = new bytes(newLength);

                // Copy up to removeStart
                {
                    uint256 destPtr;
                    uint256 srcPtr;
                    assembly {
                        destPtr := add(newStrBytes, 32)
                        srcPtr := add(_strBytes, 32)
                    }
                    uint256 len = removeStart;
                    _memcpy(destPtr, srcPtr, len);
                }

                // Copy after removeEnd
                {
                    uint256 destPtr;
                    uint256 srcPtr;
                    assembly {
                        destPtr := add(add(newStrBytes, 32), removeStart)
                        srcPtr := add(add(_strBytes, 32), removeEnd)
                    }
                    uint256 len = strBytesLength - removeEnd;
                    _memcpy(destPtr, srcPtr, len);
                }
            }

            return newStrBytes;
        } else {
            // Trait does not exist
            return _strBytes;
        }
    }

    function _indexOfFrom(
        bytes memory haystack,
        bytes memory needle,
        uint256 start
    ) private pure returns (int256 index) {
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

    function _escapeString(bytes memory input) private pure returns (bytes memory) {
        unchecked {
            uint256 length = input.length;
            uint256 extraBytes = 0;
            for (uint256 i = 0; i < length; i++) {
                if (input[i] == '"' || input[i] == "\\") {
                    extraBytes++;
                }
            }
            bytes memory output = new bytes(length + extraBytes);
            uint256 j = 0;
            for (uint256 i = 0; i < length; i++) {
                if (input[i] == '"' || input[i] == "\\") {
                    output[j++] = "\\";
                }
                output[j++] = input[i];
            }

            return output;
        }
    }

    function _memcpy(uint dest, uint src, uint len) private pure {
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
            uint mask = 256 ** (32 - len) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }
    }
}
