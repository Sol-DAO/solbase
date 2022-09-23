// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {EIP712} from "../utils/EIP712.sol";

contract MockEIP712 is EIP712 {

    constructor(string memory domainName, string memory version) EIP712(domainName, version) {}
}

contract EIP712Test is DSTestPlus {

    MockEIP712 mock;

    function setUp() public {
        mock = new MockEIP712("EIP712-domain-name", "1");
    }
}
