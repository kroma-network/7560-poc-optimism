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
        returns (bytes32 validationData)
    {
        (version, txHash, transaction);
        // limited to 48 bits
        uint48 validUntil = 0;
        uint48 validAfter = 0;
        validationData = bytes32(
            uint256(uint32(MAGIC_VALUE_SENDER)) |
            ((uint256(validUntil)) << 160) |
            (uint256(validAfter) << (160 + 48))
        );
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
