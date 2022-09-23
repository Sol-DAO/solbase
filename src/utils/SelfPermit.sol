// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "../tokens/ERC20/ERC20.sol";

abstract contract SelfPermit {
    function selfPermit(
        ERC20 token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        token.permit(msg.sender, address(this), value, deadline, v, r, s);
    }
}