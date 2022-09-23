// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC20Permit} from "../../../tokens/ERC20/extensions/ERC20Permit.sol";
import {ERC4626} from "../../../mixins/ERC4626.sol";

contract MockERC4626 is ERC4626 {
    uint256 public beforeWithdrawHookCalledCounter;
    uint256 public afterDepositHookCalledCounter;

    constructor(
        ERC20Permit _underlying,
        string memory _name,
        string memory _symbol
    ) ERC4626(_underlying, _name, _symbol) {}

    function totalAssets() public view override returns (uint256) {
        return ERC20Permit(asset).balanceOf(address(this));
    }

    function beforeWithdraw(uint256, uint256) internal override {
        unchecked {
            beforeWithdrawHookCalledCounter++;
        }
    }

    function afterDeposit(uint256, uint256) internal override {
        unchecked {
            afterDepositHookCalledCounter++;
        }
    }
}
