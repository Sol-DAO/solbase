// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Three-step single owner authorization mixin.
/// @author SolBase (https://github.com/Sol-DAO/solbase/blob/main/src/auth/OwnedThreeStep.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract OwnedThreeStep {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event OwnerUpdateInitiated(address indexed user, address indexed ownerCandidate);

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /// -----------------------------------------------------------------------
    /// Custom Errors
    /// -----------------------------------------------------------------------

    error Unauthorized();

    /// -----------------------------------------------------------------------
    /// Ownership Storage
    /// -----------------------------------------------------------------------

    address public owner;

    address internal _ownerCandidate;

    bool internal _ownerCandidateConfirmed;

    modifier onlyOwner() virtual {
        if (msg.sender != owner) revert Unauthorized();

        _;
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    /// @notice Create contract and set `owner`.
    /// @param _owner The `owner` of contract.
    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /// -----------------------------------------------------------------------
    /// Ownership Logic
    /// -----------------------------------------------------------------------

    /// @notice Initiate ownership transfer.
    /// @param newOwner The `_ownerCandidate` that will `confirmOwner()`.
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        _ownerCandidate = newOwner;

        emit OwnerUpdateInitiated(msg.sender, newOwner);
    }

    /// @notice Confirm ownership between `owner` and `_ownerCandidate`.
    function confirmOwner() public payable virtual {
        if (_ownerCandidateConfirmed) {
            if (msg.sender != owner) revert Unauthorized();

            delete _ownerCandidateConfirmed;

            address newOwner = _ownerCandidate;

            owner = newOwner;

            emit OwnershipTransferred(msg.sender, newOwner);
        } else {
            if (msg.sender != _ownerCandidate) revert Unauthorized();

            _ownerCandidateConfirmed = true;
        }
    }

    /// @notice Terminate ownership by `owner`.
    function renounceOwner() public payable virtual onlyOwner {
        delete owner;

        emit OwnershipTransferred(msg.sender, address(0));
    }
}
