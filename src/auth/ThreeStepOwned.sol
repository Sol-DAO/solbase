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

    constructor(address _owner) {
        owner = _owner;

        emit OwnerUpdated(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        _ownerCandidate = newOwner;

        emit OwnerUpdateInitiated(msg.sender, newOwner);
    }

    function confirmOwner() public virtual {
        if (_ownerCandidateConfirmed) {
            require(msg.sender == owner, "UNAUTHORIZED");
            
            delete _ownerCandidateConfirmed;
            
            address newOwner = _ownerCandidate;
            
            delete _ownerCandidate;
            
            owner = newOwner;

            emit OwnerUpdated(msg.sender, newOwner);
        } else {
            require(msg.sender == _ownerCandidate, "UNAUTHORIZED");

            _ownerCandidateConfirmed = true;
        }
    }
    
    function renounceOwner() public virtual onlyOwner {
        delete owner;
        
        delete _ownerCandidate;

        emit OwnerUpdated(msg.sender, address(0));
    }
}
