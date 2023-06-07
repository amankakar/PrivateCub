// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Wallet.sol";

contract WalletTest is Test {
    Shieldpay public walletSepolia;
    Shieldpay public walletMumbai;

    address receiver;
    address member1;
        uint256 sepoliaFork;
        uint polygonFork;
    string SEPOLIA_RPC_URL = vm.envString("ETHEREUM_MAINNET_CHAIN");
    string POLYGON_RPC = vm.envString("POLYGON_SMART_CHAIN");

    function setUp() public {
            sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
            polygonFork = vm.createFork(POLYGON_RPC);

    }

    function testSeploiaWallet(uint16 amount) public {
        vm.assume(amount != 0);
        vm.selectFork(sepoliaFork);
        walletSepolia= new Shieldpay(address(this)  , address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419));
        vm.deal(member1,   amount+2 ether);
        uint256 balanceBefore = address(this).balance;
        vm.prank(member1);
        walletSepolia.transfer{value: amount+1 ether}(receiver); 
        assertGe(address(this).balance , balanceBefore);
    }



     function testWithZeroValue() public {
        vm.selectFork(sepoliaFork);
        walletSepolia= new Shieldpay(address(this)  , address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419));
        vm.startPrank(member1);
        vm.expectRevert();
        walletSepolia.transfer{value: 0 ether}(receiver); 
        // assertEq(address(this).balance , 0);
        vm.stopPrank();
    }


      function testChangeGasFee() public {
        vm.selectFork(sepoliaFork);
        walletSepolia= new Shieldpay(address(this)  , address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419));
        walletSepolia.setGasFee(100 * 1e6);
        vm.deal(member1,   20 ether);
        vm.startPrank(member1);
        uint256 balanceBefore = address(this).balance;
        walletSepolia.transfer{value: 10 ether}(receiver); 
        assertGe(address(this).balance , balanceBefore);
        vm.stopPrank();
    }

  function testFailChangeGasFee() public {
        vm.selectFork(sepoliaFork);
        walletSepolia= new Shieldpay(address(this)  , address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419));
        vm.deal(member1,   10 ether);
        vm.startPrank(member1);
        walletSepolia.setGasFee(99 * 1e6); 
        vm.stopPrank();
    }

     function testChangeOwner() public {
        vm.selectFork(sepoliaFork);
        walletSepolia= new Shieldpay(address(this)  , address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419));
        walletSepolia.setNewOwner(member1);
        vm.deal(member1,   10 ether);
        vm.startPrank(member1);
        walletSepolia.setGasFee(99 * 1e6); 
        vm.stopPrank();
    }
    function testMumbaiWallet(uint16 amount) public {
         vm.assume(amount > 5);
        vm.selectFork(polygonFork);
        walletMumbai= new Shieldpay(address(this)  , address(0xAB594600376Ec9fD91F8e885dADF0CE036862dE0));
        vm.deal(member1,   amount + 10 ether);
        uint256 balanceBefore = address(this).balance;
        vm.prank(member1);
        walletMumbai.transfer{value: amount+ 5 ether}(receiver); 
        assertGe(address(this).balance , balanceBefore);
     }



        receive() external payable {
        }


}
