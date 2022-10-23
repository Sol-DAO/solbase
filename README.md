# ⚡ Solbase

**Modern**, **opinionated**, and **gas optimized** base for **smart contract development**.

## Contracts

```ml
auth
├─ Owned — "Simple single owner authorization"
├─ Auth — "Flexible and updatable auth pattern"
├─ OwnedThreeStep — "Three-step single owner authorization mixin"
├─ OwnedRoles — "Simple single owner and multiroles authorization mixin"
├─ authorities
│  ├─ RolesAuthority — "Role based Authority that supports up to 256 roles"
│  ├─ MultiRolesAuthority — "Flexible and target agnostic role based Authority"
mixins
├─ ERC4626 — "Minimal ERC4626 tokenized Vault implementation"
tokens
├─ WETH — "Minimalist and modern Wrapped Ether implementation"
├─ ERC20 — "Modern, minimalist, and gas-optimized ERC20 implementation"
├─ ERC721 — "Modern, minimalist, and gas-optimized ERC721 implementation"
├─ ERC1155 — "Modern, minimalist, and gas-optimized ERC1155 implementation"
extensions
├─ ERC20Permit — "ERC20 + EIP-2612 implementation"
├─ ERC721Permit — "ERC721 + EIP-2612-style implementation"
├─ ERC1155Permit — "ERC1155 + EIP-2612-style implementation"
utils
├─ LibSort — "Optimized intro sort"
├─ LibClone — "Minimal proxy library"
├─ ECDSA — "Gas-optimized ECDSA wrapper"
├─ Base64 — "Library to encode strings in Base64"
├─ LibBit — "Library for bit twiddling operations"
├─ ERC165 — "Interface for contracts with ERC165 support"
├─ LibBytemap — "Efficient bytemap library for mapping integers to bytes"
├─ SSTORE2 — "Library for cheaper reads and writes to persistent storage"
├─ Clone — "Class with helper read functions for clone with immutable args"
├─ CREATE3 — "Deploy to deterministic addresses without an initcode factor"
├─ LibString — "Library for creating string representations of uint values"
├─ Permit — "Signature permit interface for any EIP-2612 or Dai-style token"
├─ SafeCastLib — "Safe unsigned integer casting lib that reverts on overflow"
├─ SelfPermit — "Signature permit helper for any EIP-2612 or Dai-style token"
├─ SignedWadMath — "Signed integer 18 decimal fixed point arithmetic library"
├─ ReentrancyGuard — "Gas-optimized reentrancy protection for smart contracts"
├─ MerkleProofLib — "Efficient merkle tree inclusion proof verification library"
├─ SafeCastLib — "Safe unsigned integer casting library that reverts on overflow"
├─ LibERC165 — "Library used to query support of an interface declared via ERC165"
├─ FixedPointMathLib — "Arithmetic library with operations for fixed-point numbers"
├─ Bytes32AddressLib — "Library for converting between addresses and bytes32 values"
├─ LibRLP — "Library for computing contract addresses from their deployer and nonce"
├─ LibBitMap — "Efficient bitmap library for mapping integers to single bit booleans"
├─ SafeTransferLib — "Safe ERC20/ETH transfer lib that handles missing return values"
├─ LibString — "Library for converting numbers into strings and other string operations"
├─ EIP712 — "Gas-optimized implementation of EIP-712 domain separator and digest encoding"
├─ Multicallable — "Contract that enables a single call to call multiple methods on itself"
├─ SafeMulticallable — "Contract that enables a single call to call multiple methods on itself"
├─ FixedPointMath — "Arithmetic free function collection with operations for fixed-point numbers"
├─ MerkleProofLib — "Gas-optimized verification of proof of inclusion for a leaf in a Merkle tree"
├─ SignatureCheckerLib — "Signature verification helper that supports both ECDSA signatures from EOAs"
├─ SafeTransfer — "Safe ETH and ERC20 free function transfer collection that gracefully handles missing return values"
```

## Safety

This is **experimental software** and is provided on an "as is" and "as available" basis.

While each [major release has been audited](audits), these contracts are **not designed with user safety** in mind:

- There are implicit invariants these contracts expect to hold.
- **You can easily shoot yourself in the foot if you're not careful.**
- You should thoroughly read each contract you plan to use top to bottom.

We **do not give any warranties** and **will not be liable for any loss** incurred through any use of this codebase.

## Installation

To install with [**Foundry**](https://github.com/gakonst/foundry):

```sh
forge install Sol-DAO/solbase
```

To install with [**Hardhat**](https://github.com/nomiclabs/hardhat) or [**Truffle**](https://github.com/trufflesuite/truffle):

```sh
npm install solbase
```

## Acknowledgements

These contracts were inspired by or directly modified from many sources, primarily:

- [Solmate](https://github.com/transmissions11/solmate)
- [Solady](https://github.com/Vectorized/solady)
- [Gnosis](https://github.com/gnosis/gp-v2-contracts)
- [Uniswap](https://github.com/Uniswap/uniswap-lib)
- [Dappsys](https://github.com/dapphub/dappsys)
- [Dappsys V2](https://github.com/dapp-org/dappsys-v2)
- [0xSequence](https://github.com/0xSequence)
- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)
