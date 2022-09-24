// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC1155} from "./utils/mocks/MockERC1155.sol";

contract ERC1155PermitTest is DSTestPlus {
    MockERC1155 token;

    bytes32 constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 id,uint256 nonce,uint256 deadline)");

    function setUp() public {
        token = new MockERC1155();
    }

    function testPermit() public {
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, address(0xCAFE), 0, 0, block.timestamp))
                )
            )
        );

        token.mint(owner, 0, 1, new bytes(0));
        token.permit(owner,address(0xCAFE), 0, block.timestamp, v, r, s);

        assertTrue(token.isApprovedForAll(owner, address(0xCAFE)));
        assertEq(token.nonces(owner, 0), 1);
    }

    function testFailPermitBadNonce() public {
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 0, 1, block.timestamp))
                )
            )
        );

        token.permit(owner, address(0xCAFE), 0, block.timestamp, v, r, s);
    }

    function testFailPermitBadDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 0, 0, block.timestamp))
                )
            )
        );

        token.mint(owner, 0, 1, new bytes(0));
        token.permit(owner,address(0xCAFE), 0, block.timestamp + 1, v, r, s);
    }

    function testFailPermitPastDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 0, 0, block.timestamp - 1))
                )
            )
        );

        token.mint(owner, 0, 1, new bytes(0));
        token.permit(owner,address(0xCAFE), 0, block.timestamp - 1, v, r, s);
    }

    function testFailPermitReplay() public {
        uint256 privateKey = 0xBEEF;
        address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 0, 0, block.timestamp))
                )
            )
        );

        token.mint(owner, 0, 1, new bytes(0));
        token.permit(owner, address(0xCAFE), 0, block.timestamp, v, r, s);
        token.permit(owner, address(0xCAFE), 0, block.timestamp, v, r, s);
    }
}