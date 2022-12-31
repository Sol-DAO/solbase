// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC1155B} from "../../../src/tokens/ERC1155/ERC1155B.sol";

contract MockERC1155B is ERC1155B {
    function uri(uint256) public pure virtual override returns (string memory) {}

    function mint(
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        _mint(to, id, data);
    }

    function batchMint(
        address to,
        uint256[] memory ids,
        bytes memory data
    ) public virtual {
        _batchMint(to, ids, data);
    }

    function burn(uint256 id) public virtual {
        _burn(id);
    }

    function batchBurn(address from, uint256[] memory ids) public virtual {
        _batchBurn(from, ids);
    }
}
