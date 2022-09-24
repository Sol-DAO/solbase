// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20Permit} from "../tokens/ERC20/extensions/ERC20Permit.sol";

abstract contract SelfPermit {
    function selfPermit(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        ERC20Permit(token).permit(msg.sender, address(this), value, deadline, v, r, s);
    }
}
