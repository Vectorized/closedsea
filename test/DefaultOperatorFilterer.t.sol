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
    address notFiltered;

    function setUp() public override {
        super.setUp();
        notFiltered = makeAddr("not filtered");
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
}
