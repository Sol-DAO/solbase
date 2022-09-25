// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Interface for contracts with ERC165 support.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/utils/LibERC165.sol)
abstract contract ERC165 {
    function supportsInterface(bytes4 interfaceId) external view virtual returns (bool);
}
