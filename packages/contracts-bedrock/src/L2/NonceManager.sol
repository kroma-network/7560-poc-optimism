// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { ISemver } from "src/universal/ISemver.sol";

/// @custom:predeploy 0x4200000000000000000000000000000000000024
/// @title NonceManager
/// @notice The NonceManager manages nonce of smart accounts using RIP-7560.
contract NonceManager is ISemver {
    /// @notice Error for when the length of the data is invalid.
    error InvalidLength();
    /// @notice Error for when the given nonce is invalid.
    error NonceMismatch();

    /// @notice Semantic version.
    /// @custom:semver 0.1.0
    string public constant version = "0.1.0";

    /// @notice The EntryPoint address defined at RIP-7560.
    address internal constant AA_ENTRY_POINT = 0x0000000000000000000000000000000000007560;

    /// @notice Mapping of sender to key to nonce.
    mapping(address => mapping(uint192 => uint256)) internal _nonceSequenceNumber;

    /// slither-disable-next-line locked-ether
    /// TODO(sm-stack): Do we need fallback function?
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
    function _get(bytes calldata data) internal view returns (uint256 nonce) {
        if (data.length != 44) {
            revert InvalidLength();
        }

        address sender = address(bytes20(data[0:20]));
        uint192 key = uint192(bytes24(data[20:44]));

        return _nonceSequenceNumber[sender][key] | (uint256(key) << 64);
    }

    /// @notice validate nonce uniqueness for this account. Called by AA_ENTRY_POINT.
    /// @param data the calldata to validate
    function _validateIncrement(bytes calldata data) internal {
        address sender = address(bytes20(data[0:20]));
        uint192 key = uint192(bytes24(data[20:44]));
        uint64 nonce = uint64(bytes8(data[44:52]));

        uint256 currentNonce = _nonceSequenceNumber[sender][key];
        if (nonce != currentNonce) {
            revert NonceMismatch();
        }
        _nonceSequenceNumber[sender][key]++;
    }
}
