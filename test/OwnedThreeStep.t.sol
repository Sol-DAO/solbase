// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockOwnedThreeStep} from "./utils/mocks/MockOwnedThreeStep.sol";

contract ThreeStepOwnedTest is DSTestPlus {
    error Unauthorized();

    MockOwnedThreeStep mockOwnedThreeStep;

    function setUp() public payable {
        mockOwnedThreeStep = new MockOwnedThreeStep();
    }

    function testSetOwner() public payable {
        testSetOwner(address(0xBEEF));
    }

    function testCallFunctionAsNonOwner() public payable {
        address nonOwner = address(0xBAD);

        assertFalse(mockOwnedThreeStep.owner() == nonOwner);

        hevm.prank(nonOwner);
        hevm.expectRevert(Unauthorized.selector);
        mockOwnedThreeStep.transferOwnership(address(0xC0FFEE));

        assertEq(mockOwnedThreeStep.owner(), address(this));
    }

    function testCallFunctionAsOwner() public payable {
        mockOwnedThreeStep.updateFlag();
    }

    function testCallFunctionAsOwnerAfterUpdatingIt() public payable {
        address newOwner = address(0xCAFE);
        testSetOwner(newOwner);

        hevm.prank(newOwner);
        mockOwnedThreeStep.updateFlag();
    }

    function testRenounceOwner() public payable {
        mockOwnedThreeStep.renounceOwner();

        assertEq(mockOwnedThreeStep.owner(), address(0));

        hevm.expectRevert(Unauthorized.selector);
        mockOwnedThreeStep.updateFlag();
    }

    function testRenounceOwnerAsNonOwner() public payable {
        address nonOwner = address(0xBAD);
        assertFalse(mockOwnedThreeStep.owner() == nonOwner);

        hevm.prank(nonOwner);
        hevm.expectRevert(Unauthorized.selector);
        mockOwnedThreeStep.renounceOwner();
    }

    function testConfirmOwnerAfterRenounceOwner() public payable {
        address newOwner = address(0xC0FFEE);
        mockOwnedThreeStep.transferOwnership(newOwner);

        mockOwnedThreeStep.renounceOwner();
        assertEq(mockOwnedThreeStep.owner(), address(0));

        hevm.prank(newOwner);
        mockOwnedThreeStep.confirmOwner();

        hevm.expectRevert(Unauthorized.selector);
        mockOwnedThreeStep.confirmOwner();
    }

    function testConfirmOwnerInWrongOrder() public payable {
        mockOwnedThreeStep.transferOwnership(address(0xC0FFEE));

        hevm.expectRevert(Unauthorized.selector);
        mockOwnedThreeStep.confirmOwner();
    }

    function testSetOwner(address newOwner) public payable {
        mockOwnedThreeStep.transferOwnership(newOwner);

        assertEq(mockOwnedThreeStep.owner(), address(this));

        hevm.prank(newOwner);
        mockOwnedThreeStep.confirmOwner();

        assertEq(mockOwnedThreeStep.owner(), address(this));

        mockOwnedThreeStep.confirmOwner();

        assertEq(mockOwnedThreeStep.owner(), newOwner);
    }
}
