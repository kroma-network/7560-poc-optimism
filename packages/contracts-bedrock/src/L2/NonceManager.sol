// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";

/// @custom:predeploy 0x4200000000000000000000000000000000000024
/// @title NonceManager
/// @notice The NonceManager manages nonce of smart accounts using RIP-7560.
contract NonceManager is ISemver {
    /// @notice Semantic version.
    /// @custom:semver 0.1.0
    string public constant version = "0.1.0";

    /// @notice The EntryPoint address defined at RIP-7560.
    address internal constant AA_ENTRY_POINT = 0x0000000000000000000000000000000000007560;

    fallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender == AA_ENTRY_POINT) {
            _validateIncrement(data);
            return new bytes(0);
        } else {
            return abi.encodePacked(_get(data));
        }
    }

    /// @notice Return the next nonce for this sender. Within a given key, the nonce values are sequenced
    ///         (starting with zero, and incremented by one on each transaction).
    ///         But transactions with different keys can come with arbitrary order.
    /// @return nonce a full nonce to pass for next transaction with given sender and key.
    function _get(bytes calldata /* data */) internal view returns (uint256 nonce) {
        assembly {
            // Check if calldata is 44 bytes long
            if iszero(eq(calldatasize(), 44)) {
                mstore(0x00, 0x947d5a84) // 'InvalidLength()'
                revert(0x1c, 0x04)
            }

            let ptr := mload(0x40)
            calldatacopy(ptr, 0, 44)

            // Extract key and sender from calldata
            let key := shr(64, mload(add(ptr, 20)))
            mstore(0x00, key)
            mstore(0x14, shr(96, mload(ptr)))

            // Load nonce from storage
            nonce := or(shl(64, key), sload(keccak256(0x04, 0x30)))
        }
    }

    /// @notice validate nonce uniqueness for this account. Called by AA_ENTRY_POINT.
    function _validateIncrement(bytes calldata /* data */) internal {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            // Store key and sender in memory
            mstore(0x00, shr(64, mload(add(ptr, 20))))
            mstore(0x14, shr(96, mload(ptr)))

            // Calculate storage slot and load current nonce
            let nonceSlot := keccak256(0x04, 0x30)
            let currentNonce := sload(nonceSlot)

            // Revert if nonce mismatch
            if iszero(eq(shr(192, mload(add(ptr, 44))), currentNonce)) {
                mstore(0, 0)
                revert(0, 0) // Revert if nonce mismatch
            }

            // Increment nonce
            sstore(nonceSlot, add(currentNonce, 1))
        }
    }
}
