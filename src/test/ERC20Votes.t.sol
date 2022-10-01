// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";
import {MockERC20Votes} from "./utils/mocks/MockERC20Votes.sol";

contract ERC20VotesTest is DSTestPlus {

    bytes32 public constant DELEGATION_TYPEHASH
         = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

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

    function testSetDelegationWithoutBalance() public {

        assertEq(token.delegates(holder), address(0));

        hevm.prank(holder);
        token.delegate(holder);

        assertEq(token.delegates(holder), holder);
    }

    function testSetDelegationWithExistingDelegation() public {
        
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

    function testFailSetDelegationWithSigReplay() public {

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

    function testFailDelegationWithSigBadDelegate() public {
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

    function testFailDelegationWithSigBadNonce() public {
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

    function testFailDelegationWithSigExpired() public {
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
}