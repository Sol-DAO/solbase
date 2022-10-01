// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC1155} from "../../../tokens/ERC1155/ERC1155.sol";
import {EIP712} from "../../../utils/EIP712.sol";

/// @notice ERC1155 + EIP-2612-style implementation.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/tokens/ERC1155/extensions/ERC1155Permit.sol)
abstract contract ERC1155Permit is ERC1155, EIP712 {
    /// -----------------------------------------------------------------------
    /// EIP-2612-style Constants
    /// -----------------------------------------------------------------------

    /// @dev `keccak256("Permit(address owner,address spender,uint256 id,uint256 nonce,uint256 deadline)")`.
    bytes32 public constant PERMIT_TYPEHASH = 0x29da74a9365f97c3d77de334aec5c720e44b0c8a6e640ceb375e27a8ab7acadd;

    /// -----------------------------------------------------------------------
    /// EIP-2612-style Storage
    /// -----------------------------------------------------------------------

    mapping(address => mapping(uint256 => uint256)) public nonces;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(string memory domainName) EIP712(domainName, "1") {}

    /// -----------------------------------------------------------------------
    /// EIP-2612-style Permit Logic
    /// -----------------------------------------------------------------------

    function permit(
        address owner,
        address spender,
        uint256 id,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                computeDigest(
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, id, nonces[owner][id]++, deadline))
                ),
                v,
                r,
                s
            );

            require(recoveredAddress == owner && recoveredAddress != address(0), "INVALID_SIGNER");

            isApprovedForAll[owner][spender] = true;

            emit ApprovalForAll(owner, spender, true);
        }
    }
}
