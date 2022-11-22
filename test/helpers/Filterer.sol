// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {OperatorFilterer} from "../../src/OperatorFilterer.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {IOperatorFilterRegistry} from "operator-filter-registry/IOperatorFilterRegistry.sol";

contract Filterer is OperatorFilterer, Ownable {
    error OperatorNotAllowed(address operator);

    constructor() {
        _registerForOperatorFiltering(address(0), false);
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(eq(mload(0x40), 0x80)) { revert(0, 0) }
        }
    }

    function filter(address from) public view onlyAllowedOperator(from) returns (bool) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(eq(mload(0x40), 0x80)) { revert(0, 0) }
        }
        return true;
    }

    function filterOriginal(address from)
        public
        view
        onlyAllowedOperatorOriginal(from)
        returns (bool)
    {
        return true;
    }

    modifier onlyAllowedOperatorOriginal(address from) virtual {
        if (address(_OPERATOR_FILTER_REGISTRY).code.length > 0) {
            if (from == msg.sender) {
                _;
                return;
            }
            if (
                !IOperatorFilterRegistry(_OPERATOR_FILTER_REGISTRY).isOperatorAllowed(
                    address(this), msg.sender
                )
            ) {
                revert OperatorNotAllowed(msg.sender);
            }
        }
        _;
    }
}
