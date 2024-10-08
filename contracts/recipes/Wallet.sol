// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {UniqueFungible} from "@unique-nft/solidity-interfaces/contracts/UniqueFungible.sol";
import {UniquePrecompiles} from "../libraries/UniquePrecompiles.sol";
import {CollectionMinter} from "../CollectionMinter.sol";

contract Wallet is CollectionMinter {
    address private feeAsset;
    address private vendor;
    address public owner;

    uint256 public s_executionFee;

    event Executed(address indexed to, uint256 value, bytes data);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwnerPayable(uint256 _fee) {
        require(msg.sender == owner, "Not owner");
        uint256 executionFee = _fee == 0 ? s_executionFee : _fee;
        bool success = UniqueFungible(feeAsset).transfer(vendor, executionFee);
        require(success, "Cannot withdraw the execution fee");
        _;
    }

    constructor(address _owner, uint32 _feeAsset, address _vendor) CollectionMinter(true, false, true) {
        require(_owner != address(0), "Owner address cannot be zero");
        feeAsset = COLLECTION_HELPERS.collectionAddress(_feeAsset);
        s_executionFee = 1e16;
        owner = _owner;
        vendor = _vendor;
    }

    /// @notice Allows the owner to execute a call to another contract
    /// @param _to The address of the contract or account to call
    /// @param _value The amount of Ether (in wei) to send with the call
    /// @param _data The calldata to send with the call
    /// @return result The data returned from the call
    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwnerPayable(0) returns (bytes memory result) {
        require(_to != address(0), "Target address cannot be zero");

        // Perform the call
        (bool success, bytes memory data) = _to.call{value: _value}(_data);
        require(success, "Call execution failed");

        emit Executed(_to, _value, _data);

        return data;
    }

    function transfer(address _token, address _recipient, uint256 _amount) external onlyOwnerPayable(1e17) {
        UniqueFungible(_token).transfer(_recipient, _amount);
    }

    function createCollection() external onlyOwnerPayable(1e17) {
        // TODO call minter contract
    }

    /// @notice Allows the owner to change the ownership of the wallet
    /// @param _newOwner The address of the new owner
    function changeOwner(address _newOwner) external onlyOwnerPayable(0) {
        require(_newOwner != address(0), "New owner cannot be zero address");
        emit OwnerChanged(owner, _newOwner);
        owner = _newOwner;
    }

    /// @notice Fallback function to receive Ether
    receive() external payable {}

    /// @notice Function to withdraw Ether from the wallet to the owner's address
    /// @param _amount The amount of Ether (in wei) to withdraw
    function withdraw(uint256 _amount) external onlyOwnerPayable(0) {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(owner).transfer(_amount);
    }

    /// @notice Returns the wallet's Ether balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
