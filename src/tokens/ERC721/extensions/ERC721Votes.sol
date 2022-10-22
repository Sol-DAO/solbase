// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721Permit} from "./ERC721Permit.sol";
import {SafeCastLib} from "../../../utils/SafeCastLib.sol";
import {FixedPointMathLib} from "../../../utils/FixedPointMathLib.sol";

struct Checkpoint {
    uint32 fromBlock;
    uint224 votes;
}

/// @notice ERC721-compatible voting and delegation implementation.
/// @author SolDAO (https://github.com/Sol-DAO/solbase/blob/main/src/tokens/ERC721/extensions/ERC721Votes.sol)
abstract contract ERC721Votes is ERC721Permit {
    /// -----------------------------------------------------------------------
    /// ERC721Votes Events
    /// -----------------------------------------------------------------------

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /// -----------------------------------------------------------------------
    /// Custom Errors
    /// -----------------------------------------------------------------------

    error Undetermined();

    error DelegationSigExpired();

    error SupplyMaxed();

    /// -----------------------------------------------------------------------
    /// ERC721Votes Constants
    /// -----------------------------------------------------------------------

    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// -----------------------------------------------------------------------
    /// ERC721Votes Storage
    /// -----------------------------------------------------------------------

    mapping(address => address) public delegates;

    mapping(address => uint256) public delegateNonces;

    mapping(address => Checkpoint[]) public checkpoints;

    Checkpoint[] public totalSupplyCheckpoints;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(string memory _name, string memory _symbol) ERC721Permit(_name, _symbol) {}

    /// -----------------------------------------------------------------------
    /// ERC721Votes Logic
    /// -----------------------------------------------------------------------

    /// @dev Gets the total number of checkpoints for `account`.
    function numCheckpoints(address account) public view virtual returns (uint256) {
        return checkpoints[account].length;
    }

    /// @dev Gets the current votes balance for `account`.
    function getVotes(address account) public view virtual returns (uint256) {
        uint256 pos = checkpoints[account].length;

        // Cannot underflow as value is confirmed as positive before arithmetic.
        unchecked {
            return pos == 0 ? 0 : checkpoints[account][pos - 1].votes;
        }
    }

    /// @dev Retrieve the number of votes for `account` at the end of `blockNumber`.
    function getPastVotes(address account, uint256 blockNumber) public view virtual returns (uint256) {
        if (block.number <= blockNumber) revert Undetermined();

        return _checkpointsLookup(checkpoints[account], blockNumber);
    }

    /// @dev Retrieve the `totalSupply` at the end of `blockNumber`.
    function getPastTotalSupply(uint256 blockNumber) public view virtual returns (uint256) {
        if (block.number <= blockNumber) revert Undetermined();

        return _checkpointsLookup(totalSupplyCheckpoints, blockNumber);
    }

    /// @dev Lookup a value in a list of (sorted) checkpoints.
    function _checkpointsLookup(Checkpoint[] storage ckpts, uint256 blockNumber) internal view returns (uint256) {
        uint256 length = ckpts.length;
        uint256 low;
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
            uint256 mid = ((low & high) + (low ^ high)) >> 1;

            if (_unsafeAccess(ckpts, mid).fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // Cannot underflow as value is confirmed as positive before arithmetic.
        unchecked {
            return high == 0 ? 0 : _unsafeAccess(ckpts, high - 1).votes;
        }
    }

    /// @dev Delegate votes from the sender to `delegatee`.
    function delegate(address delegatee) public virtual {
        _delegate(msg.sender, delegatee);
    }

    /// @dev Delegates votes from signer to `delegatee`
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) revert DelegationSigExpired();

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                computeDigest(keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, deadline))),
                v,
                r,
                s
            );

            if (recoveredAddress == address(0)) revert InvalidSigner();

            if (nonce != delegateNonces[recoveredAddress]++) revert InvalidSigner();

            _delegate(recoveredAddress, delegatee);
        }
    }

    /// @dev Snapshots the totalSupply after it has been increased.
    function _mint(address to, uint256 id) internal virtual override {
        super._mint(to, id);

        _writeCheckpoint(totalSupplyCheckpoints, _add, 1);
    }

    /// @dev Snapshots the totalSupply after it has been decreased.
    function _burn(uint256 id) internal virtual override {
        super._burn(id);

        _writeCheckpoint(totalSupplyCheckpoints, _subtract, 1);
    }

    /// @dev Performs ERC721 transferFrom with delegation tracking.
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        _moveVotingPower(delegates[from], delegates[to], 1);

        super.transferFrom(from, to, id);
    }

    /// @dev Performs ERC721 safeTransferFrom with delegation tracking.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        _moveVotingPower(delegates[from], delegates[to], 1);

        super.safeTransferFrom(from, to, id);
    }

    /// @dev Performs ERC721 safeTransferFrom (data) with delegation tracking.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual override {
        _moveVotingPower(delegates[from], delegates[to], 1);

        super.safeTransferFrom(from, to, id, data);
    }

    /// @dev Change delegation for `delegator` to `delegatee`.
    function _delegate(address delegator, address delegatee) internal virtual {
        address currentDelegate = delegates[delegator];

        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveVotingPower(currentDelegate, delegatee, balanceOf(delegator));
    }

    function _moveVotingPower(
        address src,
        address dst,
        uint256 amount
    ) internal virtual {
        if (src != dst && amount != 0) {
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
    ) internal virtual returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;

        // Cannot underflow as value is confirmed as positive before arithmetic.
        unchecked {
            Checkpoint memory oldCkpt = pos == 0 ? Checkpoint(0, 0) : _unsafeAccess(ckpts, pos - 1);

            oldWeight = oldCkpt.votes;
            newWeight = op(oldWeight, delta);

            if (pos != 0 && oldCkpt.fromBlock == block.number) {
                _unsafeAccess(ckpts, pos - 1).votes = SafeCastLib.safeCastTo224(newWeight);
            } else {
                ckpts.push(
                    Checkpoint({
                        fromBlock: SafeCastLib.safeCastTo32(block.number),
                        votes: SafeCastLib.safeCastTo224(newWeight)
                    })
                );
            }
        }
    }

    function _add(uint256 a, uint256 b) internal pure virtual returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) internal pure virtual returns (uint256) {
        return a - b;
    }

    function _unsafeAccess(Checkpoint[] storage ckpts, uint256 pos)
        internal
        pure
        virtual
        returns (Checkpoint storage result)
    {
        assembly {
            mstore(0, ckpts.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }
}
