// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {EIP712} from "../../../utils/EIP712.sol";
import {ERC20} from "../../../tokens/ERC20/ERC20.sol";

abstract contract ERC20Permit is ERC20, EIP712 {

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
    ) 
        ERC20(_name, _symbol, _decimals)
        EIP712(_name, "1") 
    {}

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
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                computeDigest(                        
                    keccak256(
                        abi.encode(
                            keccak256(
                                "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                            ),
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }
}