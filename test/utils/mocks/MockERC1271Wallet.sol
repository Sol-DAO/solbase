// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ECDSA} from "../../../src/utils/ECDSA.sol";

import {ERC721TokenReceiver} from "../../../src/tokens/ERC721/ERC721.sol";
import {ERC1155TokenReceiver} from "../../../src/tokens/ERC1155/ERC1155.sol";

contract MockERC1271Wallet is ERC721TokenReceiver, ERC1155TokenReceiver {
    address signer;

    constructor(address signer_) {
        signer = signer_;
    }

    function isValidSignature(bytes32 hash, bytes calldata signature) external view returns (bytes4) {
        return ECDSA.recover(hash, signature) == signer ? bytes4(0x1626ba7e) : bytes4(0);
    }
}
