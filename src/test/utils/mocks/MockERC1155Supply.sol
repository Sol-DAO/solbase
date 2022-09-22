// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC1155} from "../../../tokens/ERC1155.sol";

contract MockERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) public totalSupply;

    function uri(uint256) public pure virtual override returns (string memory) {}

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        _mint(to, id, amount, data);

        totalSupply[id] += amount;
    }

    function batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        _batchMint(to, ids, amounts, data);

        uint256 id;

        uint256 amount;

        for (uint256 i; i < ids.length; ) {
            id = ids[i];

            amount = amounts[i];

            totalSupply[id] += amount;

            unchecked {
                ++i;
            }
        }
    }

    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) public virtual {
        _burn(from, id, amount);

        unchecked {
            totalSupply[id] -= amount;
        }
    }

    function batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public virtual {
        _batchBurn(from, ids, amounts);

        uint256 id;

        uint256 amount;

        for (uint256 i; i < ids.length; ) {
            id = ids[i];

            amount = amounts[i];

            totalSupply[id] -= amount;

            unchecked {
                ++i;
            }
        }
    }
}
