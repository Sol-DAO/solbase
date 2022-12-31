// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Contract helper for any ERC2612, EIP-4494 or Dai-style token permit.
/// @author Solbase (https://github.com/Sol-DAO/solbase/blob/main/src/utils/Permit.sol)
abstract contract Permit {
    /// @dev ERC20.

    /// @notice Permit to spend tokens for ERC2612 permit signatures.
    /// @param owner The address of the token holder.
    /// @param spender The address of the token permit holder.
    /// @param value The amount permitted to spend.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `owner` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `owner` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `owner` along with `r` and `v`.
    /// @dev This permit will work for certain ERC721 supporting ERC2612-style permits,
    /// such as Uniswap V3 position and Solbase NFTs.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual;

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
    ) public virtual;

    /// @dev ERC721.

    /// @notice Permit to spend specific NFT `tokenId` for ERC2612-style permit signatures.
    /// @param spender The address of the token permit holder.
    /// @param tokenId The ID of the token that is being approved for permit.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `owner` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `owner` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `owner` along with `r` and `v`.
    /// @dev Modified from Uniswap
    /// (https://github.com/Uniswap/v3-periphery/blob/main/contracts/interfaces/IERC721Permit.sol).
    function permit(address spender, uint256 tokenId, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual;

    /// @notice Permit to spend specific NFT `tokenId` for EIP-4494 permit signatures.
    /// @param spender The address of the token permit holder.
    /// @param tokenId The ID of the token that is being approved for permit.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param sig A traditional or EIP-2098 signature.
    function permit(address spender, uint256 tokenId, uint256 deadline, bytes calldata sig) public virtual;

    /// @dev ERC1155.

    /// @notice Permit to spend multitoken IDs for ERC2612-style permit signatures.
    /// @param owner The address of the token holder.
    /// @param operator The address of the token permit holder.
    /// @param approved If true, `operator` will be given permission to spend `owner`'s tokens.
    /// @param deadline The unix timestamp before which permit must be spent.
    /// @param v Must produce valid secp256k1 signature from the `owner` along with `r` and `s`.
    /// @param r Must produce valid secp256k1 signature from the `owner` along with `v` and `s`.
    /// @param s Must produce valid secp256k1 signature from the `owner` along with `r` and `v`.
    function permit(
        address owner,
        address operator,
        bool approved,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual;
}
