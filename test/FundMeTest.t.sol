// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {console} from "forge-std/console.sol";

contract FundMeTest is Test {
    FundMe fundMeContract;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 20 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMeContract = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMeContract.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMeContract.getOwner(), msg.sender);
    }

    function testPriceFeedIsAccurate() public view {
        uint256 version = fundMeContract.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMeContract.fund{value: 1e10}();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next transaction will be sent by USER
        fundMeContract.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMeContract.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address fundersAddress = fundMeContract.getFunder(0);
        assertEq(fundersAddress, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMeContract.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMeContract.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMeContract.getOwner().balance;
        uint256 startingContractBalance = address(fundMeContract).balance;

        // Act
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMeContract.getOwner());
        fundMeContract.withdraw();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMeContract.getOwner().balance;
        uint256 endingContractBalance = address(fundMeContract).balance;

        assertEq(endingContractBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingContractBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 15;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i));
            fundMeContract.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMeContract.getOwner().balance;
        uint256 startingContractBalance = address(fundMeContract).balance;

        vm.startPrank(fundMeContract.getOwner());
        fundMeContract.withdraw();
        vm.stopPrank();

        assertEq(address(fundMeContract).balance, 0); // current balance is depleted
        assertEq(
            startingOwnerBalance + startingContractBalance,
            fundMeContract.getOwner().balance
        );
    }
}
