// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Permit} from "./Permit.sol";

/// @notice Self helper for any ERC2612, EIP-4494 or Dai-style token permit.
/// @author Solbase (https://github.com/Sol-DAO/solbase/blob/main/src/utils/SelfPermit.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/SelfPermit.sol)
/// @dev These functions are expected to be embedded in multicall to allow EOAs to approve a contract and call a function
/// that requires an approval in a single transaction.
abstract contract SelfPermit {
    /// @dev ERC20.

    /// @notice Permits this contract to spend a given ERC2612 `token` from `owner`.
    /// @param token The address of the asset spent.
    /// @param owner The address of the asset holder.
    /// @param value The amount permitted to spend.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `msg.sender` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `v`.
    function selfPermit(
        Permit token,
        address owner,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        token.permit(owner, address(this), value, deadline, v, r, s);
    }

    /// @notice Permits this contract to spend a given Dai-style `token` from `owner`.
    /// @param token The address of the asset spent.
    /// @param owner The address of the asset holder.
    /// @param nonce The current nonce of the `owner`.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `msg.sender` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `v`.
    function selfPermitAllowed(
        Permit token,
        address owner,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        token.permit(owner, address(this), nonce, deadline, true, v, r, s);
    }

    /// @dev ERC721.

    /// @notice Permits this contract to spend a given ERC2612-style NFT `tokenID`.
    /// @param token The address of the asset spent.
    /// @param tokenId The ID of the token that is being approved for permit.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `msg.sender` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `v`.
    function selfPermit721(
        Permit token,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        token.permit(address(this), tokenId, deadline, v, r, s);
    }

    /// @notice Permits this contract to spend a given EIP-4494 NFT `tokenID`.
    /// @param token The address of the asset spent.
    /// @param tokenId The ID of the token that is being approved for permit.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param sig A traditional or EIP-2098 signature.
    function selfPermit721(
        Permit token,
        uint256 tokenId,
        uint256 deadline,
        bytes calldata sig
    ) public virtual {
        token.permit(address(this), tokenId, deadline, sig);
    }

    /// @dev ERC1155.

    /// @notice Permits this contract to spend a given ERC2612-style multitoken.
    /// @param token The address of the asset spent.
    /// @param owner The address of the asset holder.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `msg.sender` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `msg.sender` along with `r` and `v`.
    function selfPermit1155(
        Permit token,
        address owner,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        token.permit(owner, address(this), true, deadline, v, r, s);
    }
}
