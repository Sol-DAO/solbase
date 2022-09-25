// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC721} from "./utils/mocks/MockERC721.sol";

contract ERC721PermitTest is DSTestPlus {
    MockERC721 token;

    bytes32 constant PERMIT_TYPEHASH = keccak256("Permit(address spender,uint256 id,uint256 nonce,uint256 deadline)");

    function setUp() public {
        token = new MockERC721("Token", "TKN");
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

        token.mint(owner, 0);
        token.permit(address(0xCAFE), 0, block.timestamp, v, r, s);

        assertEq(token.getApproved(0), address(0xCAFE));
        assertEq(token.nonces(0), 1);
    }

    function testPermitAll() public {
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

        token.mint(owner, 0);
        token.permit(address(0xCAFE), 0, block.timestamp, v, r, s);

        assertEq(token.getApproved(0), address(0xCAFE));
        assertEq(token.nonces(0), 1);
    }

    function testFailPermitBadNonce() public {
        uint256 privateKey = 0xBEEF;
        //address owner = hevm.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, address(0xCAFE), type(uint256).max, 1, block.timestamp))
                )
            )
        );

        token.permit(address(0xCAFE), 0, block.timestamp, v, r, s);
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
                    keccak256(abi.encode(PERMIT_TYPEHASH, address(0xCAFE), type(uint256).max, 0, block.timestamp))
                )
            )
        );

        token.mint(owner, 0);
        token.permit(address(0xCAFE), 0, block.timestamp + 1, v, r, s);
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
                    keccak256(abi.encode(PERMIT_TYPEHASH, address(0xCAFE), type(uint256).max, 0, block.timestamp - 1))
                )
            )
        );

        token.mint(owner, 0);
        token.permit(address(0xCAFE), 0, block.timestamp - 1, v, r, s);
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
                    keccak256(abi.encode(PERMIT_TYPEHASH, address(0xCAFE), 0, 0, block.timestamp))
                )
            )
        );

        token.mint(owner, 0);
        token.permit(address(0xCAFE), 0, block.timestamp, v, r, s);
        token.permit(address(0xCAFE), 0, block.timestamp, v, r, s);
    }
}
