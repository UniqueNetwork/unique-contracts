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
        int256 indexOfAttributes = _indexOf(_strBytes, ATTRIBUTES_PATTERN);
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

            // Construct new bytes
            bytes memory newStrBytes = new bytes(_strBytes.length - (valueEnd - valueStart) + escapedValue.length);

            uint256 k = 0;

            // Copy up to valueStart
            unchecked {
                for (uint256 i = 0; i < valueStart; i++) {
                    newStrBytes[k++] = _strBytes[i];
                }

                // Insert new value
                for (uint256 i = 0; i < escapedValue.length; i++) {
                    newStrBytes[k++] = escapedValue[i];
                }

                // Copy the rest
                for (uint256 i = valueEnd; i < _strBytes.length; i++) {
                    newStrBytes[k++] = _strBytes[i];
                }
            }

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

            bytes memory newStrBytes = new bytes(_strBytes.length + newTrait.length);

            uint256 k = 0;

            unchecked {
                for (uint256 i = 0; i < startAttributesIndex; i++) {
                    newStrBytes[k++] = _strBytes[i];
                }

                for (uint256 i = 0; i < newTrait.length; i++) {
                    newStrBytes[k++] = newTrait[i];
                }

                for (uint256 i = startAttributesIndex; i < _strBytes.length; i++) {
                    newStrBytes[k++] = _strBytes[i];
                }
            }

            return newStrBytes;
        }
    }

    function dangerRemoveTrait(bytes memory _strBytes, bytes memory _trait_type) public pure returns (bytes memory) {
        bytes memory traitTypePattern = abi.encodePacked(bytes('"trait_type":"'), _trait_type, bytes('"'));
        int256 index = _indexOf(_strBytes, traitTypePattern);

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
                newStrBytes = new bytes(strBytesLength - (removeEnd - removeStart));

                uint256 k = 0;

                unchecked {
                    // Copy up to removeStart
                    for (uint256 i = 0; i < removeStart; i++) {
                        newStrBytes[k++] = _strBytes[i];
                    }

                    // Copy after removeEnd
                    for (uint256 i = removeEnd; i < strBytesLength; i++) {
                        newStrBytes[k++] = _strBytes[i];
                    }
                }
            }

            return newStrBytes;
        } else {
            // Trait does not exist
            return _strBytes;
        }
    }

    function _indexOf(bytes memory haystack, bytes memory needle) private pure returns (int256) {
        uint256 needleLength = needle.length;
        uint256 haystackLength = haystack.length;

        if (needleLength > haystackLength) {
            return -1;
        }

        uint256 searchLimit = haystackLength - needleLength;

        unchecked {
            for (uint256 i = 0; i <= searchLimit; i++) {
                bool matchFound = true;
                for (uint256 j = 0; j < needleLength; j++) {
                    if (haystack[i + j] != needle[j]) {
                        matchFound = false;
                        break;
                    }
                }
                if (matchFound) {
                    return int256(i);
                }
            }
        }

        return -1;
    }

    function _indexOfFrom(bytes memory haystack, bytes memory needle, uint256 start) private pure returns (int256) {
        uint256 needleLength = needle.length;
        uint256 haystackLength = haystack.length;

        unchecked {
            if (needleLength + start > haystackLength) {
                return -1;
            }
        }

        uint256 searchLimit = haystackLength - needleLength;

        unchecked {
            for (uint256 i = start; i <= searchLimit; i++) {
                bool matchFound = true;
                for (uint256 j = 0; j < needleLength; j++) {
                    if (haystack[i + j] != needle[j]) {
                        matchFound = false;
                        break;
                    }
                }
                if (matchFound) {
                    return int256(i);
                }
            }
        }
        return -1;
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
}
