// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721} from "../../../tokens/ERC721/ERC721.sol";
import {EIP712} from "../../../utils/EIP712.sol";

/// @notice ERC721 + EIP-2612-Style implementation.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/tokens/ERC721/extensions/ERC721Permit.sol)
abstract contract ERC721Permit is ERC721, EIP712 {
    /// -----------------------------------------------------------------------
    /// EIP-2612-Style Storage
    /// -----------------------------------------------------------------------

    mapping(uint256 => uint256) public nonces;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(string memory _name, string memory _symbol) payable ERC721(_name, _symbol) EIP712(_name, "1") {}

    /// -----------------------------------------------------------------------
    /// EIP-2612-Style Permit Logic
    /// -----------------------------------------------------------------------

    function permit(
        address spender,
        uint256 id,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(spender != address(0), "INVALID_SPENDER");

        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                computeDigest(
                    keccak256(
                        abi.encode(
                            keccak256("Permit(address spender,uint256 id,uint256 nonce,uint256 deadline)"),
                            spender,
                            id,
                            nonces[id]++,
                            deadline
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(
                (recoveredAddress == _ownerOf[id] || id == type(uint256).max) && recoveredAddress != address(0),
                "INVALID SIGNER"
            );

            // If id is 2**256, then we assume the signer wants
            // to approve spender to spend all of their tokens.
            if (id == type(uint256).max) {
                isApprovedForAll[recoveredAddress][spender] = true;

                emit ApprovalForAll(recoveredAddress, spender, true);
            } else {
                getApproved[id] = spender;

                emit Approval(recoveredAddress, spender, id);
            }
        }
    }
}
