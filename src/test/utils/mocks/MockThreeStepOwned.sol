// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ThreeStepOwned} from "../../../auth/ThreeStepOwned.sol";

contract MockThreeStepOwned is ThreeStepOwned(msg.sender) {
    bool public flag;

    function updateFlag() public virtual onlyOwner {
        flag = true;
    }
}
