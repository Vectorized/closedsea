// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {OperatorFilterer} from "../src/OperatorFilterer.sol";
import {BaseRegistryTest} from "./BaseRegistryTest.sol";
import {Vm} from "forge-std/Vm.sol";
import {Filterer} from "./helpers/Filterer.sol";

contract ConcreteOperatorFilterer is OperatorFilterer {
    constructor(address registrant, bool sub) {
        _registerForOperatorFiltering(registrant, sub);
    }
}

contract OperatorFiltererTest is BaseRegistryTest {
    Filterer filterer;
    address filteredAddress;
    address filteredCodeHashAddress;
    bytes32 filteredCodeHash;
    address notFiltered;

    function setUp() public override {
        super.setUp();
        notFiltered = makeAddr("not filtered");
        filterer = new Filterer();
        filteredAddress = makeAddr("filtered address");
        registry.updateOperator(address(filterer), filteredAddress, true);
        filteredCodeHashAddress = makeAddr("filtered code hash");
        bytes memory code = hex"deadbeef";
        filteredCodeHash = keccak256(code);
        registry.updateCodeHash(address(filterer), filteredCodeHash, true);
        vm.etch(filteredCodeHashAddress, code);
    }

    function testFilterWithMsgSenderGas() public view {
        filterer.filter(address(this));
    }

    function testFilterWithMsgSenderOriginalGas() public view {
        filterer.filterOriginal(address(this));
    }

    function testFilterWithOperatorGas() public view {
        filterer.filter(notFiltered);
    }

    function testFilterWithOperatorOriginalGas() public view {
        filterer.filterOriginal(notFiltered);
    }

    function testFilter() public {
        assertTrue(filterer.filter(notFiltered));
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
        vm.prank(filteredAddress);
        filterer.filter(notFiltered);
        vm.expectRevert(
            abi.encodeWithSelector(
                CodeHashFiltered.selector, filteredCodeHashAddress, filteredCodeHash
            )
        );
        vm.prank(filteredCodeHashAddress);
        filterer.filter(notFiltered);
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function testConstructory_noSubscribeOrCopy() public {
        vm.recordLogs();
        Filterer filterer2 = new Filterer();
        Vm.Log[] memory logs = vm.getRecordedLogs();

        assertEq(logs.length, 2);
        uint256 i;
        if (logs[0].topics[0] == keccak256("OwnershipTransferred(address,address)")) {
            i = 1;
        }
        assertEq(logs[i].topics[0], keccak256("RegistrationUpdated(address,bool)"));
        assertEq(address(uint160(uint256(logs[i].topics[1]))), address(filterer2));
        assertEq(logs[i ^ 1].topics[0], keccak256("OwnershipTransferred(address,address)"));
    }

    function testConstructor_copy() public {
        address deployed = computeCreateAddress(address(this), vm.getNonce(address(this)));
        vm.expectEmit(true, false, false, false, address(registry));
        emit RegistrationUpdated(deployed, true);
        vm.expectEmit(true, true, true, false, address(registry));
        emit OperatorUpdated(deployed, filteredAddress, true);
        vm.expectEmit(true, true, true, false, address(registry));
        emit CodeHashUpdated(deployed, filteredCodeHash, true);
        new ConcreteOperatorFilterer(address(filterer), false);
    }

    function testConstructor_subscribe() public {
        address deployed = computeCreateAddress(address(this), vm.getNonce(address(this)));
        vm.expectEmit(true, false, false, false, address(registry));
        emit RegistrationUpdated(deployed, true);
        vm.expectEmit(true, true, true, false, address(registry));
        emit SubscriptionUpdated(deployed, address(filterer), true);
        vm.recordLogs();
        new ConcreteOperatorFilterer(address(filterer), true);
        assertEq(vm.getRecordedLogs().length, 2);
    }

    function testRegistryNotDeployedDoesNotRevert() public {
        vm.etch(address(registry), "");
        Filterer filterer2 = new Filterer();
        assertTrue(filterer2.filter(address(this)));
    }

    function testRegisterNonExistentRegistryDoesNotRevert() public {
        new ConcreteOperatorFilterer(address(0x12345678791234567879), true);
        new ConcreteOperatorFilterer(address(0x12345678791234567879), false);
    }
}
