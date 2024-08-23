// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestPaymaster {
    // bytes4(keccak256("validatePaymasterTransaction(uint256,bytes32,bytes)"))
    bytes4 private constant MAGIC_VALUE_PAYMASTER = 0xe0e6183a;

    // solhint-disable-next-line no-empty-blocks
    receive() external payable { }

    function postPaymasterTransaction(bool success, uint256 actualGasCost, bytes calldata context) external pure {
        (success, actualGasCost, context);
    }

    function validatePaymasterTransaction(
        uint256 version,
        bytes32 txHash,
        bytes calldata transaction
    )
        external
        pure
        returns (bytes32 validationData, bytes memory context)
    {
        (version, txHash, transaction);
        context = new bytes(1);
        // limited to 48 bits
        uint48 validUntil = 0;
        uint48 validAfter = 0;
        validationData = bytes32(
            uint256(uint32(MAGIC_VALUE_PAYMASTER)) |
            ((uint256(validUntil)) << 160) |
            (uint256(validAfter) << (160 + 48))
        );
    }
}
