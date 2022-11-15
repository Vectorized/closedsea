// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {OperatorFilterer} from "../src/OperatorFilterer.sol";
import {BaseRegistryTest} from "./BaseRegistryTest.sol";
import {DefaultFilterer} from "./helpers/DefaultFilterer.sol";

contract DefaultOperatorFiltererTest is BaseRegistryTest {
    DefaultFilterer filterer;
    address filteredAddress;
    address filteredCodeHashAddress;
    bytes32 filteredCodeHash;
    address constant DEFAULT_SUBSCRIPTION = address(0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6);

    function setUp() public override {
        super.setUp();
        vm.startPrank(DEFAULT_SUBSCRIPTION);
        registry.register(DEFAULT_SUBSCRIPTION);

        filteredAddress = makeAddr("filtered address");
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), filteredAddress, true);
        filteredCodeHashAddress = makeAddr("filtered code hash");
        bytes memory code = hex"deadbeef";
        filteredCodeHash = keccak256(code);
        registry.updateCodeHash(address(DEFAULT_SUBSCRIPTION), filteredCodeHash, true);
        vm.etch(filteredCodeHashAddress, code);

        filterer = new DefaultFilterer();
        vm.stopPrank();
    }

    function testFilterGas() public view {
        filterer.filterTest(address(this));
    }

    function testFilter() public {
        assertTrue(filterer.filterTest(address(this)));
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
        vm.prank(filteredAddress);
        filterer.filterTest(address(this));
        vm.expectRevert(abi.encodeWithSelector(CodeHashFiltered.selector, filteredCodeHashAddress, filteredCodeHash));
        vm.prank(filteredCodeHashAddress);
        filterer.filterTest(address(this));
    }
}
