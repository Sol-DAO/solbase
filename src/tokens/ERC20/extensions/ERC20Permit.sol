// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20} from "../../../tokens/ERC20/ERC20.sol";
import {EIP712} from "../../../utils/EIP712.sol";

/// @notice ERC20 + EIP-2612 implementation.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/tokens/ERC20/extensions/ERC20Permit.sol)
abstract contract ERC20Permit is ERC20, EIP712 {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error PermitExpired();

    error InvalidSigner();

    /// -----------------------------------------------------------------------
    /// EIP-2612 Constants
    /// -----------------------------------------------------------------------

    /// @dev `keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")`.
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    /// -----------------------------------------------------------------------
    /// EIP-2612 Storage
    /// -----------------------------------------------------------------------

    mapping(address => uint256) public nonces;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) EIP712(_name, "1") {}

    /// -----------------------------------------------------------------------
    /// EIP-2612 Logic
    /// -----------------------------------------------------------------------

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) revert PermitExpired();

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                computeDigest(keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))),
                v,
                r,
                s
            );

            if (recoveredAddress == address(0)) revert InvalidSigner();

            if (recoveredAddress != owner) revert InvalidSigner();

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }
}
