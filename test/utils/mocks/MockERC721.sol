// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721Permit} from "../../../src/tokens/ERC721/extensions/ERC721Permit.sol";

contract MockERC721 is ERC721Permit {
    constructor(string memory _name, string memory _symbol) ERC721Permit(_name, _symbol) {}

    function tokenURI(uint256) public pure virtual override returns (string memory) {}

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId, bytes memory data) public virtual {
        _safeMint(to, tokenId, data);
    }
}
