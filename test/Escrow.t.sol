// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import "../src/Wallet.sol";
// import "../src/Escrow.sol";

// import "../src/BUSD.sol";

// contract EscrowTest is Test {
//     Shieldpay public walletSepolia;
//     Shieldpay public walletMumbai;
//     Escrow public escrowInstance;
//     BEP20Token public bepToken;
//     address receiver = vm.addr(3);
//     address member1 = vm.addr(2);
//     address seller = vm.addr(4);
//     uint256 sepoliaFork;
//     uint polygonFork;
//     uint256 binanceFork;
//     string SEPOLIA_RPC_URL = vm.envString("ETHEREUM_MAINNET_CHAIN");

//     // string POLYGON_RPC = vm.envString("POLYGON_SMART_CHAIN");

//     function setUp() public {
//         sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);

//         // polygonFork = vm.createFork(POLYGON_RPC);
//     }

//     function testEscrow() public {
//         vm.selectFork(sepoliaFork);
//         walletSepolia = new Shieldpay(
//             address(this),
//             address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419)
//         );
//         escrowInstance = new Escrow(address(walletSepolia), address(bepToken));
//         escrowInstance.addItem(seller, bytes32("1"), 2 ether, 2 ether, 4);
//         vm.deal(seller, 4 ether);
//         vm.deal(member1, 4 ether);
//         vm.startPrank(member1);
//         uint128 per = calculatePercentage(2 ether, 25);
//         console.logUint(address(this).balance);
//         escrowInstance.buyerPlaceOrder{value: 2 ether + per}(
//             0,
//             0,
//             bytes32("2"),
//             bytes32("1")
//         );
//         console.logUint(seller.balance);
//         console.logUint(address(this).balance);
//         vm.stopPrank();
//         vm.startPrank(seller);
//         escrowInstance.sellerDispatchItem(bytes32("2"));
//         vm.stopPrank();

//         vm.startPrank(member1);
//         escrowInstance.buyerCompleteOrder(bytes32("2"), bytes32("1"));
//         console.logUint(seller.balance);
//         console.logUint(address(this).balance);
//         vm.stopPrank();
//     }

//     function calculatePercentage(
//         uint128 price,
//         uint8 per
//     ) private pure returns (uint128) {
//         return ((price) * per) / 1000;
//     }

//     // list of test cases
//     //check ETH transfer to owner and seller
//     function testEthTransferEscrow() public {
//         vm.selectFork(sepoliaFork);
//         walletSepolia = new Shieldpay(
//             address(this),
//             address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419)
//         );

//         escrowInstance = new Escrow(address(walletSepolia), address(bepToken));
//         uint128 per = calculatePercentage(2 ether, 25);
//         escrowInstance.addItem(seller, bytes32("1"), (2 ether), 2 ether, 4);
//         vm.deal(seller, 4 ether);
//         vm.deal(member1, 4 ether);
//         vm.startPrank(member1);
//         console.logUint(per);
//         escrowInstance.buyerPlaceOrder{value: 2 ether + per}(
//             0,
//             0,
//             bytes32("2"),
//             bytes32("1")
//         );
//         vm.stopPrank();
//         vm.startPrank(seller);
//         escrowInstance.sellerDispatchItem(bytes32("2"));
//         vm.stopPrank();

//         vm.startPrank(member1);
//         escrowInstance.buyerCompleteOrder(bytes32("2"), bytes32("1"));
//         vm.stopPrank();
//         assertGt((2 ether - per), (seller.balance - 4 ether));
//     }

//     // check busd transfer

//     // check payment types
//     // check qunatity
//     // check complete sell flow
//     // try to break sell flow
//     // admin complete and disupte flow
//     receive() external payable {}
// }
