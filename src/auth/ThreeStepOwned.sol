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

    bool internal _updateConfirmedByCandidate;
    address internal _ownerCandidate;

    address public owner;

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

    function renounceOwnership() public virtual onlyOwner {
        owner = address(0);

        emit OwnerUpdated(msg.sender, address(0));
    }

    function initOwnershipUpdate(address _newOwnerCandidate) public virtual onlyOwner {
        _ownerCandidate = _newOwnerCandidate;

        emit OwnerUpdateInitiated(msg.sender, _newOwnerCandidate);
    }

    function confirmOwnershipUpdate() public virtual {
        if (_updateConfirmedByCandidate) {
            require(msg.sender == owner, "UNAUTHORIZED");

            _updateConfirmedByCandidate = false;
            owner = _ownerCandidate;

            emit OwnerUpdated(msg.sender, owner);
        } else {
            require(msg.sender == _ownerCandidate, "UNAUTHORIZED");

            _updateConfirmedByCandidate = true;
        }
    }
}
