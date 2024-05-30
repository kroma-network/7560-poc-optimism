// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";

/// @custom:predeploy 0x4200000000000000000000000000000000000024
/// @title NonceManager
/// @notice The NonceManager manages nonce of smart accounts and EOAs using RIP-7560.
contract NonceManager is ISemver {
    /// @notice Semantic version.
    /// @custom:semver 0.1.0
    string public constant version = "0.1.0";

    address internal constant AA_ENTRY_POINT = 0x0000000000000000000000000000000000007560;

    /// The next valid sequence number for a given nonce key.
    mapping(address => mapping(uint192 => uint256)) public nonceSequenceNumber;

    fallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender == AA_ENTRY_POINT) {
            _validateIncrement(data);
            return new bytes(0);
        } else {
            return abi.encodePacked(get(data));
        }
    }

    /// @notice allow an account to manually increment its own nonce.
    ///         (mainly so that during construction nonce can be made non-zero,
    ///         to "absorb" the gas cost of first nonce increment to 1st transaction (construction),
    ///         not to 2nd transaction)
    /// @param key the high 192 bit of the nonce
    function incrementNonce(uint192 key) public {
        nonceSequenceNumber[msg.sender][key]++;
    }

    /// @notice Return the next nonce for this sender. Within a given key, the nonce values are sequenced
    ///         (starting with zero, and incremented by one on each transaction).
    ///         But transactions with different keys can come with arbitrary order.
    /// @return nonce a full nonce to pass for next transaction with given sender and key.
    function get(bytes calldata data) public view returns (uint256 nonce) {
        if (data.length != 44) {
            revert("length mismatch");
        }

        address sender = address(bytes20(data[0:20]));
        uint192 key = uint192(bytes24(data[20:44]));

        return nonceSequenceNumber[sender][key] | (uint256(key) << 64);
    }

    /// @notice validate nonce uniqueness for this account. Called by AA_ENTRY_POINT.
    /// @param data the calldata to validate
    function _validateIncrement(bytes calldata data) internal {
        address sender = address(bytes20(data[0:20]));
        uint192 key = uint192(bytes24(data[20:44]));
        uint64 nonce = uint64(bytes8(data[44:52]));

        uint256 currentNonce = nonceSequenceNumber[sender][key];
        if (nonce != currentNonce) {
            revert();
        }
        nonceSequenceNumber[sender][key]++;
    }
}
