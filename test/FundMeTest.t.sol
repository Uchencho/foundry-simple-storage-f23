// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMeContract;

    function setUp() public {
        fundMeContract = new FundMe();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMeContract.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMeContract.i_owner(), address(this));
    }
}
