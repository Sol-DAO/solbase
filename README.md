# solbase

**Modern**, **opinionated**, and **gas optimized** base for **smart contract development**.

## Contracts

```ml
auth
├─ Owned — "Simple single owner authorization"
├─ Auth — "Flexible and updatable auth pattern"
├─ OwnedRoles — "Simple single owner and multiroles authorization mixin"
├─ ThreeStepOwned — "Three-step single owner authorization mixin"
├─ authorities
│  ├─ RolesAuthority — "Role based Authority that supports up to 256 roles"
│  ├─ MultiRolesAuthority — "Flexible and target agnostic role based Authority"
mixins
├─ ERC4626 — "Minimal ERC4626 tokenized Vault implementation"
tokens
├─ WETH — "Minimalist and modern Wrapped Ether implementation"
├─ ERC20 — "Modern and gas efficient ERC20 + EIP-2612 implementation"
├─ ERC721 — "Modern, minimalist, and gas efficient ERC721 implementation"
├─ ERC1155 — "Minimalist and gas efficient standard ERC1155 implementation"
utils
├─ LibSort — "Optimized intro sort"
├─ LibClone — "Minimal proxy library"
├─ ECDSA — "Gas optimized ECDSA wrapper"
├─ Base64 — "Library to encode strings in Base64"
├─ LibBit — "Library for bit twiddling operations"
├─ LibBytemap — "Efficient bytemap library for mapping integers to bytes"
├─ SSTORE2 — "Library for cheaper reads and writes to persistent storage"
├─ Clone — "Class with helper read functions for clone with immutable args"
├─ CREATE3 — "Deploy to deterministic addresses without an initcode factor"
├─ LibString — "Library for creating string representations of uint values"
├─ SafeCastLib — "Safe unsigned integer casting lib that reverts on overflow"
├─ SignedWadMath — "Signed integer 18 decimal fixed point arithmetic library"
├─ ReentrancyGuard — "Gas optimized reentrancy protection for smart contracts"
├─ MerkleProofLib — "Efficient merkle tree inclusion proof verification library"
├─ SafeCastLib — "Safe unsigned integer casting library that reverts on overflow"
├─ FixedPointMathLib — "Arithmetic library with operations for fixed-point numbers"
├─ Bytes32AddressLib — "Library for converting between addresses and bytes32 values"
├─ LibRLP — "Library for computing contract addresses from their deployer and nonce"
├─ LibBitMap — "Efficient bitmap library for mapping integers to single bit booleans"
├─ SafeTransferLib — "Safe ERC20/ETH transfer lib that handles missing return values"
├─ LibString — "Library for converting numbers into strings and other string operations"
├─ Multicallable — "Contract that enables a single call to call multiple methods on itself"
├─ MerkleProofLib — "Gas optimized verification of proof of inclusion for a leaf in a Merkle tree"
├─ SignatureCheckerLib — "Signature verification helper that supports both ECDSA signatures from EOAs"
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
