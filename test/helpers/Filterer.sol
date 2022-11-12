// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {OperatorFilterer} from "../../src/OperatorFilterer.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract Filterer is OperatorFilterer, Ownable {
    constructor() {
        _registerForOperatorFiltering(address(0), false);
    }

    function testFilter(address from) public view onlyAllowedOperator(from, true) returns (bool) {
        return true;
    }
}
