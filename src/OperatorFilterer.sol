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
    /// Note: Will not revert nor update existing settings for repeated registration.
    function _registerForOperatorFiltering() internal {
        _registerForOperatorFiltering(_OPENSEA_DEFAULT_SUBSCRIPTION, true);
    }

    /// @dev Registers the current contract to OpenSea's operator filter.
    /// Note: Will not revert nor update existing settings for repeated registration.
    function _registerForOperatorFiltering(address subscriptionOrRegistrantToCopy, bool subscribe) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let functionSelector := 0x7d3e3dbe // `registerAndSubscribe(address,address)`.
            // prettier-ignore
            for {} 1 {} {
                // Clean the upper 96 bits of `subscriptionOrRegistrantToCopy` in case they are dirty.
                subscriptionOrRegistrantToCopy := shr(96, shl(96, subscriptionOrRegistrantToCopy))
                if iszero(subscribe) {
                    if iszero(subscriptionOrRegistrantToCopy) {
                        functionSelector := 0x4420e486 // `register(address)`.
                        break
                    }
                    functionSelector := 0xa0af2903 // `registerAndCopyEntries(address,address)`.
                    break
                }
                break
            }
            // Store the function selector.
            mstore(0x00, shl(224, functionSelector))
            // Store the `address(this)`.
            mstore(0x04, address())
            // Store the `subscriptionOrRegistrantToCopy`.
            mstore(0x24, subscriptionOrRegistrantToCopy)
            // Register into the registry.
            pop(call(gas(), _OPERATOR_FILTER_REGISTRY, 0, 0x00, 0x44, 0x00, 0x00))
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

                // Store the function selector of `isOperatorAllowed(address,address)`,
                // shifted left by 6 bytes, which is enough for 8tb of memory.
                // We waste 6-3 = 3 bytes to save on 6 runtime gas (PUSH1 0x224 SHL).
                mstore(0x00, 0xc6171134001122334455)
                // Store the `address(this)`.
                mstore(0x1a, address())
                // Store the `msg.sender`.
                mstore(0x3a, caller())

                // `isOperatorAllowed` always returns true if it does not revert.
                if iszero(staticcall(gas(), registry, 0x16, 0x44, 0x00, 0x00)) {
                    // Bubble up the revert if the staticcall reverts.
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }

                // Store the `from`.
                mstore(0x3a, from)

                // We abuse `returndatasize` here to save 1 gas over PUSH1 0x00.
                // `returndatasize` will be 0x00 if the contract is not deployed,
                // and 0x20 if deployed.
                if iszero(staticcall(gas(), registry, 0x16, 0x44, returndatasize(), returndatasize())) {
                    // Bubble up the revert if the staticcall reverts.
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
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
