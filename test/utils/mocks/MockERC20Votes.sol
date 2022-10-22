// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20Votes} from "../../../src/tokens/ERC20/extensions/ERC20Votes.sol";

contract MockERC20Votes is ERC20Votes {
    constructor(string memory name, string memory symbol) ERC20Votes(name, symbol, 18) {}

    function mint(address account, uint256 amount) public payable {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public payable {
        _burn(account, amount);
    }

    function getChainId() external view returns (uint256) {
        return block.chainid;
    }
}
