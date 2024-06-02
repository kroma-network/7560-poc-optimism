// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestAccount {
    // bytes4(keccak256("validateTransaction(uint256,bytes32,bytes)"))
    bytes4 private constant MAGIC_VALUE_SENDER = 0xbf45c166;

    // solhint-disable-next-line no-empty-blocks
    receive() external payable { }

    function validateTransaction(
        uint256 version,
        bytes32 txHash,
        bytes calldata transaction
    )
        external
        pure
        returns (uint256 validationData)
    {
        (version, txHash, transaction);
        uint64 max = type(uint64).max;
        validationData = uint256(uint32(MAGIC_VALUE_SENDER)) << 224 | uint256(uint64(0)) << 160 | uint256(max) << 96;
    }

    function execute(address dest, uint256 value, bytes calldata func) external {
        (bool success, bytes memory result) = dest.call{ value: value }(func);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }
}
