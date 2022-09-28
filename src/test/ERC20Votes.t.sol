// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC20Votes} from "./utils/mocks/MockERC20Votes.sol";

contract ERC20VotesTest is DSTestPlus {

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

    function testChangeDelegation() public {

        hevm.roll(420);

        token.mint(holder, supply);

        hevm.prank(holder);
        token.delegate(holder);

        assertEq(token.delegates(holder), holder);

        hevm.prank(holder);
        token.delegate(holderDelegate);

        assertEq(token.delegates(holder), holderDelegate);
        
        assertEq(token.getVotes(holder), 0);
        assertEq(token.getVotes(holderDelegate), supply);

        assertEq(token.getPastVotes(holder, block.number - 1), supply);
        assertEq(token.getPastVotes(holderDelegate, block.number - 1), 0);

        // TODO: code under this fails

        hevm.roll(block.number + 1);

        assertEq(token.getPastVotes(holder, block.number - 1), 0);
        assertEq(token.getPastVotes(holderDelegate, block.number - 1), supply);
    }
}