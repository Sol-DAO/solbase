// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";
import {MockERC20Votes} from "./utils/mocks/MockERC20Votes.sol";

contract ERC20VotesTest is DSTestPlus {

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    MockERC20Votes token;

    address holder = address(0xCAFE);
    address holderDelegate = address(0xC0de);
    uint256 supply = 10_000_000 ether;

    function setUp() public {
        token = new MockERC20Votes("Token", "TKN");
    }

    /// @dev Theoretical max supply is 2**224.
    function testFailMintingRestriction() public {
        token.mint(address(this), type(uint224).max + 1);
    }

    function testSetDelegation() public {

        hevm.roll(420);

        token.mint(holder, supply);

        assertEq(token.delegates(holder), address(0));

        hevm.prank(holder);
        token.delegate(holder);

        assertEq(token.delegates(holder), holder);
        assertEq(token.getVotes(holder), supply);
        assertEq(token.getPastVotes(holder, block.number - 1), 0);

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(holder, block.number - 1), supply);
    }

    function testSetDelegation_WithoutBalance() public {

        assertEq(token.delegates(holder), address(0));

        hevm.prank(holder);
        token.delegate(holder);

        assertEq(token.delegates(holder), holder);
    }

    function testSetDelegation_WithExistingDelegation() public {
        
        hevm.roll(420);

        address delegatee = address(0xD3136473);

        token.mint(holder, supply);

        hevm.prank(holder);
        token.delegate(holder);

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(holder, block.number - 1), supply);
        assertEq(token.getPastVotes(delegatee, block.number - 1), 0);
        assertEq(token.delegates(holder), holder);

        hevm.prank(holder);
        token.delegate(delegatee);

        assertEq(token.delegates(holder), delegatee);
        assertEq(token.getVotes(holder), 0);
        assertEq(token.getVotes(delegatee), supply);

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(holder, block.number - 1), 0);
        assertEq(token.getPastVotes(delegatee, block.number - 1), supply);
    }

    function testSetDelegationWithSig() public {

        hevm.roll(420);

        uint256 privateKey = uint256(0xB0b);
        address owner = hevm.addr(privateKey);
        uint256 nonce = 0;
        uint256 expiry = type(uint256).max;

        token.mint(owner, supply);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(token.DELEGATION_TYPEHASH(), owner, nonce, expiry))
                )
            )
        );
        
        assertEq(token.delegates(owner), address(0));

        token.delegateBySig(owner, nonce, expiry, v, r, s);

        assertEq(token.delegates(owner), owner);
        assertEq(token.getVotes(owner), supply);
        assertEq(token.getPastVotes(owner, block.number - 1), 0);

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(owner, block.number - 1), supply);
    }

    function testFailSetDelegationWithSig_Replay() public {

        hevm.roll(420);

        uint256 privateKey = uint256(0xB0b);
        address owner = hevm.addr(privateKey);
        uint256 nonce = 0;
        uint256 expiry = type(uint256).max;

        token.mint(owner, supply);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(token.DELEGATION_TYPEHASH(), owner, nonce, expiry))
                )
            )
        );
        
        assertEq(token.delegates(owner), address(0));

        token.delegateBySig(owner, nonce, expiry, v, r, s);
        token.delegateBySig(owner, nonce, expiry, v, r, s);
    }

    function testFailDelegationWithSig_BadDelegate() public {
        // it('rejects bad delegatee', async function () {
        // const { v, r, s } = fromRpcSig(ethSigUtil.signTypedMessage(
        //     delegator.getPrivateKey(),
        //     buildData(this.chainId, this.token.address, {
        //     delegatee: delegatorAddress,
        //     nonce,
        //     expiry: MAX_UINT256,
        //     }),
        // ));

        // const receipt = await this.token.delegateBySig(holderDelegatee, nonce, MAX_UINT256, v, r, s);
        // const { args } = receipt.logs.find(({ event }) => event == 'DelegateChanged');
        // expect(args.delegator).to.not.be.equal(delegatorAddress);
        // expect(args.fromDelegate).to.be.equal(ZERO_ADDRESS);
        // expect(args.toDelegate).to.be.equal(holderDelegatee);

        hevm.roll(420);

        uint256 privateKey = uint256(0xB0b);
        address owner = hevm.addr(privateKey);
        uint256 nonce = 0;
        uint256 expiry = type(uint256).max;

        token.mint(owner, supply);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(token.DELEGATION_TYPEHASH(), owner, nonce, expiry))
                )
            )
        );

        // NOTE: this doesn't fail by itself, kinda sketchy
        token.delegateBySig(address(0xBAD), nonce, expiry, v, r, s);
    }

    function testFailDelegation_WithSigBadNonce() public {
        hevm.roll(420);

        uint256 privateKey = uint256(0xB0b);
        address owner = hevm.addr(privateKey);
        uint256 nonce = 1; // bad nonce
        uint256 expiry = type(uint256).max;

        token.mint(owner, supply);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(token.DELEGATION_TYPEHASH(), owner, nonce, expiry))
                )
            )
        );

        token.delegateBySig(address(0xBAD), nonce, expiry, v, r, s);
    }

    function testFailDelegation_WithSigExpired() public {
        hevm.roll(420);
        hevm.warp(420);

        uint256 privateKey = uint256(0xB0b);
        address owner = hevm.addr(privateKey);
        uint256 nonce = 0;
        uint256 expiry = block.timestamp - 1; // bad expiry

        token.mint(owner, supply);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(token.DELEGATION_TYPEHASH(), owner, nonce, expiry))
                )
            )
        );
        
        token.delegateBySig(address(0xBAD), nonce, expiry, v, r, s);
    }

    function testTransfer_WithoutExistingDelegation() public {
        
        address to = address(0xc0de);

        token.mint(holder, supply);

        hevm.prank(holder);
        token.transfer(to, 1 ether);

        assertEq(token.getVotes(holder), 0);
        assertEq(token.getVotes(to), 0);

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(holder, block.number - 1), 0);
        assertEq(token.getPastVotes(to, block.number - 1), 0);
    }

    function testTransfer_WithExistingSelfDelegation() public {
        
        address to = address(0xc0de);

        token.mint(holder, supply);

        hevm.startPrank(holder);
        
        token.delegate(holder);
        token.transfer(to, 1 ether);

        hevm.stopPrank();

        assertEq(token.getVotes(holder), supply - 1 ether);
        assertEq(token.getVotes(to), 0);

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(holder, block.number - 1), supply - 1 ether);
        assertEq(token.getPastVotes(to, block.number - 1), 0);
    }

    function testTransfer_WithExistingReceiverDelegation() public {
        
        address to = address(0xc0de);

        token.mint(holder, supply);

        hevm.startPrank(holder);
        
        token.delegate(to);
        token.transfer(to, 1 ether);

        hevm.stopPrank();

        assertEq(token.getVotes(holder), 0);
        assertEq(token.getVotes(to), supply - 1 ether);

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(holder, block.number - 1), 0);
        assertEq(token.getPastVotes(to, block.number - 1), supply - 1 ether);
    }
    
    function testTransfer_WithFullDelegation() public {
        
        address to = address(0xc0de);

        token.mint(holder, supply);

        hevm.startPrank(holder);
        
        token.delegate(holder);
        token.delegate(to);
        token.transfer(to, 1 ether);

        hevm.stopPrank();

        assertEq(token.getVotes(holder), 0);
        assertEq(token.getVotes(to), supply - 1 ether);

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(holder, block.number - 1), 0);
        assertEq(token.getPastVotes(to, block.number - 1), supply - 1 ether);
    }

    /// -----------------------------------------------------------------------
    /// Compound Tests
    /// -----------------------------------------------------------------------

    function testNumCheckpoints() public {

        address to = address(0xc0de);
        address otherTo = address(0xb0b);

        token.mint(holder, supply);

        hevm.prank(holder);
        token.transfer(to, 100);
        assertEq(token.numCheckpoints(to), 0);

        hevm.roll(block.number + 1);
        uint256 t1 = block.number;

        hevm.prank(to);
        token.delegate(otherTo);
        assertEq(token.numCheckpoints(otherTo), 1);

        hevm.roll(block.number + 1);
        uint256 t2 = block.number;

        hevm.prank(to);
        token.transfer(otherTo, 10);
        assertEq(token.numCheckpoints(otherTo), 2);

        hevm.roll(block.number + 1);
        uint256 t3 = block.number;

        hevm.prank(to);
        token.transfer(otherTo, 10);
        assertEq(token.numCheckpoints(otherTo), 3);

        hevm.roll(block.number + 1);
        uint256 t4 = block.number;

        hevm.prank(holder);
        token.transfer(to, 20);
        assertEq(token.numCheckpoints(otherTo), 4);

        (uint256 fromBlock, uint256 votes) = token.checkpoints(otherTo, 0);
        assertEq(fromBlock, t1);
        assertEq(votes, 100);

        (fromBlock, votes) = token.checkpoints(otherTo, 1);
        assertEq(fromBlock, t2);
        assertEq(votes, 90);

        (fromBlock, votes) = token.checkpoints(otherTo, 2);
        assertEq(fromBlock, t3);
        assertEq(votes, 80);

        (fromBlock, votes) = token.checkpoints(otherTo, 3);
        assertEq(fromBlock, t4);
        assertEq(votes, 100);

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(otherTo, t1), 100);
        assertEq(token.getPastVotes(otherTo, t2), 90);
        assertEq(token.getPastVotes(otherTo, t3), 80);
        assertEq(token.getPastVotes(otherTo, t4), 100);   
    }

    function testNumCheckpoints_OnlySingleCheckpointPerBlock() public {

        address to = address(0xc0de);
        address otherTo = address(0xb0b);

        token.mint(holder, supply);

        hevm.startPrank(holder);

        token.delegate(holder);
        token.transfer(to, 100);

        hevm.stopPrank();

        assertEq(token.numCheckpoints(otherTo), 0);

        hevm.startPrank(to);
        
        token.delegate(otherTo);
        token.transfer(otherTo, 10);
        token.transfer(otherTo, 10);

        hevm.stopPrank();

        assertEq(token.numCheckpoints(otherTo), 1);

        (uint256 fromBlock, uint256 votes) = token.checkpoints(otherTo, 0);
        assertEq(fromBlock, 0);
        assertEq(votes, 80);

        hevm.roll(block.number + 1);

        hevm.prank(holder);
        token.transfer(to, 20);

        assertEq(token.numCheckpoints(otherTo), 2);

        (fromBlock, votes) = token.checkpoints(otherTo, 1);
        assertEq(fromBlock, 1);
        assertEq(votes, 100);
    }

    function testFailGetPastVotes_RevertOnCurrentBlockAndGreater() public {
        token.getPastVotes(holder, block.number + 1);
    }

    function testGetPastVotes_ReturnsZeroWithoutExistingCheckpoints() public {
        hevm.roll(block.number + 1);
        assertEq(token.getPastVotes(holder, 0), 0);
    }

    function testGetPastVotes_ReturnsLastestBlockIfInputIsGreaterThanCurrentBlock() public {

        address to = address(0xc0de);

        token.mint(holder, supply);

        hevm.prank(holder);
        token.delegate(to);

        hevm.roll(block.number + 2);

        assertEq(token.getPastVotes(to, block.number - 1), supply);
        assertEq(token.getPastVotes(to, block.number - 2), supply);
    }

    function testGetPastVotes_ReturnsZeroIfInputIsLessThanFirstCheckpointBlock() public {
        
        address to = address(0xc0de);

        hevm.roll(block.number + 1);

        token.mint(holder, supply);
        
        hevm.prank(holder);
        token.delegate(to);

        hevm.roll(block.number + 2);

        assertEq(token.getPastVotes(to, block.number - 3), 0);
        assertEq(token.getPastVotes(to, block.number - 1), supply);
    }

    function testGetPastVotes_ReturnsCorrectVotingBalancePerCheckpoint() public {

        address to = address(0xc0de);

        hevm.roll(block.number + 1);
        uint256 t1 = block.number;

        token.mint(holder, supply);

        hevm.prank(holder);
        token.delegate(to);

        hevm.roll(block.number + 2);
        uint256 t2 = block.number;

        hevm.prank(holder);
        token.transfer(to, 10);

        hevm.roll(block.number + 2);
        uint256 t3 = block.number;

        hevm.prank(holder);
        token.transfer(to, 10);

        hevm.roll(block.number + 2);
        uint256 t4 = block.number;

        hevm.prank(to);
        token.transfer(holder, 20);

        hevm.roll(block.number + 2);

        assertEq(token.getPastVotes(to, t1 - 1), 0);
        assertEq(token.getPastVotes(to, t1), supply);

        assertEq(token.getPastVotes(to, t1 + 1), supply);
        assertEq(token.getPastVotes(to, t2), supply - 10);

        assertEq(token.getPastVotes(to, t2 + 1), supply - 10);
        assertEq(token.getPastVotes(to, t3), supply - 20);
        
        assertEq(token.getPastVotes(to, t3 + 1), supply - 20);
        assertEq(token.getPastVotes(to, t4), supply);

        assertEq(token.getPastVotes(to, t4 + 1), supply);
    }

    function testFailGetPastTotalSupply_RevertOnCurrentBlockAndGreater() public {
        token.getPastTotalSupply(block.number + 1);
    }

    function testGetPastTotalSupply_ReturnsZeroWhenNoExistingCheckpoints() public {
        hevm.roll(block.number + 1);
        assertEq(token.getPastTotalSupply(0), 0);
    }
    
    function testGetPastTotalSupply_ReturnsLatestBlockOnCurrentBlockOrGreater() public {

        token.mint(holder, supply);

        hevm.roll(block.number + 2);

        assertEq(token.getPastTotalSupply(block.number - 1), supply);
        assertEq(token.getPastTotalSupply(block.number - 2), supply);
    }
    
    function testGetPastTotalSupply_ReturnsZeroIfLessThanFirstCheckpointBlock() public {

        hevm.roll(block.number + 1);

        token.mint(holder, supply);

        hevm.roll(block.number + 2);

        assertEq(token.getPastTotalSupply(block.number - 3), 0);
        assertEq(token.getPastTotalSupply(block.number - 1), supply);
    }

    function testGetPastTotalSupply_ReturnsCorrectVotingBalancePerCheckpoint() public {

        hevm.roll(block.number + 1);
        uint256 t1 = block.number;

        token.mint(holder, supply);

        hevm.roll(block.number + 2);
        uint256 t2 = block.number;

        token.burn(holder, 10);

        hevm.roll(block.number + 2);
        uint256 t3 = block.number;

        token.burn(holder, 10);

        hevm.roll(block.number + 2);
        uint256 t4 = block.number;

        token.mint(holder, 20);

        hevm.roll(block.number + 2);

        assertEq(token.getPastTotalSupply(t1 - 1), 0);
        assertEq(token.getPastTotalSupply(t1), supply);

        assertEq(token.getPastTotalSupply(t1 + 1), supply);
        assertEq(token.getPastTotalSupply(t2), supply - 10);

        assertEq(token.getPastTotalSupply(t2 + 1), supply - 10);
        assertEq(token.getPastTotalSupply(t3), supply - 20);

        assertEq(token.getPastTotalSupply(t3 + 1), supply - 20);
        assertEq(token.getPastTotalSupply(t4), supply);
        assertEq(token.getPastTotalSupply(t4 + 1), supply);
    }
}