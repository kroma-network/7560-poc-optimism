// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Testing utilities
import { stdError } from "forge-std/Test.sol";
import { VmSafe } from "forge-std/Vm.sol";

import { CommonTest } from "test/setup/CommonTest.sol";
import { NextImpl } from "test/mocks/NextImpl.sol";
import { EIP1967Helper } from "test/mocks/EIP1967Helper.sol";

// Libraries
import { Types } from "src/libraries/Types.sol";
import { Hashing } from "src/libraries/Hashing.sol";
import { Constants } from "src/libraries/Constants.sol";

// Target contract dependencies
import { Proxy } from "src/universal/Proxy.sol";
import { ResourceMetering } from "src/L1/ResourceMetering.sol";
import { AddressAliasHelper } from "src/vendor/AddressAliasHelper.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";
import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";
import { L1Block } from "src/L2/L1Block.sol";
import { Predeploys } from "src/libraries/Predeploys.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { GasPayingToken } from "src/libraries/GasPayingToken.sol";
import { MockERC20 } from "solmate/test/utils/mocks/MockERC20.sol";
import { AddressAliasHelper } from "src/vendor/AddressAliasHelper.sol";
import "src/libraries/PortalErrors.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L1BlockInterop, ConfigType } from "src/L2/L1BlockInterop.sol";
import { Predeploys } from "src/libraries/Predeploys.sol";
import { Constants } from "src/libraries/Constants.sol";

contract OptimismPortal_Test is CommonTest {
    address depositor;

    /// @notice Marked virtual to be overridden in
    ///         test/kontrol/deployment/DeploymentSummary.t.sol
    function setUp() public virtual override {
        super.setUp();
        depositor = makeAddr("depositor");
    }

    function testFuzz_setConfig(ConfigType _type, bytes calldata _value) public {
        vm.prank(depositor);

        // Emit the special deposit transaction directly that sets the config in the L1Block predeploy contract.
        interop.emit TransactionDeposited(
            Constants.DEPOSITOR_ACCOUNT,
            Predeploys.L1_BLOCK_ATTRIBUTES,
            OptimismPortal.DEPOSIT_VERSION,
            abi.encodePacked(
                uint256(0), // mint
                uint256(0), // value
                uint64(Constants.SYSTEM_DEPOSIT_GAS_LIMIT), // gasLimit
                false, // isCreation,
                abi.encodeCall(L1BlockInterop.setConfig, (_type, _value))
            )
        );
    }
}
