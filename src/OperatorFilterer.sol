// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Optimized and flexible operator filterer to abide to OpenSea's
/// mandatory on-chain royalty enforcement in order for new collections to
/// receive royalties.
/// For more information, see:
/// See: https://github.com/ProjectOpenSea/operator-filter-registry
abstract contract OperatorFilterer {
    /// @dev Emitted when the caller is a blocked operator.
    error OperatorNotAllowed(address operator);

    /// @dev The default OpenSea operator blocklist subscription.
    address internal constant _OPENSEA_DEFAULT_SUBSCRIPTION = 0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6;

    /// @dev The OpenSea operator filter registry.
    address internal constant _OPERATOR_FILTER_REGISTRY = 0x000000000000AAeB6D7670E522A718067333cd4E;

    /// @dev Registers the current contract to OpenSea's operator filter,
    /// and subscribe to the default OpenSea operator blocklist.
    function _registerForOperatorFiltering() internal {
        _registerForOperatorFiltering(_OPENSEA_DEFAULT_SUBSCRIPTION, true);
    }

    /// @dev Registers the current contract to OpenSea's operator filter.
    function _registerForOperatorFiltering(address subscriptionOrRegistrantToCopy, bool subscribe) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let registry := _OPERATOR_FILTER_REGISTRY
            // prettier-ignore
            for {} 1 {} {
                // Clean the upper 96 bits of `subscriptionOrRegistrantToCopy` in case they are dirty.
                subscriptionOrRegistrantToCopy := shr(96, shl(96, subscriptionOrRegistrantToCopy))
                if iszero(subscribe) {
                    if iszero(subscriptionOrRegistrantToCopy) {
                        // Store the function selector of `register(address)`.
                        mstore(0x00, shl(224, 0x4420e486))
                        break
                    }
                    // Store the function selector of `registerAndCopyEntries(address,address)`.
                    mstore(0x00, shl(224, 0xa0af2903))
                    break
                }
                // Store the function selector of `registerAndSubscribe(address,address)`.
                mstore(0x00, shl(224, 0x7d3e3dbe))
                break
            }

            // Store the `address(this)`.
            mstore(0x04, address())
            // Store the `subscriptionOrRegistrantToCopy`.
            mstore(0x24, subscriptionOrRegistrantToCopy)
            // Register into the registry.
            pop(call(gas(), registry, 0, 0x00, 0x44, 0x00, 0x00))
            // Restore the part of the free memory pointer that was overwritten,
            // which is guaranteed to be zero, because of Solidity's memory size limits.
            mstore(0x24, 0)
        }
    }

    /// @dev Modifier to guard a function and revert if `from` is a blocked operator.
    /// Can be turned off by passing false for `filterEnabled`.
    modifier onlyAllowedOperator(address from, bool filterEnabled) virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // prettier-ignore
            for {} filterEnabled {} {
                // Clean the upper 96 bits of `from` in case they are dirty.
                from := shr(96, shl(96, from))
                // prettier-ignore
                if eq(from, caller()) { break }

                let registry := _OPERATOR_FILTER_REGISTRY
                
                // prettier-ignore
                if iszero(extcodesize(registry)) { break }

                // Store the function selector of `isOperatorAllowed(address,address)`,
                // shifted left by 6 bytes, which is enough for 8tb of memory.
                // We waste 6-3 = 3 bytes to save on 6 runtime gas (PUSH1 0x224 SHL).
                mstore(0x00, 0xc6171134001122334455)
                // Store the `address(this)`.
                mstore(0x1a, address())
                // Store the `msg.sender`.
                mstore(0x3a, caller())

                if iszero(staticcall(gas(), registry, 0x16, 0x44, 0x3a, 0x20)) {
                    // Bubble up the revert if the staticcall reverts.
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }

                if iszero(and(eq(mload(0x3a), 1), eq(returndatasize(), 0x20))) {
                    // Store the function selector of `OperatorNotAllowed(address)`.
                    mstore(0x00, 0xede71dcc)
                    // Store the `msg.sender`.
                    mstore(0x20, caller())
                    // Revert with (offset, size).
                    revert(0x1c, 0x36)
                }

                // Store the `from`.
                mstore(0x3a, from)

                if iszero(staticcall(gas(), registry, 0x16, 0x44, 0x3a, 0x20)) {
                    // Bubble up the revert if the staticcall reverts.
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }

                if iszero(and(eq(mload(0x3a), 1), eq(returndatasize(), 0x20))) {
                    // Store the function selector of `OperatorNotAllowed(address)`.
                    mstore(0x00, 0xede71dcc)
                    // Store the `msg.sender`.
                    mstore(0x20, caller())
                    // Revert with (offset, size).
                    revert(0x1c, 0x24)
                }

                // Restore the part of the free memory pointer that was overwritten,
                // which is guaranteed to be zero, if less than 8tb of memory is used.
                mstore(0x3a, 0)
                break
            }
        }
        _;
    }
}
