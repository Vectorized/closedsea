// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {OperatorFilterer} from "../src/OperatorFilterer.sol";
import {BaseRegistryTest} from "./BaseRegistryTest.sol";
import {Vm} from "forge-std/Vm.sol";
import {PriorityFilterer} from "./helpers/PriorityFilterer.sol";

contract PriorityOperatorFiltererTest is BaseRegistryTest {
    PriorityFilterer filterer;
    address filteredAddress;
    address filteredCodeHashAddress;
    address priorityOperator;
    bytes32 filteredCodeHash;
    address notFiltered;

    function setUp() public override {
        super.setUp();
        priorityOperator = makeAddr("priority operator");
        notFiltered = makeAddr("not filtered");
        filterer = new PriorityFilterer(priorityOperator);
        filteredAddress = makeAddr("filtered address");
        registry.updateOperator(address(filterer), filteredAddress, true);
        filteredCodeHashAddress = makeAddr("filtered code hash");
        bytes memory code = hex"deadbeef";
        filteredCodeHash = keccak256(code);
        registry.updateCodeHash(address(filterer), filteredCodeHash, true);
        vm.etch(filteredCodeHashAddress, code);
    }

    function testPriorityFilterWithMsgSenderGas() public view {
        filterer.filter(address(this));
    }

    function testPriorityFilterWithOperatorGas() public view {
        filterer.filter(notFiltered);
    }

    function testPriorityFilterWithPriorityOperatorGas() public {
        vm.prank(priorityOperator);
        filterer.filter(notFiltered);
    }

    function testPriorityFilter() public {
        assertTrue(filterer.filter(notFiltered));
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
        vm.prank(filteredAddress);
        filterer.filter(notFiltered);
        vm.expectRevert(abi.encodeWithSelector(CodeHashFiltered.selector, filteredCodeHashAddress, filteredCodeHash));
        vm.prank(filteredCodeHashAddress);
        filterer.filter(notFiltered);

        registry.updateOperator(address(filterer), priorityOperator, true);
        vm.prank(priorityOperator);
        filterer.filter(notFiltered);
    }
}
