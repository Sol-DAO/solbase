// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockOwnedThreeStep} from "./utils/mocks/MockOwnedThreeStep.sol";

contract ThreeStepOwnedTest is DSTestPlus {
    MockOwnedThreeStep mockOwnedThreeStep;

    function setUp() public {
        mockOwnedThreeStep = new MockOwnedThreeStep();
    }

    function testSetOwner() public {
        testSetOwner(address(0xBEEF));
    }

    function testCallFunctionAsNonOwner() public {
        address nonOwner = address(0xBAD);

        assertFalse(mockOwnedThreeStep.owner() == nonOwner);

        hevm.prank(nonOwner);
        hevm.expectRevert("UNAUTHORIZED");
        mockOwnedThreeStep.setOwner(address(0xC0FFEE));

        assertEq(mockOwnedThreeStep.owner(), address(this));
    }

    function testCallFunctionAsOwner() public {
        mockOwnedThreeStep.updateFlag();
    }

    function testCallFunctionAsOwnerAfterUpdatingIt() public {
        address newOwner = address(0xCAFE);
        testSetOwner(newOwner);

        hevm.prank(newOwner);
        mockOwnedThreeStep.updateFlag();
    }

    function testRenounceOwner() public {
        mockOwnedThreeStep.renounceOwner();

        assertEq(mockOwnedThreeStep.owner(), address(0));

        hevm.expectRevert("UNAUTHORIZED");
        mockOwnedThreeStep.updateFlag();
    }

    function testRenounceOwnerAsNonOwner() public {
        address nonOwner = address(0xBAD);
        assertFalse(mockOwnedThreeStep.owner() == nonOwner);

        hevm.prank(nonOwner);
        hevm.expectRevert("UNAUTHORIZED");
        mockOwnedThreeStep.renounceOwner();
    }

    function testConfirmOwnerAfterRenounceOwner() public {
        address newOwner = address(0xC0FFEE);
        mockOwnedThreeStep.setOwner(newOwner);

        mockOwnedThreeStep.renounceOwner();
        assertEq(mockOwnedThreeStep.owner(), address(0));

        hevm.prank(newOwner);
        mockOwnedThreeStep.confirmOwner();

        hevm.expectRevert("UNAUTHORIZED");
        mockOwnedThreeStep.confirmOwner();
    }

    function testConfirmOwnerInWrongOrder() public {
        mockOwnedThreeStep.setOwner(address(0xC0FFEE));

        hevm.expectRevert("UNAUTHORIZED");
        mockOwnedThreeStep.confirmOwner();
    }

    function testSetOwner(address newOwner) public {
        mockOwnedThreeStep.setOwner(newOwner);

        assertEq(mockOwnedThreeStep.owner(), address(this));

        hevm.prank(newOwner);
        mockOwnedThreeStep.confirmOwner();

        assertEq(mockOwnedThreeStep.owner(), address(this));

        mockOwnedThreeStep.confirmOwner();

        assertEq(mockOwnedThreeStep.owner(), newOwner);
    }
}
