// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Owned} from "../../../auth/Owned.sol";

contract MockOwned is Owned(msg.sender) {
    bool public flag;

    function updateFlag() public virtual onlyOwner {
        flag = true;
    }
}
