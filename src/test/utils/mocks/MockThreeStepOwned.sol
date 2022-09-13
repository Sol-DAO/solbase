// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ThreeStepOwned} from "../../../auth/ThreeStepOwned.sol";

contract MockThreeStepOwned is ThreeStepOwned(msg.sender) {
    bool public flag;

    function updateFlag() public virtual onlyOwner {
        flag = true;
    }
}
