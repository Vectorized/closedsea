// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { ExampleERC721Upgradeable } from
    "../../../src/example/upgradeable/ExampleERC721Upgradeable.sol";
import { BaseRegistryTest } from "../../BaseRegistryTest.sol";
import { Initializable } from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";

contract TestableExampleERC721 is ExampleERC721Upgradeable {
    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function repeatRegistration() public {
        _registerForOperatorFiltering();
    }
}

contract ExampleERC721UpgradeableTest is BaseRegistryTest, Initializable {
    TestableExampleERC721 example;
    address filteredAddress;

    function setUp() public override {
        super.setUp();

        vm.startPrank(DEFAULT_SUBSCRIPTION);
        registry.register(DEFAULT_SUBSCRIPTION);

        filteredAddress = makeAddr("filtered address");
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), filteredAddress, true);
        vm.stopPrank();

        example = new TestableExampleERC721();
        example.initialize();
    }

    function testUpgradeable() public {
        TestableExampleERC721 example2 = new TestableExampleERC721();
        vm.expectEmit(true, true, false, true, address(example2));
        emit Initialized(1);
        example2.initialize();
        vm.expectRevert(bytes("Initializable: contract is already initialized"));
        example2.initialize();
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
        vm.prank(bob);
        example.setApprovalForAll(alice, true);

        vm.prank(DEFAULT_SUBSCRIPTION);
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), alice, true);

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, alice));
        example.transferFrom(bob, makeAddr("to"), 1);
    }

    function testExcludeApprovals() public {
        address alice = address(0xA11CE);
        address bob = address(0xB0B);
        example.mint(bob, 1);

        vm.prank(DEFAULT_SUBSCRIPTION);
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), alice, true);

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, alice));
        example.setApprovalForAll(alice, true);

        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, alice));
        example.approve(alice, 1);
    }

    function testSetOperatorFilteringEnabled() public {
        uint256 randomness = uint256(keccak256(abi.encode(123)));
        address alice = address(0xA11CE);
        address to = makeAddr("to");
        example.setOperatorFilteringEnabled(false);
        vm.prank(alice);
        example.setApprovalForAll(address(filteredAddress), true);

        for (uint256 i = 0; i < 128; ++i) {
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

        for (uint256 i = 0; i < 128; ++i) {
            bool enabled = randomness & 1 == 0;
            vm.prank(example.owner());
            example.setOperatorFilteringEnabled(enabled);

            vm.prank(alice);
            if (enabled) {
                vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
            }
            example.setApprovalForAll(address(filteredAddress), true);
            randomness = randomness >> 1;
        }
    }

    function testRepeatRegistrationOk() public {
        vm.prank(example.owner());
        example.repeatRegistration();
        testSetOperatorFilteringEnabled();
    }

    function testSupportsInterface() public {
        assertTrue(example.supportsInterface(0x01ffc9a7)); // IERC165
        assertTrue(example.supportsInterface(0x80ac58cd)); // IERC721
        assertTrue(example.supportsInterface(0x5b5e139f)); // IERC721Metadata
        assertTrue(example.supportsInterface(0x2a55205a)); // IERC2981
        assertFalse(example.supportsInterface(0x10101010)); // Some unsupported interface.
    }
}
