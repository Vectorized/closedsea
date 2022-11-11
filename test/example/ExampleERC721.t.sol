// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ExampleERC721} from "../../src/example/ExampleERC721.sol";
import {BaseRegistryTest} from "../BaseRegistryTest.sol";

contract TestableExampleERC721 is ExampleERC721 {
    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract ExampleERC721Test is BaseRegistryTest {
    TestableExampleERC721 example;
    address filteredAddress;

    address constant DEFAULT_SUBSCRIPTION = address(0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6);

    function setUp() public override {
        super.setUp();

        vm.startPrank(DEFAULT_SUBSCRIPTION);
        registry.register(DEFAULT_SUBSCRIPTION);

        filteredAddress = makeAddr("filtered address");
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), filteredAddress, true);
        vm.stopPrank();

        example = new TestableExampleERC721();
    }

    function testFilter() public {
        vm.startPrank(address(filteredAddress));
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
        example.transferFrom(makeAddr("from"), makeAddr("to"), 1);
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
        example.safeTransferFrom(makeAddr("from"), makeAddr("to"), 1);
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
        example.safeTransferFrom(makeAddr("from"), makeAddr("to"), 1, "");
    }

    function testOwnersNotExcluded() public {
        address alice = address(0xA11CE);
        example.mint(alice, 1);

        vm.prank(DEFAULT_SUBSCRIPTION);
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), alice, true);

        vm.prank(alice);
        example.transferFrom(alice, makeAddr("to"), 1);
    }

    function testOwnersNotExcludedSafeTransfer() public {
        address alice = address(0xA11CE);
        example.mint(alice, 1);
        example.mint(alice, 2);

        vm.prank(DEFAULT_SUBSCRIPTION);
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), alice, true);

        vm.startPrank(alice);
        example.safeTransferFrom(alice, makeAddr("to"), 1);
        example.safeTransferFrom(alice, makeAddr("to"), 2, "");
    }

    function testExclusionExceptionDoesNotApplyToOperators() public {
        address alice = address(0xA11CE);
        address bob = address(0xB0B);
        example.mint(bob, 1);

        vm.prank(DEFAULT_SUBSCRIPTION);
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), alice, true);

        vm.prank(bob);
        example.setApprovalForAll(alice, true);

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, alice));
        example.transferFrom(bob, makeAddr("to"), 1);
    }

    function testSetOperatorFilteringEnabled() public {
        uint256 randomness = uint256(keccak256(abi.encode(123)));
        address alice = address(0xA11CE);
        address to = makeAddr("to");
        vm.prank(alice);
        example.setApprovalForAll(address(filteredAddress), true);

        for (uint256 i = 0; i < 256; ++i) {
            example.mint(alice, i);
            bool enabled = randomness & 1 == 0;
            vm.prank(example.owner());
            example.setOperatorFilteringEnabled(enabled);

            vm.prank(address(filteredAddress));
            if (enabled) {
                vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
            }
            example.transferFrom(alice, to, i);

            randomness = randomness >> 1;
        }
    }

    function testRepeatRegistrationOk() public {
        vm.prank(example.owner());
        example.repeatRegistration();
        testSetOperatorFilteringEnabled();
    }
}
