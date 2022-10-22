// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721Votes} from "../../../src/tokens/ERC721/extensions/ERC721Votes.sol";

contract MockERC721Votes is ERC721Votes {
    constructor(string memory name, string memory symbol) ERC721Votes(name, symbol) {}

    /// @dev Getters.

    function getChainId() public view virtual returns (uint256) {
        return block.chainid;
    }

    function tokenURI(uint256) public view virtual override returns (string memory) {
        return "MOCK";
    }

    /// @dev Mint/Burn.

    function mint(address account, uint256 id) public payable virtual {
        _mint(account, id);
    }

    function burn(uint256 id) public payable virtual {
        _burn(id);
    }
}
