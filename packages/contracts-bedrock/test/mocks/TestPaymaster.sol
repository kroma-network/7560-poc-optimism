// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestPaymaster {
    // bytes4(keccak256("validatePaymasterTransaction(uint256,bytes32,bytes)"))
    bytes4 private constant MAGIC_VALUE_PAYMASTER = 0xe0e6183a;

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    function postPaymasterTransaction(bool success, uint256 actualGasCost, bytes calldata context) external pure {
        (success, actualGasCost, context);
    }

    function validatePaymasterTransaction(
        uint256 version,
        bytes32 txHash,
        bytes calldata transaction
    ) external pure returns (bytes memory context, bytes32 validationData) {
        (version, txHash, transaction);
        context = new bytes(0);
        uint64 max = type(uint64).max - 1;
        validationData = bytes32(abi.encodePacked(MAGIC_VALUE_PAYMASTER, max, uint64(0)));
    }
}
