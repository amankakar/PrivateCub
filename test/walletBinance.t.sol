// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WalletBinance.sol";
import "../src/BUSD.sol";
contract WalletTestBinance is Test {
    Shieldpay public walletBinance;
    IERC20 public busdInstance;
    address public owner = vm.addr(4);
    address member1 = vm.addr(3);
        uint256 binanceFork;
        uint mumbaiFork;
    string BINANCE_RPC_URL = vm.envString("BINANCE_SMART_CHAIN");

    function setUp() public {
            binanceFork = vm.createFork(BINANCE_RPC_URL);
    }

    function testTransferBNB(uint16 amount) public {
        vm.selectFork(binanceFork);
        walletBinance= new Shieldpay(address(this)  , address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56) ,  address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE));
        vm.deal(member1,   amount+10 ether);
        uint256 balanceBefore = address(this).balance;
        vm.prank(member1);
        address receiver = vm.addr(1);
        walletBinance.transfer{value: amount + 0.07 ether}(receiver); 
        assertGe(address(this).balance , balanceBefore);
    }

  function testTransferBUSD() public {
        vm.selectFork(binanceFork);
        busdInstance = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        walletBinance= new Shieldpay(owner  , address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56) ,  address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE));
        vm.deal(member1,   10 ether);
        address receiver = vm.addr(1);
        address usdOwner = 0xF07C30E4CD6cFff525791B4b601bD345bded7f47; // busd20 token owner address
        vm.prank(usdOwner);
        busdInstance.transfer(member1 , 99000000000000000000);
        vm.startPrank(member1);
        busdInstance.approve(address(walletBinance) , 99000000000000000000);
        // console.logUint(busdInstance.allowance(member1 , address(walletBinance)));
        console.logAddress(member1);
        console.logAddress(address(busdInstance));
        walletBinance.transferBusd(receiver , 9900000000000000000); 
        vm.stopPrank();
        assertEq(990000000000000000, busdInstance.balanceOf(owner));
    }
 


        receive() external payable {
        }


}
