// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Authority} from "../../../src/auth/Auth.sol";

contract MockAuthority is Authority {
    bool immutable allowCalls;

    constructor(bool _allowCalls) {
        allowCalls = _allowCalls;
    }

    function canCall(address, address, bytes4) public view override returns (bool) {
        return allowCalls;
    }
}
