// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/auth/Auth.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
abstract contract Auth {
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    error Unauthorized();

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnershipTransferred(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() virtual {
        if (!isAuthorized(msg.sender, msg.sig)) revert Unauthorized();

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be
        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public payable virtual {
        // We check if the caller is the owner first because we want to ensure they can
        // always swap out the authority even if it's reverting or using up a lot of gas.
        if (msg.sender != owner && !authority.canCall(msg.sender, address(this), msg.sig)) revert Unauthorized();

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function transferOwnership(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}
