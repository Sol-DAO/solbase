// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {EIP712} from "../../../utils/EIP712.sol";

contract MockEIP712 is EIP712 {
    constructor(string memory domainName, string memory version) EIP712(domainName, version) {}
}
