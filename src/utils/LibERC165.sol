// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Interface for contracts with ERC165 support (https://eips.ethereum.org/EIPS/eip-165[EIP]).
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/utils/LibERC165.sol)
abstract contract ERC165 {
    function supportsInterface(bytes4 interfaceId) external view virtual returns (bool);
}

/// @notice Library used to query support of an interface declared via {ERC165}.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/utils/LibERC165.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165Checker.sol)
/// @dev Note that these functions return the actual result of the query: they do not
/// revert if an interface is not supported. It is up to the caller to decide
/// what to do in these cases.
library LibERC165 {
    /// @dev As per the ERC165 spec, no interface should ever match `0xffffffff`.
    bytes4 private constant INTERFACE_ID_INVALID = 0xffffffff;

    /// @dev Returns true if `account` supports the {ERC165} interface.
    function supportsERC165(address account) internal view returns (bool) {
        return
            supportsERC165InterfaceUnchecked(account, type(ERC165).interfaceId) &&
            !supportsERC165InterfaceUnchecked(account, INTERFACE_ID_INVALID);
    }

    /// @dev Returns true if `account` supports the interface defined by
    /// `interfaceId`. Support for {ERC165} itself is queried automatically.
    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        return supportsERC165(account) && supportsERC165InterfaceUnchecked(account, interfaceId);
    }

    /// @notice Query if a contract implements an interface - does not check ERC165 support.
    /// @param account The address of the contract to query for support of an interface.
    /// @param interfaceId The interface identifier, as specified in ERC165.
    /// @return true if the contract at account indicates support of the interface with
    /// identifier `interfaceId` - false otherwise.
    /// @dev Assumes that account contains a contract that supports ERC165, otherwise
    /// the behavior of this method is undefined. This precondition can be checked
    /// with {supportsERC165}.
    /// Interface identification is specified in ERC165.
    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
        // Prepare call.
        bytes memory encodedParams = abi.encodeWithSelector(ERC165.supportsInterface.selector, interfaceId);

        // Perform static call.
        bool success;
        uint256 returnSize;
        uint256 returnValue;

        assembly {
            success := staticcall(30000, account, add(encodedParams, 0x20), mload(encodedParams), 0x00, 0x20)
            returnSize := returndatasize()
            returnValue := mload(0x00)
        }

        return success && returnSize >= 0x20 && returnValue != 0;
    }
}
