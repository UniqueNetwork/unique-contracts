// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library AttributeUtils {
    function dangerSetTraitValue(
        bytes memory _strBytes,
        bytes memory _trait_type,
        bytes memory _value
    ) public pure returns (bytes memory) {
        bytes memory attributesPattern = abi.encodePacked(bytes('"attributes":['));
        int256 indexOfAttributes = _indexOf(_strBytes, attributesPattern);
        // TODO if indexOfAttributes == -1;

        bytes memory traitTypePattern = abi.encodePacked(bytes('"trait_type":"'), _trait_type, bytes('"'));
        int256 index = _indexOfFrom(_strBytes, traitTypePattern, uint256(indexOfAttributes));

        if (index >= 0) {
            // Trait exists, replace the value
            uint256 traitIndex = uint256(index);

            // Find the index of '"value":"' after trait_type
            bytes memory valuePattern = bytes('"value":"');
            int256 valueIndex = _indexOfFrom(_strBytes, valuePattern, traitIndex);

            if (valueIndex >= 0) {
                uint256 valueStart = uint256(valueIndex) + valuePattern.length;
                uint256 valueEnd = valueStart;
                while (valueEnd < _strBytes.length && _strBytes[valueEnd] != '"') {
                    valueEnd++;
                }

                // Construct new bytes
                bytes memory newStrBytes = new bytes(_strBytes.length - (valueEnd - valueStart) + _value.length);

                uint256 k = 0;

                // Copy up to valueStart
                for (uint256 i = 0; i < valueStart; i++) {
                    newStrBytes[k++] = _strBytes[i];
                }

                // Insert new value
                for (uint256 i = 0; i < _value.length; i++) {
                    newStrBytes[k++] = _value[i];
                }

                // Copy the rest
                for (uint256 i = valueEnd; i < _strBytes.length; i++) {
                    newStrBytes[k++] = _strBytes[i];
                }

                return newStrBytes;
            } else {
                // "value":" not found after trait_type
                return _strBytes;
            }
        } else {
            uint256 startAttributesIndex = uint256(indexOfAttributes) + attributesPattern.length;
            string memory endOfNewTrait = _strBytes[startAttributesIndex] == "]" ? '"}' : '"},';

            // Trait does not exist, add new trait
            bytes memory newTrait = abi.encodePacked(
                bytes('{"trait_type":"'),
                _trait_type,
                bytes('","value":"'),
                _value,
                bytes(endOfNewTrait)
            );

            // TODO: add , or not
            bytes memory newStrBytes = new bytes(_strBytes.length + newTrait.length);

            uint256 k = 0;

            for (uint256 i = 0; i < startAttributesIndex; i++) {
                newStrBytes[k++] = _strBytes[i];
            }

            for (uint256 i = 0; i < newTrait.length; i++) {
                newStrBytes[k++] = newTrait[i];
            }

            for (uint256 i = startAttributesIndex; i < _strBytes.length; i++) {
                newStrBytes[k++] = _strBytes[i];
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
            while (objectStart > 0 && _strBytes[objectStart - 1] != "{") {
                objectStart--;
            }
            objectStart--; // Include the '{'

            // Find the end of the trait object '}'
            uint256 objectEnd = uint256(index);
            while (objectEnd < _strBytes.length && _strBytes[objectEnd] != "}") {
                objectEnd++;
            }
            objectEnd++; // Include the '}'

            uint256 removeStart = objectStart;
            uint256 removeEnd = objectEnd;

            // Decide whether to remove the comma before or after
            if (removeEnd < _strBytes.length && _strBytes[removeEnd] == ",") {
                removeEnd++; // Include the comma after
            } else if (removeStart > 0 && _strBytes[removeStart - 1] == ",") {
                removeStart--; // Include the comma before
            }

            // Handle the case when the array becomes empty
            uint256 arrayStart = 0;
            if (_strBytes[0] == "[") {
                arrayStart = 1;
            }
            uint256 arrayEnd = _strBytes.length;
            if (_strBytes[_strBytes.length - 1] == "]") {
                arrayEnd = _strBytes.length - 1;
            }

            bool isOnlyTrait = (removeStart <= arrayStart) && (removeEnd >= arrayEnd);

            bytes memory newStrBytes;

            if (isOnlyTrait) {
                // Return empty array
                newStrBytes = abi.encodePacked(bytes("[]"));
            } else {
                // Construct new bytes
                newStrBytes = new bytes(_strBytes.length - (removeEnd - removeStart));

                uint256 k = 0;

                // Copy up to removeStart
                for (uint256 i = 0; i < removeStart; i++) {
                    newStrBytes[k++] = _strBytes[i];
                }

                // Copy after removeEnd
                for (uint256 i = removeEnd; i < _strBytes.length; i++) {
                    newStrBytes[k++] = _strBytes[i];
                }
            }

            return newStrBytes;
        } else {
            // Trait does not exist
            return _strBytes;
        }
    }

    function _indexOf(bytes memory haystack, bytes memory needle) private pure returns (int256) {
        if (needle.length > haystack.length) {
            return -1;
        }
        for (uint256 i = 0; i <= haystack.length - needle.length; i++) {
            bool matchFound = true;
            for (uint256 j = 0; j < needle.length; j++) {
                if (haystack[i + j] != needle[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) {
                return int256(i);
            }
        }
        return -1;
    }

    function _indexOfFrom(bytes memory haystack, bytes memory needle, uint256 start) private pure returns (int256) {
        if (needle.length + start > haystack.length) {
            return -1;
        }
        for (uint256 i = start; i <= haystack.length - needle.length; i++) {
            bool matchFound = true;
            for (uint256 j = 0; j < needle.length; j++) {
                if (haystack[i + j] != needle[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) {
                return int256(i);
            }
        }
        return -1;
    }
}
