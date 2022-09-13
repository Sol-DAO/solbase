// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockThreeStepOwned} from "./utils/mocks/MockThreeStepOwned.sol";

contract ThreeStepOwnedTest is DSTestPlus {
    MockThreeStepOwned mockThreeStepOwned;

    function setUp() public {
        mockThreeStepOwned = new MockThreeStepOwned();
    }

    function testUpdateOwner() public {
        testUpdateOwner(address(0xBEEF));
    }

    function testCallFunctionAsNonOwner() public {
        address nonOwner = address(0xBAD);

        assertFalse(mockThreeStepOwned.owner() == nonOwner);

        hevm.prank(nonOwner);
        hevm.expectRevert("UNAUTHORIZED");
        mockThreeStepOwned.initOwnershipUpdate(address(0xC0FFEE));

        assertEq(mockThreeStepOwned.owner(), address(this));
    }

    function testCallFunctionAsOwner() public {
        mockThreeStepOwned.updateFlag();
    }

    function testCallFunctionAsOwnerAfterUpdatingIt() public {
        address newOwner = address(0xCAFE);
        testUpdateOwner(newOwner);

        hevm.prank(newOwner);
        mockThreeStepOwned.updateFlag();
    }

    function testRenounceOwnership() public {
        mockThreeStepOwned.renounceOwnership();

        assertEq(mockThreeStepOwned.owner(), address(0));

        hevm.expectRevert("UNAUTHORIZED");
        mockThreeStepOwned.updateFlag();
    }

    function testRenounceOwnershipAsNonOwner() public {
        address nonOwner = address(0xBAD);
        assertFalse(mockThreeStepOwned.owner() == nonOwner);

        hevm.prank(nonOwner);
        hevm.expectRevert("UNAUTHORIZED");
        mockThreeStepOwned.renounceOwnership();
    }

    function testConfirmOwnershipUpdateAfterRenouncing() public {
        address ownerCandidate = address(0xC0FFEE);
        mockThreeStepOwned.initOwnershipUpdate(ownerCandidate);

        mockThreeStepOwned.renounceOwnership();
        assertEq(mockThreeStepOwned.owner(), address(0));

        hevm.prank(ownerCandidate);
        mockThreeStepOwned.confirmOwnershipUpdate();

        hevm.expectRevert("UNAUTHORIZED");
        mockThreeStepOwned.confirmOwnershipUpdate();
    }

    function testConfirmOwnershipInWrongOrder() public {
        mockThreeStepOwned.initOwnershipUpdate(address(0xC0FFEE));

        hevm.expectRevert("UNAUTHORIZED");
        mockThreeStepOwned.confirmOwnershipUpdate();
    }

    function testUpdateOwner(address ownerCandidate) public {
        mockThreeStepOwned.initOwnershipUpdate(ownerCandidate);

        assertEq(mockThreeStepOwned.owner(), address(this));

        hevm.prank(ownerCandidate);
        mockThreeStepOwned.confirmOwnershipUpdate();

        assertEq(mockThreeStepOwned.owner(), address(this));

        mockThreeStepOwned.confirmOwnershipUpdate();

        assertEq(mockThreeStepOwned.owner(), ownerCandidate);
    }
}
