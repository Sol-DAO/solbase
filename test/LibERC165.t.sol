// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "forge-std/Test.sol";

import {LibERC165} from "../src/utils/LibERC165.sol";
import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {MockERC721} from "./utils/mocks/MockERC721.sol";

contract LibERC165test is Test {
    using LibERC165 for address;

    address token;
    address nft;

    function setUp() public {
        token = address(new MockERC20("Token", "TKN", 18));
        nft = address(new MockERC721("Token", "TKN"));
    }

    function testSupportsERC165() public payable {
        assert(nft.supportsERC165());
    }

    function testSupportsERC165Fail() public payable {
        assert(!token.supportsERC165());
    }

    function testSupportsInterface() public payable {
        assert(nft.supportsInterface(0x80ac58cd));
    }

    function testSupportsInterfaceFail() public payable {
        assert(!nft.supportsInterface(0xd9b67a26));
    }

    function testSupportsERC165InterfaceUnchecked() public payable {
        assert(nft.supportsERC165InterfaceUnchecked(0x80ac58cd));
    }

    function testSupportsERC165InterfaceUncheckedFail() public payable {
        assert(!nft.supportsERC165InterfaceUnchecked(0xd9b67a26));
    }
}
