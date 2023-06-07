// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Wallet.sol";
import "../src/Escrow.sol";

contract EscrowTest is Test {
    Shieldpay public walletSepolia;
    Shieldpay public walletMumbai;
    Escrow public escrowInstance;

    address receiver=vm.addr(3);
    address member1 = vm.addr(2);
    address seller = vm.addr(4);
        uint256 sepoliaFork;
        uint polygonFork;
    string SEPOLIA_RPC_URL = vm.envString("ETHEREUM_MAINNET_CHAIN");
    // string POLYGON_RPC = vm.envString("POLYGON_SMART_CHAIN");

    function setUp() public {
            sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
            // polygonFork = vm.createFork(POLYGON_RPC);

    }

    function testEscrow() public {
        // vm.assume(amount != 0);
        vm.selectFork(sepoliaFork);
        walletSepolia= new Shieldpay(address(this)  , address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419));
        escrowInstance = new Escrow(address(walletSepolia));
        escrowInstance.addItem(seller , bytes32("1")  , 2 ether, 4);
        vm.deal(seller,   4 ether);
        


        vm.deal(member1,   4 ether);
        vm.startPrank(member1);
        uint128 per = calculatePercentage(2 ether);
        console.logUint(address(this).balance);
        escrowInstance.buyerPlaceOrder{value:   2 ether + per}( 0 , 0 , bytes32("1") , bytes32("1"));
        console.logUint(seller.balance);
        console.logUint(address(this).balance);
        vm.stopPrank();
        vm.startPrank(seller);
        escrowInstance.sellerDispatchItem(bytes32("1"));
        vm.stopPrank();

          vm.startPrank(member1);
        escrowInstance.buyerCompleteOrder(bytes32("1") , bytes32("1"));
        console.logUint(seller.balance);
        console.logUint(address(this).balance);
        vm.stopPrank();

    }
   function calculatePercentage(uint128 price) private pure returns(uint128){
        return ((price) * 25) / 1000;
        
     }


        receive() external payable {
        }


}
