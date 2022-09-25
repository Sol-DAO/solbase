// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20Permit} from "../tokens/ERC20/extensions/ERC20Permit.sol";

/// @notice Functionality to call `permit()` on any EIP-2612 or Dai-style token for use in the route.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/utils/SelfPermit.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/SelfPermit.sol)
/// @dev These functions are expected to be embedded in `multicall()` to allow EOAs to approve a contract and call a function
/// that requires an approval in a single transaction.
abstract contract SelfPermit {
    /// @notice Permits this contract to spend a given token from `msg.sender`.
    /// @dev The `owner` is always `msg.sender` and the `spender` is always `address(this)`.
    /// @param token The address of the token spent.
    /// @param value The amount that can be spent of token.
    /// @param deadline A timestamp, the current blocktime must be less than or equal to this timestamp.
    /// @param v Must produce valid secp256k1 signature from the holder along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the holder along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the holder along with `r` and `v`.
    function selfPermit(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable virtual {
        ERC20Permit(token).permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    /// @notice Permits this contract to spend the sender's tokens for permit signatures that have the `allowed` parameter.
    /// @dev The `owner` is always `msg.sender` and the `spender` is always `address(this)`.
    /// @param token The address of the token spent.
    /// @param nonce The current nonce of the owner.
    /// @param deadline The timestamp at which the permit is no longer valid.
    /// @param v Must produce valid secp256k1 signature from the holder along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the holder along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the holder along with `r` and `v`.
    function selfPermitAllowed(
        address token,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable virtual {
        SelfPermit(token).permit(msg.sender, address(this), nonce, deadline, true, v, r, s);
    }

    /// @dev Helper for Dai-style `permit()` via `selfPermitAllowed()`.
    function permit(
        address owner,
        address spender,
        uint256 nonce,
        uint256 deadline,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable virtual;
}
