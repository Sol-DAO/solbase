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
        mockThreeStepOwned.setOwner(address(0xC0FFEE));

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

    function testRenounceOwner() public {
        mockThreeStepOwned.renounceOwner();

        assertEq(mockThreeStepOwned.owner(), address(0));

        hevm.expectRevert("UNAUTHORIZED");
        mockThreeStepOwned.updateFlag();
    }

    function testRenounceOwnerAsNonOwner() public {
        address nonOwner = address(0xBAD);
        assertFalse(mockThreeStepOwned.owner() == nonOwner);

        hevm.prank(nonOwner);
        hevm.expectRevert("UNAUTHORIZED");
        mockThreeStepOwned.renounceOwner();
    }

    function testConfirmOwnerAfterRenounceOwner() public {
        address newOwner = address(0xC0FFEE);
        mockThreeStepOwned.setOwner(newOwner);

        mockThreeStepOwned.renounceOwner();
        assertEq(mockThreeStepOwned.owner(), address(0));

        hevm.prank(newOwner);
        mockThreeStepOwned.confirmOwner();

        hevm.expectRevert("UNAUTHORIZED");
        mockThreeStepOwned.confirmOwner();
    }

    function testConfirmOwnerInWrongOrder() public {
        mockThreeStepOwned.setOwner(address(0xC0FFEE));

        hevm.expectRevert("UNAUTHORIZED");
        mockThreeStepOwned.confirmOwner();
    }

    function testSetOwner(address newOwner) public {
        mockThreeStepOwned.setOwner(newOwner);

        assertEq(mockThreeStepOwned.owner(), address(this));

        hevm.prank(newOwner);
        mockThreeStepOwned.confirmOwner();

        assertEq(mockThreeStepOwned.owner(), address(this));

        mockThreeStepOwned.confirmOwner();

        assertEq(mockThreeStepOwned.owner(), newOwner);
    }
}
