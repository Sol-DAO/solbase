// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC721} from "./utils/mocks/MockERC721.sol";

contract ERC721PermitTest is DSTestPlus {
    MockERC721 token;

    function setUp() public {
        token = new MockERC721("Token", "TKN");
    }

    /// -----------------------------------------------------------------------
    /// Helpers
    /// -----------------------------------------------------------------------

    // @dev 'keccak256("Permit(address spender,uint256 id,uint256 nonce,uint256 deadline)")'
    bytes32 public constant PERMIT_TYPEHASH = 0xf01eb1ca10960d4c3e51084e76fe5255d292d4b84c5297cdd41025ecd1f10ead;

    function computeDigest(address to, uint256 id, uint256 nonce, uint256 deadline) internal view virtual returns (bytes32) {
        bytes32 hashStruct = 
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH, 
                    to, 
                    id, 
                    nonce, 
                    deadline
                )
            );
        
        return keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), hashStruct));
    }

    /// -----------------------------------------------------------------------
    /// Tests
    /// -----------------------------------------------------------------------

    function testPermit() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, 0, block.timestamp));

        token.mint(owner, 0);
        token.permit(to, 0, block.timestamp, v, r, s);

        assertEq(token.getApproved(0), to);
        assertEq(token.nonces(0), 1);
    }

    function testPermitAll() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, type(uint256).max, 0, block.timestamp));

        token.mint(owner, 0);
        token.permit(to, type(uint256).max, block.timestamp, v, r, s);

        assertTrue(token.isApprovedForAll(owner, to));
        assertEq(token.nonces(type(uint256).max), 1);
    }

    function testFailPermitBadNonce() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, 1, block.timestamp));

        token.mint(owner, 0);
        token.permit(to, 0, block.timestamp, v, r, s);
    }

    function testFailPermitBadDeadline() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, 0, block.timestamp));

        token.mint(owner, 0);
        token.permit(to, 0, block.timestamp + 1, v, r, s);
    }

    function testFailPermitPastDeadline() public {
        
        hevm.warp(420); // forge's default block.timestamp is 0, thus the test would have failed regardless 
        
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, 0, block.timestamp - 1));

        token.mint(owner, 0);
        token.permit(to, 0, block.timestamp - 1, v, r, s);
    }

    function testFailPermitReplay() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, 0, block.timestamp));

        token.mint(owner, 0);
        token.permit(to, 0, block.timestamp, v, r, s);
        token.permit(to, 0, block.timestamp, v, r, s);
    }

    function testFailPermitAllReplay() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, type(uint256).max, 0, block.timestamp));

        token.permit(to, type(uint256).max, block.timestamp, v, r, s);
        token.permit(to, type(uint256).max, block.timestamp, v, r, s);
    }

    /// -----------------------------------------------------------------------
    /// Fuzz Tests
    /// -----------------------------------------------------------------------

    function testPermit(
        uint248 privateKey,
        address to,
        uint256 deadline
    ) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));
        hevm.assume(deadline >= block.timestamp);
        
        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, 0, deadline));

        address owner = hevm.addr(privateKey);
        
        token.mint(owner, 0);
        token.permit(to, 0, deadline, v, r, s);

        assertEq(token.getApproved(0), to);
        assertEq(token.nonces(0), 1);
    }

    function testFailPermitBadNonce(
        uint248 privateKey,
        address to,
        uint256 deadline,
        uint256 nonce
    ) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));
        hevm.assume(deadline >= block.timestamp);
        hevm.assume(nonce > 0); // bad nonce

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, nonce, deadline));

        address owner = hevm.addr(privateKey);
        
        token.mint(owner, 0);
        token.permit(to, 0, deadline, v, r, s);
    }

    function testFailPermitBadDeadline(
        uint248 privateKey,
        address to,
        uint256 deadline
    ) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));
        hevm.assume(deadline < block.timestamp); // bad deadline

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, 0, deadline));

        address owner = hevm.addr(privateKey);
        
        token.mint(owner, 0);
        token.permit(to, 0, deadline + 1, v, r, s);
    }

    function testFailPermitPastDeadline(
        uint248 privateKey,
        address to,
        uint256 deadline
    ) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));
        deadline = bound(deadline, 0, block.timestamp - 1);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, 0, deadline));

        address owner = hevm.addr(privateKey);
        
        token.mint(owner, 0);
        token.permit(to, 0, deadline, v, r, s);
    }

    function testFailPermitReplay(
        uint256 privateKey,
        address to,
        uint256 deadline
    ) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));
        hevm.assume(deadline >= block.timestamp);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(to, 0, 0, deadline));

        address owner = hevm.addr(privateKey);

        token.mint(owner, 0);
        token.permit(to, 0, deadline, v, r, s);
        token.permit(to, 0, deadline, v, r, s);
    }
}