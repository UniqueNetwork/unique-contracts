// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./BytesUtils.sol";

/**
 * @title AttributeUtils
 * @dev Library for manipulating token attributes within a JSON metadata string.
 *      Provides functions to set or remove traits in a token's attributes.
 */
library AttributeUtils {
    using BytesUtils for *;

    bytes private constant ATTRIBUTES_PATTERN = '"attributes":[';
    bytes private constant VALUE_PATTERN = '"value":"';
    bytes private constant IMAGE_PATTERN = '"image":"';

    /**
     * @notice Sets or updates the image field in the token's metadata JSON.
     * @dev If the `image` field exists, its value is updated.
     *      If it does not exist, a new `image` field is added to the JSON.
     *      This function uses string manipulation with byte arrays and assembly for efficiency.
     *      It uses the BytesUtils library for helper functions.
     * @param _strBytes The original token metadata as a byte array.
     * @param _image The new image URL or value to set.
     * @return A new byte array representing the updated token metadata.
     */
    function setTokenImage(bytes memory _strBytes, bytes memory _image) public pure returns (bytes memory) {
        bytes memory imagePattern = IMAGE_PATTERN;
        int256 index = _strBytes.indexOfFrom(imagePattern, 0);

        if (index >= 0) {
            // Image field exists, replace the value
            uint256 imageIndex = uint256(index);

            // Find the index of the start of the image value
            uint256 valueStart = imageIndex + imagePattern.length;
            uint256 valueEnd = valueStart;

            // Find the end index of the current image value (denoted by the next double quote)
            while (valueEnd < _strBytes.length && _strBytes[valueEnd] != '"') {
                unchecked {
                    valueEnd++;
                }
            }

            // Escape special characters in the new image value
            bytes memory escapedImage = _image.escapeString();

            // Calculate the new length of the JSON string after replacing the image value
            uint256 newLength = _strBytes.length - (valueEnd - valueStart) + escapedImage.length;
            bytes memory newStrBytes = new bytes(newLength);

            uint256 dest;
            uint256 src;
            uint256 len;

            assembly {
                dest := add(newStrBytes, 32)
                src := add(_strBytes, 32)
            }

            // Copy the part before the image value
            len = valueStart;
            dest.memcpy(src, len);
            dest += len;

            // Copy the escaped new image value
            assembly {
                src := add(escapedImage, 32)
                len := mload(escapedImage)
            }
            dest.memcpy(src, len);
            dest += len;

            // Copy the remaining part after the old image value
            uint256 restLen = _strBytes.length - valueEnd;
            assembly {
                src := add(add(_strBytes, 32), valueEnd)
            }
            dest.memcpy(src, restLen);

            return newStrBytes;
        } else {
            // Image field does not exist, add it
            // Find the insertion point (after '{' or before the first field)
            uint256 insertionPoint = 0;

            // Check if JSON starts with '{'
            if (_strBytes.length > 0 && _strBytes[0] == "{") {
                insertionPoint = 1; // After '{'

                // Move insertionPoint after any whitespace or newlines
                while (insertionPoint < _strBytes.length && _strBytes[insertionPoint] <= 0x20) {
                    unchecked {
                        insertionPoint++;
                    }
                }
            }

            // Escape special characters in the new image value
            bytes memory escapedImage = _image.escapeString();

            // Construct the new image field
            bytes memory newImageField = abi.encodePacked('"image":"', escapedImage, '"');

            // Determine if we need to add a comma
            bool needsComma = (_strBytes.length > insertionPoint && _strBytes[insertionPoint] != "}");

            // Adjust the new image field accordingly
            if (needsComma) {
                newImageField = abi.encodePacked(newImageField, ",");
            }

            // Calculate the new length of the JSON string after adding the image field
            uint256 newLength = _strBytes.length + newImageField.length;
            bytes memory newStrBytes = new bytes(newLength);

            uint256 dest;
            uint256 src;
            uint256 len;

            assembly {
                dest := add(newStrBytes, 32)
                src := add(_strBytes, 32)
            }

            // Copy the part before the insertion point
            len = insertionPoint;
            dest.memcpy(src, len);
            dest += len;

            // Copy the new image field
            assembly {
                src := add(newImageField, 32)
                len := mload(newImageField)
            }
            dest.memcpy(src, len);
            dest += len;

            // Copy the remaining part after the insertion point
            uint256 restLen = _strBytes.length - insertionPoint;
            assembly {
                src := add(add(_strBytes, 32), insertionPoint)
            }
            dest.memcpy(src, restLen);

            return newStrBytes;
        }
    }

    /**
     * @notice Sets or updates the value of a trait in the token's attributes JSON.
     * @dev If the trait with the given `trait_type` exists, its `value` is updated.
     *      If it does not exist, a new trait is added to the attributes array.
     * @param _strBytes The original token metadata as a byte array.
     * @param _trait_type The `trait_type` of the trait to set or update.
     * @param _value The new `value` to assign to the trait.
     * @return A new byte array representing the updated token metadata.
     */
    function dangerSetTraitValue(
        bytes memory _strBytes,
        bytes memory _trait_type,
        bytes memory _value
    ) public pure returns (bytes memory) {
        int256 indexOfAttributes = _strBytes.indexOfFrom(ATTRIBUTES_PATTERN, 0);
        if (indexOfAttributes == -1) return _strBytes;

        bytes memory traitTypePattern = abi.encodePacked('"trait_type":"', _trait_type, '"');
        int256 index = _strBytes.indexOfFrom(traitTypePattern, uint256(indexOfAttributes));

        if (index >= 0) {
            // Trait exists, replace the value
            uint256 traitIndex = uint256(index);

            // Find the index of '"value":"' after trait_type
            int256 valueIndex = _strBytes.indexOfFrom(VALUE_PATTERN, traitIndex);

            if (valueIndex == -1) return _strBytes;

            uint256 valueStart = uint256(valueIndex) + VALUE_PATTERN.length;
            uint256 valueEnd = valueStart;
            while (valueEnd < _strBytes.length && _strBytes[valueEnd] != '"') {
                unchecked {
                    valueEnd++;
                }
            }

            // Escape _value
            bytes memory escapedValue = _value.escapeString();

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
            dest.memcpy(src, len);
            dest += len;

            // Copy the escapedValue
            assembly {
                src := add(escapedValue, 32)
                len := mload(escapedValue)
            }
            dest.memcpy(src, len);
            dest += len;

            // Copy the rest
            uint256 restLen = _strBytes.length - valueEnd;
            assembly {
                src := add(add(_strBytes, 32), valueEnd)
            }
            dest.memcpy(src, restLen);

            return newStrBytes;
        } else {
            uint256 startAttributesIndex = uint256(indexOfAttributes) + ATTRIBUTES_PATTERN.length;
            string memory endOfNewTrait = _strBytes[startAttributesIndex] == "]" ? '"}' : '"},';

            bytes memory escapedTraitType = _trait_type.escapeString();
            bytes memory escapedValue = _value.escapeString();

            // Trait does not exist, add new trait
            bytes memory newTrait = abi.encodePacked(
                '{"trait_type":"',
                escapedTraitType,
                '",',
                VALUE_PATTERN,
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
            dest.memcpy(src, len);
            dest += len;

            // Copy newTrait
            assembly {
                src := add(newTrait, 32)
                len := mload(newTrait)
            }
            dest.memcpy(src, len);
            dest += len;

            // Copy the rest
            uint256 restLen = _strBytes.length - startAttributesIndex;
            assembly {
                src := add(add(_strBytes, 32), startAttributesIndex)
            }
            dest.memcpy(src, restLen);

            return newStrBytes;
        }
    }

    /**
     * @notice Removes a trait from the token's attributes JSON based on the `trait_type`.
     * @dev Searches for the trait with the given `trait_type` and removes it from the attributes array.
     *      If the trait is not found, the original JSON is returned unchanged.
     * @param _strBytes The original token metadata as a byte array.
     * @param _trait_type The `trait_type` of the trait to remove.
     * @return A new byte array representing the updated token metadata without the specified trait.
     */
    function dangerRemoveTrait(bytes memory _strBytes, bytes memory _trait_type) public pure returns (bytes memory) {
        bytes memory traitTypePattern = abi.encodePacked('"trait_type":"', _trait_type, '"');
        int256 index = _strBytes.indexOfFrom(traitTypePattern, 0);

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
                    destPtr.memcpy(srcPtr, len);
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
                    destPtr.memcpy(srcPtr, len);
                }
            }

            return newStrBytes;
        } else {
            // Trait does not exist
            return _strBytes;
        }
    }
}
