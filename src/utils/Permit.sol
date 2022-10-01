// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Signature permit interface for any EIP-2612 or Dai-style token.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/utils/Permit.sol)
abstract contract Permit {
    /// @notice Permit to spend tokens for EIP-2612 permit signatures.
    /// @param owner The address of the token holder.
    /// @param spender The address of the token permit holder.
    /// @param value The amount permitted to spend.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `owner` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `owner` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `owner` along with `r` and `v`.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual;

    /// @notice Permit to spend tokens for permit signatures that have the `allowed` parameter.
    /// @param owner The address of the token holder.
    /// @param spender The address of the token permit holder.
    /// @param nonce The current nonce of the `owner`.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param allowed If true, `spender` will be given permission to spend `owner`'s tokens.
    /// @param v Must produce valid secp256k1 signature from the `owner` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `owner` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `owner` along with `r` and `v`.
    function permit(
        address owner,
        address spender,
        uint256 nonce,
        uint256 deadline,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual;
}
