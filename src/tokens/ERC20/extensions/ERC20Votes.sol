// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20Permit} from "./ERC20Permit.sol";
import {SafeCastLib} from "../../../utils/SafeCastLib.sol";
import {FixedPointMathLib} from "../../../utils/FixedPointMathLib.sol";

struct Checkpoint {
    uint32 fromBlock;
    uint224 votes;
}

abstract contract ERC20Votes is ERC20Permit {

    /// -----------------------------------------------------------------------
    /// ERC20Votes Events
    /// -----------------------------------------------------------------------

    event DelegateChanged(
        address indexed delegator, 
        address indexed fromDelegate, 
        address indexed toDelegate
    );

    event DelegateVotesChanged(
        address indexed delegate, 
        uint256 previousBalance, 
        uint256 newBalance
    );

    /// -----------------------------------------------------------------------
    /// ERC20Votes Constants
    /// -----------------------------------------------------------------------

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// -----------------------------------------------------------------------
    /// ERC20Votes Storage
    /// -----------------------------------------------------------------------

    mapping(address => address) public delegates;

    mapping(address => Checkpoint[]) public checkpoints;
    
    Checkpoint[] public totalSupplyCheckpoints;

    /// -----------------------------------------------------------------------
    /// ERC20Votes Logic
    /// -----------------------------------------------------------------------

    /// @dev Gets the total number of checkpoints for 'account'
    function numCheckpoints(address account) public view virtual returns (uint256) {
        return checkpoints[account].length;
    }

    /// @dev Gets the current votes balance for `account`.
    function getVotes(address account) public view virtual returns (uint256) {
        uint256 pos = checkpoints[account].length;
        return pos == 0 ? 0 : checkpoints[account][pos - 1].votes;
    }

    /// @dev Retrieve the number of votes for `account` at the end of `blockNumber`.
    function getPastVotes(address account, uint256 blockNumber) public view virtual returns (uint256) {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(checkpoints[account], blockNumber);
    }

    /// @dev Retrieve the `totalSupply` at the end of `blockNumber`.
    function getPastTotalSupply(uint256 blockNumber) public view virtual returns (uint256) {
        require(blockNumber < block.number, "ERC20Votes: block not yet mined");
        return _checkpointsLookup(totalSupplyCheckpoints, blockNumber);
    }

    /// @dev Lookup a value in a list of (sorted) checkpoints.
    function _checkpointsLookup(Checkpoint[] storage ckpts, uint256 blockNumber) private view returns (uint256) {

        uint256 length = ckpts.length;
        uint256 low = 0;
        uint256 high = length;

        if (length > 5) {
            uint256 mid = length - FixedPointMathLib.sqrt(length);
            if (_unsafeAccess(ckpts, mid).fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        while (low < high) {
            uint256 mid = (low & high) + (low ^ high) >> 1;
            if (_unsafeAccess(ckpts, mid).fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return high == 0 ? 0 : _unsafeAccess(ckpts, high - 1).votes;
    }

    /// @dev Delegate votes from the sender to `delegatee`.
    function delegate(address delegatee) public virtual {
        _delegate(msg.sender, delegatee);
    }

    /// @dev Delegates votes from signer to `delegatee`
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(block.timestamp <= expiry, "DELEGATION_DEADLINE_EXPIRED");
        
        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                computeDigest(
                    keccak256(
                        abi.encode(
                            DELEGATION_TYPEHASH, 
                            delegatee, 
                            nonce, 
                            expiry
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0), "INVALID_SIGNATURE");

            require(nonce == nonces[recoveredAddress]++, "INVALID_NONCE");

            _delegate(recoveredAddress, delegatee);   
        }
    }

    /// @dev Maximum token supply. Defaults to `type(uint224).max` (2^224^ - 1).
    function _maxSupply() internal view virtual returns (uint224) {
        return type(uint224).max;
    }

    /// @dev Snapshots the totalSupply after it has been increased.
    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);

        require(totalSupply <= _maxSupply(), "ERC20Votes: total supply risks overflowing votes");

        _writeCheckpoint(totalSupplyCheckpoints, _add, amount);
    }

    /// @dev Snapshots the totalSupply after it has been decreased.
    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);

        _writeCheckpoint(totalSupplyCheckpoints, _subtract, amount);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        super.transfer(to, amount);

        _moveVotingPower(delegates[msg.sender], delegates[to], amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        super.transferFrom(from, to, amount);

        _moveVotingPower(delegates[from], delegates[to], amount);
    }


    /// @dev Change delegation for `delegator` to `delegatee`.
    function _delegate(address delegator, address delegatee) internal virtual {
        address currentDelegate = delegates[delegator];
        uint256 delegatorBalance = balanceOf[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveVotingPower(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveVotingPower(
        address src,
        address dst,
        uint256 amount
    ) private {
        if (src != dst && amount > 0) {
            if (src != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(checkpoints[src], _subtract, amount);
                emit DelegateVotesChanged(src, oldWeight, newWeight);
            }

            if (dst != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(checkpoints[dst], _add, amount);
                emit DelegateVotesChanged(dst, oldWeight, newWeight);
            }
        }
    }

    function _writeCheckpoint(
        Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) private returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;

        Checkpoint memory oldCkpt = pos == 0 ? Checkpoint(0, 0) : _unsafeAccess(ckpts, pos - 1);

        oldWeight = oldCkpt.votes;
        newWeight = op(oldWeight, delta);

        if (pos > 0 && oldCkpt.fromBlock == block.number) {
            _unsafeAccess(ckpts, pos - 1).votes = SafeCastLib.safeCastTo224(newWeight);
        } else {
            ckpts.push(Checkpoint({fromBlock: SafeCastLib.safeCastTo32(block.number), votes: SafeCastLib.safeCastTo224(newWeight)}));
        }
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }

    function _unsafeAccess(Checkpoint[] storage ckpts, uint256 pos) private pure returns (Checkpoint storage result) {
        assembly {
            mstore(0, ckpts.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }
}