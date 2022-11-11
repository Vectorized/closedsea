// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {OperatorFilterer} from "../../src/OperatorFilterer.sol";

contract DefaultFilterer is OperatorFilterer {
    constructor() {
        _registerForOperatorFiltering();
    }

    function filterTest(address from) public view onlyAllowedOperator(from, true) returns (bool) {
        return true;
    }
}
