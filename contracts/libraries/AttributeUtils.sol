// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library AttributeUtils {
    /// @notice Sets a new trait value in the provided attribute.
    /// @dev DANGER: This method can be very gas-consuming, especially with large JSON strings, and could potentially lead to a denial of service (DOS) if used improperly.
    /// @param _str The original tokenData.
    /// @param _traitType The trait type whose value needs to be updated.
    /// @param _newValue The new value to set for the specified trait type.
    /// @return The updated tokenData string with the new trait value.
    function _dangerDosPossible_setTraitValue(
        bytes memory _str,
        string memory _traitType,
        string memory _newValue
    ) internal pure returns (bytes memory) {
        bytes memory newValueBytes = bytes(_newValue);

        bytes memory key = abi.encodePacked('"trait_type":"', _traitType, '","value":"');
        uint keyLength = key.length;
        uint strLength = _str.length;
        uint i = 0;
        uint oldValueLen = 0;

        // Find key in string
        for (i = 0; i <= strLength - keyLength; i++) {
            bool matchFound = true;
            for (uint j = 0; j < keyLength; j++) {
                if (_str[i + j] != key[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) {
                // Find the old value length
                uint k = i + keyLength;
                while (k < strLength && _str[k] != '"') {
                    oldValueLen++;
                    k++;
                }
                break;
            }
        }

        // If no match is found, return original string
        if (i > strLength - keyLength) {
            return _str;
        }

        // Create a new string with the new value
        bytes memory result = new bytes(strLength - oldValueLen + newValueBytes.length);
        uint pos = 0;

        // Copy the part before the key
        for (uint j = 0; j < i + keyLength; j++) {
            result[pos++] = _str[j];
        }

        // Copy the new value
        for (uint j = 0; j < newValueBytes.length; j++) {
            result[pos++] = newValueBytes[j];
        }

        // Copy the rest of the original string after the old value
        for (uint j = i + keyLength + oldValueLen; j < strLength; j++) {
            result[pos++] = _str[j];
        }

        // Return the new string
        return result;
    }

    /// @notice Removes a specified trait from the provided attributes.
    /// @dev DANGER: This method can be very gas-consuming, especially with large JSON strings, and could potentially lead to a denial of service (DOS) if used improperly.
    /// @param _str The original tokenData.
    /// @param _traitType The trait type to be removed.
    /// @return The updated tokenData string with the specified trait removed.
    function _dangerDosPossible_removeTrait(
        bytes memory _str,
        string memory _traitType
    ) internal pure returns (bytes memory) {
        bytes memory key = abi.encodePacked('"trait_type":"', _traitType, '","value":"');
        uint keyLength = key.length;
        uint strLength = _str.length;
        uint i = 0;

        // Step 1: Find the trait in the string
        for (i = 0; i <= strLength - keyLength; i++) {
            bool matchFound = true;
            for (uint j = 0; j < keyLength; j++) {
                if (_str[i + j] != key[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) {
                uint traitStart = i;
                uint k = i + keyLength;

                // Find the end of the value string
                while (k < strLength && _str[k] != '"') {
                    k++;
                }
                uint traitEnd = k + 1;

                // Step 2: Adjust for commas and braces
                // Handle trailing comma
                if (traitEnd < strLength && _str[traitEnd] == ",") {
                    traitEnd++;
                }
                // Handle leading comma
                else if (traitStart > 0 && _str[traitStart - 1] == ",") {
                    traitStart--;
                }

                // Handle surrounding curly braces
                if (traitStart > 0 && _str[traitStart - 1] == "{" && traitEnd < strLength && _str[traitEnd] == "}") {
                    traitStart--;
                    traitEnd++;
                }

                // If the trait is the only one, remove the entire object
                if (traitStart == 0 && traitEnd == strLength) {
                    return bytes(""); // Return an empty string if the entire content is removed
                }

                // Step 3: Copy the remaining parts into a new bytes array
                bytes memory result = new bytes(strLength - (traitEnd - traitStart));
                uint pos = 0;

                // Copy before the trait
                for (uint j = 0; j < traitStart; j++) {
                    result[pos++] = _str[j];
                }

                // Copy after the trait
                for (uint j = traitEnd; j < strLength; j++) {
                    result[pos++] = _str[j];
                }

                // Step 4: Remove any double commas
                if (result.length > 0) {
                    // Remove leading comma if there's one at the start
                    if (result[0] == ",") {
                        bytes memory finalResult = new bytes(result.length - 1);
                        for (uint j = 1; j < result.length; j++) {
                            finalResult[j - 1] = result[j];
                        }
                        result = finalResult;
                    }

                    // Remove trailing comma if there's one at the end
                    if (result.length > 0 && result[result.length - 1] == ",") {
                        bytes memory finalResult = new bytes(result.length - 1);
                        for (uint j = 0; j < finalResult.length; j++) {
                            finalResult[j] = result[j];
                        }
                        result = finalResult;
                    }

                    // Replace double commas with a single one
                    for (uint j = 1; j < result.length; j++) {
                        if (result[j] == "," && result[j - 1] == ",") {
                            bytes memory finalResult = new bytes(result.length - 1);
                            for (uint k = 0; k < j - 1; k++) {
                                finalResult[k] = result[k];
                            }
                            for (uint k = j; k < result.length; k++) {
                                finalResult[k - 1] = result[k];
                            }
                            result = finalResult;
                        }
                    }
                }

                // Step 5: Return the cleaned-up bytes array
                return result;
            }
        }

        // If no match is found, return the original string
        return _str;
    }
}
