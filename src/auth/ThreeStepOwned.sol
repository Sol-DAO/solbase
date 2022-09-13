// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Three-step single owner authorization mixin.
/// @author SolBase (https://github.com/Sol-DAO/solbase/blob/main/src/auth/ThreeStepOwned.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract ThreeStepOwned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdateInitiated(address indexed user, address indexed ownerCandidate);

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;
    
    address internal _ownerCandidate;
    
    bool internal _ownerCandidateConfirmed;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Create contract and set `owner`.
    /// @param _owner The `owner` of contract.
    constructor(address _owner) {
        owner = _owner;

        emit OwnerUpdated(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Initiate ownership transfer.
    /// @param newOwner The `_ownerCandidate` that will `confirmOwner()`.
    function setOwner(address newOwner) public virtual onlyOwner {
        _ownerCandidate = newOwner;

        emit OwnerUpdateInitiated(msg.sender, newOwner);
    }
    
    /// @notice Confirm ownership between `owner` and `_ownerCandidate`.
    function confirmOwner() public virtual {
        if (_ownerCandidateConfirmed) {
            require(msg.sender == owner, "UNAUTHORIZED");
            
            delete _ownerCandidateConfirmed;
            
            address newOwner = _ownerCandidate;
            
            owner = newOwner;

            emit OwnerUpdated(msg.sender, newOwner);
        } else {
            require(msg.sender == _ownerCandidate, "UNAUTHORIZED");

            _ownerCandidateConfirmed = true;
        }
    }
    
    /// @notice Terminate ownership by `owner`.
    function renounceOwner() public virtual onlyOwner {
        delete owner;

        emit OwnerUpdated(msg.sender, address(0));
    }
}
