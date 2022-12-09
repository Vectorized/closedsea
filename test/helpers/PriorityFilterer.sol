// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { OperatorFilterer } from "../../src/OperatorFilterer.sol";
import { Ownable } from "openzeppelin-contracts/access/Ownable.sol";
import { IOperatorFilterRegistry } from "operator-filter-registry/IOperatorFilterRegistry.sol";

contract PriorityFilterer is OperatorFilterer, Ownable {
    address private immutable _priorityOperator;

    constructor(address priorityOperator) {
        _priorityOperator = priorityOperator;
        _registerForOperatorFiltering(address(0), false);
    }

    function filter(address from) public view onlyAllowedOperator(from) returns (bool) {
        return true;
    }

    function _isPriorityOperator(address operator) internal view override returns (bool) {
        return operator == _priorityOperator;
    }
}
