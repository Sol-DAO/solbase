// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC721} from "../../../tokens/ERC721.sol";

contract MockERC721 is ERC721 {
    uint256 public totalSupply;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function tokenURI(uint256) public pure virtual override returns (string memory) {}

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);

        unchecked {
            --totalSupply;
        }
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId);

        unchecked {
            ++totalSupply;
        }
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        _safeMint(to, tokenId, data);

        unchecked {
            ++totalSupply;
        }
    }
}
