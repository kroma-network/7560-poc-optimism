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
        uint64 max = type(uint64).max - 1;
        validationData = bytes32(abi.encodePacked(MAGIC_VALUE_SENDER, max, uint64(0)));
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
