// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { OperatorFilterer } from "../../src/OperatorFilterer.sol";

contract DefaultFilterer is OperatorFilterer {
    constructor() {
        _registerForOperatorFiltering();
    }

    function filter(address from) public view onlyAllowedOperator(from) returns (bool) {
        return true;
    }
}
