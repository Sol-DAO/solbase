// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {OwnedThreeStep} from "../../../src/auth/OwnedThreeStep.sol";

contract MockOwnedThreeStep is OwnedThreeStep(msg.sender) {
    bool public flag;

    function updateFlag() public virtual onlyOwner {
        flag = true;
    }
}
