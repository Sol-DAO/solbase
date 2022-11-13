// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Arithmetic free function collection with operations for fixed-point numbers.
/// @author Solbase (https://github.com/Sol-DAO/solbase/blob/main/src/utils/FixedPointMath.sol)
/// @author Modified from Solady (https://github.com/vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol)

/// @dev The multiply-divide operation failed, either due to a
/// multiplication overflow, or a division by a zero.
error MulDivFailed();

/// @dev The maximum possible integer.
uint256 constant MAX_UINT256 = 2 ** 256 - 1;

/// @dev Returns `floor(x * y / denominator)`.
/// Reverts if `x * y` overflows, or `denominator` is zero.
function mulDivDown(uint256 x, uint256 y, uint256 denominator) pure returns (uint256 z) {
    assembly {
        // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
        if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
            // Store the function selector of `MulDivFailed()`.
            mstore(0x00, 0xad251c27)
            // Revert with (offset, size).
            revert(0x1c, 0x04)
        }

        // Divide x * y by the denominator.
        z := div(mul(x, y), denominator)
    }
}

/// @dev Returns `ceil(x * y / denominator)`.
/// Reverts if `x * y` overflows, or `denominator` is zero.
function mulDivUp(uint256 x, uint256 y, uint256 denominator) pure returns (uint256 z) {
    assembly {
        // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
        if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
            // Store the function selector of `MulDivFailed()`.
            mstore(0x00, 0xad251c27)
            // Revert with (offset, size).
            revert(0x1c, 0x04)
        }

        // If x * y modulo the denominator is strictly greater than 0,
        // 1 is added to round up the division of x * y by the denominator.
        z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
    }
}
