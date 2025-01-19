// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMeContract;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMeContract = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMeContract.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMeContract.i_owner(), msg.sender);
    }

    function testPriceFeedIsAccurate() public view {
        uint256 version = fundMeContract.getVersion();
        assertEq(version, 4);
    }
}
