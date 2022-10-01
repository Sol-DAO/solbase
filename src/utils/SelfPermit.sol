// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Permit} from "./Permit.sol";

/// @notice Signature permit helper for any EIP-2612 or Dai-style token.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/utils/SelfPermit.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/SelfPermit.sol)
/// @dev These functions are expected to be embedded in multicall to allow EOAs to approve a contract and call a function
/// that requires an approval in a single transaction.
abstract contract SelfPermit {
    /// @notice Permits this contract to spend a given EIP-2612 `token` from `msg.sender`.
    /// @dev The `owner` is always `msg.sender` and the `spender` is always `address(this)`.
    /// @param token The address of the asset spent.
    /// @param value The amount permitted to spend.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `msg.sender` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `v`.
    function selfPermit(
        Permit token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        token.permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    /// @notice Permits this contract to spend a given Dai-style `token` from `msg.sender`.
    /// @dev The `owner` is always `msg.sender` and the `spender` is always `address(this)`.
    /// @param token The address of the asset spent.
    /// @param nonce The current nonce of the `owner`.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `msg.sender` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `v`.
    function selfPermitAllowed(
        Permit token,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        token.permit(msg.sender, address(this), nonce, deadline, true, v, r, s);
    }
}
