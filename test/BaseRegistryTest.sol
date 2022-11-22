// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {
    OperatorFilterRegistry,
    OperatorFilterRegistryErrorsAndEvents
} from "operator-filter-registry/OperatorFilterRegistry.sol";

contract BaseRegistryTest is Test, OperatorFilterRegistryErrorsAndEvents {
    OperatorFilterRegistry constant registry =
        OperatorFilterRegistry(0x000000000000AAeB6D7670E522A718067333cd4E);

    address constant DEFAULT_SUBSCRIPTION = address(0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6);

    function setUp() public virtual {
        address deployedRegistry = address(new OperatorFilterRegistry());
        vm.etch(address(registry), deployedRegistry.code);
    }
}
