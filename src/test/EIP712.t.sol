// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {EIP712} from "../utils/EIP712.sol";

contract MockEIP712 is EIP712 {
    constructor(string memory domainName, string memory version) EIP712(domainName, version) {}
}

contract EIP712Test is DSTestPlus {
    MockEIP712 mock;

    uint256 chainId;

    function setUp() public {
        mock = new MockEIP712("A Name", "1");

        chainId = block.chainid;
    }

    struct Message {
        address to;
        string message;
    }

    function testDigest() public {
        uint256 bobKey = 0xB0b;

        address bob = hevm.addr(bobKey);

        Message memory data = Message(address(this), "hey alice!");

        bytes32 hashStruct = keccak256(
            abi.encodePacked("\x19\x01", mock.DOMAIN_SEPARATOR(), keccak256(abi.encode(data)))
        );

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(bobKey, hashStruct);

        address recoveredAddress = ecrecover(hashStruct, v, r, s);

        assertEq(recoveredAddress, bob);
    }
}
