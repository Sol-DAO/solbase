// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20Permit} from "../../../src/tokens/ERC20/extensions/ERC20Permit.sol";

contract MockERC20 is ERC20Permit {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20Permit(_name, _symbol, _decimals) {}

    function mint(address to, uint256 value) public virtual {
        _mint(to, value);
    }

    function burn(address from, uint256 value) public virtual {
        _burn(from, value);
    }

    function burnFrom(address from, uint256 value) public virtual {
        _burn(from, value);
    }
}
