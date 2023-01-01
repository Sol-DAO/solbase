// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC1155} from "./utils/mocks/MockERC1155.sol";

contract ERC1155PermitTest is DSTestPlus {
    MockERC1155 token;

    function setUp() public {
        token = new MockERC1155();
    }

    /// -----------------------------------------------------------------------
    /// Helpers
    /// -----------------------------------------------------------------------

    // @dev 'keccak256("Permit(address owner,address spender,uint256 id,uint256 nonce,uint256 deadline)")'
    bytes32 public constant PERMIT_TYPEHASH = 0x29da74a9365f97c3d77de334aec5c720e44b0c8a6e640ceb375e27a8ab7acadd;

    function computeDigest(
        address owner,
        address to,
        uint256 id,
        uint256 nonce,
        uint256 deadline
    ) internal view virtual returns (bytes32) {
        bytes32 hashStruct = keccak256(abi.encode(PERMIT_TYPEHASH, owner, to, id, nonce, deadline));

        return keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), hashStruct));
    }

    /// -----------------------------------------------------------------------
    /// Tests
    /// -----------------------------------------------------------------------

    function testPermit() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(0xBEEF);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, 0, 0, block.timestamp));

        token.mint(owner, 0, 1, new bytes(0));
        token.permit(owner, to, 0, block.timestamp, v, r, s);

        assertTrue(token.isApprovedForAll(owner, to));
        assertEq(token.nonces(owner, 0), 1);
    }

    function testFailPermitBadNonce() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(0xBEEF);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, 0, 1, block.timestamp));

        token.mint(owner, 0, 1, new bytes(0));
        token.permit(owner, to, 0, block.timestamp, v, r, s);
    }

    function testFailPermitBadDeadline() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(0xBEEF);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, 0, 0, block.timestamp));

        token.mint(owner, 0, 1, new bytes(0));
        token.permit(owner, to, 0, block.timestamp + 1, v, r, s);
    }

    function testFailPermitPastDeadline() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(0xBEEF);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, 0, 0, block.timestamp - 1));

        token.mint(owner, 0, 1, new bytes(0));
        token.permit(owner, to, 0, block.timestamp - 1, v, r, s);
    }

    function testFailPermitReplay() public {
        address to = address(0xCAFE);
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(0xBEEF);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, 0, 0, block.timestamp));

        token.mint(owner, 0, 1, new bytes(0));
        token.permit(owner, to, 0, block.timestamp, v, r, s);
        token.permit(owner, to, 0, block.timestamp, v, r, s);
    }

    /// -----------------------------------------------------------------------
    /// Fuzz Tests
    /// -----------------------------------------------------------------------

    function testPermit(uint248 privateKey, uint256 id, address to) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));

        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, id, 0, block.timestamp));

        token.mint(owner, id, 1, new bytes(0));
        token.permit(owner, to, id, block.timestamp, v, r, s);

        assertTrue(token.isApprovedForAll(owner, to));
        assertEq(token.nonces(owner, id), 1);
    }

    function testFailPermitBadNonce(uint248 privateKey, uint256 id, address to, uint256 nonce) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));
        hevm.assume(nonce > 0);

        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, id, nonce, block.timestamp));

        token.mint(owner, id, 1, new bytes(0));
        token.permit(owner, to, id, block.timestamp, v, r, s);
    }

    function testFailPermitBadDeadline(uint248 privateKey, uint256 id, address to) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));

        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, id, 0, block.timestamp));

        token.mint(owner, id, 1, new bytes(0));
        token.permit(owner, to, id, block.timestamp + 1, v, r, s);
    }

    function testFailPermitPastDeadline(uint248 privateKey, uint256 id, address to) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));

        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, id, 0, block.timestamp - 1));

        token.mint(owner, id, 1, new bytes(0));
        token.permit(owner, to, id, block.timestamp - 1, v, r, s);
    }

    function testFailPermitReplay(uint248 privateKey, uint256 id, address to) public {
        hevm.assume(privateKey > 0);
        hevm.assume(to > address(0));

        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(privateKey, computeDigest(owner, to, id, 0, block.timestamp));

        token.mint(owner, id, 1, new bytes(0));
        token.permit(owner, to, id, block.timestamp, v, r, s);
        token.permit(owner, to, id, block.timestamp, v, r, s);
    }
}
