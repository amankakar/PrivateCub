// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Escrow.sol";
import "../src/WalletBinance.sol";

import "../src/BUSD.sol";

contract EscrowBTest is Test {
    Shieldpay public walletBinance;
    IERC20 public busdInstance;
    Escrow public escrowInstance;
    BEP20Token public bepToken;
    address receiver = vm.addr(3);
    address member1 = vm.addr(2);
    address seller = vm.addr(4);
    uint256 sepoliaFork;
    uint polygonFork;
    uint256 binanceFork;
    string SEPOLIA_RPC_URL = vm.envString("ETHEREUM_MAINNET_CHAIN");
    string BINANCE_RPC_URL = vm.envString("BINANCE_SMART_CHAIN");

    // string POLYGON_RPC = vm.envString("POLYGON_SMART_CHAIN");

    function setUp() public {
        sepoliaFork = vm.createFork(SEPOLIA_RPC_URL);
        binanceFork = vm.createFork(BINANCE_RPC_URL);
        // polygonFork = vm.createFork(POLYGON_RPC);
    }

    function testEscrow() public {
        vm.selectFork(binanceFork);
        walletBinance = new Shieldpay(
            address(this),
            address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56),
            address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE)
        );

        escrowInstance = new Escrow(address(walletBinance), address(bepToken));
        escrowInstance.addItem(seller, bytes32("1"), 2 ether, 2 ether, 4);
        vm.deal(seller, 4 ether);
        vm.deal(member1, 4 ether);
        vm.startPrank(member1);
        uint128 per = calculatePercentage(2 ether, 25);
        console.logUint(address(this).balance);
        uint8[] memory _paymentType = new uint8[](1);
        uint128[] memory amount=new uint128[](1);
        bytes32[] memory  _key=new bytes32[](1);
        bytes32[] memory itemKey= new bytes32[](1);
        _paymentType[0] =0;
        amount[0] =0;
        _key[0] = "2";
        itemKey[0] = "1";
        escrowInstance.buyerPlaceOrder{value: 2 ether + per}(
            _paymentType,
            amount,
            _key,
            itemKey
        );
        console.logUint(seller.balance);
        console.logUint(address(this).balance);
        vm.stopPrank();
        vm.startPrank(seller);
        escrowInstance.sellerDispatchItem(bytes32("2"));
        vm.stopPrank();

        vm.startPrank(member1);
        escrowInstance.buyerCompleteOrder(_key ,itemKey);
        console.logUint(seller.balance);
        console.logUint(address(this).balance);
        vm.stopPrank();
    }

    function calculatePercentage(
        uint128 price,
        uint8 per
    ) private pure returns (uint128) {
        return ((price) * per) / 1000;
    }

    // list of test cases
    //check ETH transfer to owner and seller
    function testBNBTransferEscrow() public {
        vm.selectFork(binanceFork);
        walletBinance = new Shieldpay(
            address(this),
            address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56),
            address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE)
        );

        escrowInstance = new Escrow(address(walletBinance), address(bepToken));
        uint128 per = calculatePercentage(2 ether, 25);
        escrowInstance.addItem(seller, bytes32("1"), (2 ether), 2 ether, 4);
        vm.deal(seller, 4 ether);
        vm.deal(member1, 4 ether);
        vm.startPrank(member1);
        console.logUint(per);
      uint8[] memory _paymentType = new uint8[](1);
        uint128[] memory amount=new uint128[](1);
        bytes32[] memory  _key=new bytes32[](1);
        bytes32[] memory itemKey= new bytes32[](1);
        _paymentType[0] =0;
        amount[0] =0;
        _key[0] = "2";
        itemKey[0] = "1";
        escrowInstance.buyerPlaceOrder{value: 2 ether + per}(
            _paymentType,
            amount,
            _key,
            itemKey
        );
        vm.stopPrank();
        vm.startPrank(seller);
        escrowInstance.sellerDispatchItem(bytes32("2"));
        vm.stopPrank();

        vm.startPrank(member1);
        escrowInstance.buyerCompleteOrder(_key, itemKey);
        vm.stopPrank();
        assertGt((2 ether - per), (seller.balance - 4 ether));
    }

    // check busd transfer

    function testBUSDTransferEscrow() public {
        vm.selectFork(binanceFork);
        walletBinance = new Shieldpay(
            address(this),
            address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56),
            address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE)
        );
        busdInstance = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        escrowInstance = new Escrow(
            address(walletBinance),
            address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56)
        );
        uint128 per = calculatePercentage(2 ether, 25);
        console.log("per", per);
        escrowInstance.addItem(seller, bytes32("1"), (2 ether), 2 ether, 4);
        vm.deal(seller, 4 ether);
        vm.deal(member1, 4 ether);
        address usdOwner = 0xF07C30E4CD6cFff525791B4b601bD345bded7f47; // busd20 token owner address
        vm.prank(usdOwner);
        busdInstance.transfer(member1, 4 ether);

        vm.startPrank(member1);
        busdInstance.approve(address(escrowInstance), 4 ether);
        // console.logUint(per);
        uint8[] memory _paymentType = new uint8[](1);
        uint128[] memory amount=new uint128[](1);
        bytes32[] memory  _key=new bytes32[](1);
        bytes32[] memory itemKey= new bytes32[](1);
        _paymentType[0] =1;
        amount[0] =2 ether +per;
        _key[0] = "2";
        itemKey[0] = "1";
        escrowInstance.buyerPlaceOrder{value: 2 ether + per}(
            _paymentType,
            amount,
            _key,
            itemKey
        );
        vm.stopPrank();
        vm.startPrank(seller);
        escrowInstance.sellerDispatchItem(bytes32("2"));
        vm.stopPrank();
        uint256 busdBlanceBefore = busdInstance.balanceOf(seller);
        console.log(busdBlanceBefore);

        vm.startPrank(member1);
        escrowInstance.buyerCompleteOrder(_key, itemKey);
        vm.stopPrank();
        uint256 ownerBlace = busdInstance.balanceOf(address(this));
        console.log(busdInstance.balanceOf(seller) - busdBlanceBefore);
        // assertEq(busdInstance.balanceOf(seller),(50000000000000000 + 990000000000000000));
    }

    // check payment types
    // check qunatity
    // check complete sell flow
    // try to break sell flow
    // admin complete and disupte flow

     function testAdminCompleteEscrow() public {
        vm.selectFork(binanceFork);
        walletBinance = new Shieldpay(
            address(this),
            address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56),
            address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE)
        );
        busdInstance = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        escrowInstance = new Escrow(
            address(walletBinance),
            address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56)
        );
        uint128 per = calculatePercentage(2 ether, 25);
        console.log("per", per);
        escrowInstance.addItem(seller, bytes32("1"), (2 ether), 2 ether, 4);
        vm.deal(seller, 4 ether);
        vm.deal(member1, 4 ether);
        address usdOwner = 0xF07C30E4CD6cFff525791B4b601bD345bded7f47; // busd20 token owner address
        vm.prank(usdOwner);
        busdInstance.transfer(member1, 4 ether);

        vm.startPrank(member1);
        busdInstance.approve(address(escrowInstance), 4 ether);
        // console.logUint(per);
        uint8[] memory _paymentType = new uint8[](1);
        uint128[] memory amount=new uint128[](1);
        bytes32[] memory  _key=new bytes32[](1);
        bytes32[] memory itemKey= new bytes32[](1);
        _paymentType[0] =1;
        amount[0] =2 ether + per;
        _key[0] = "2";
        itemKey[0] = "1";
        escrowInstance.buyerPlaceOrder{value: 2 ether + per}(
            _paymentType,
            amount,
            _key,
            itemKey
        );
        vm.stopPrank();
        vm.startPrank(seller);
        escrowInstance.sellerDispatchItem(bytes32("2"));
        vm.stopPrank();
        uint256 busdBlanceBefore = busdInstance.balanceOf(seller);
        console.log(busdBlanceBefore);

        // vm.startPrank(member1);
        escrowInstance.adminCompleteOrder(bytes32("2"), bytes32("1"));
        // vm.stopPrank();
        uint256 ownerBlace = busdInstance.balanceOf(address(this));
        console.log(busdInstance.balanceOf(seller) - busdBlanceBefore);
        assertEq(busdInstance.balanceOf(seller),(960000000000000000));
    }


     function testAdminCompleteBNBEscrow() public {
        vm.selectFork(binanceFork);
        walletBinance = new Shieldpay(
            address(this),
            address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56),
            address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE)
        );

        escrowInstance = new Escrow(address(walletBinance), address(bepToken));
        uint128 per = calculatePercentage(2 ether, 25);
        escrowInstance.addItem(seller, bytes32("1"), (2 ether), 2 ether, 4);
        vm.deal(seller, 4 ether);
        vm.deal(member1, 4 ether);
        vm.startPrank(member1);
        console.logUint(per);
     uint8[] memory _paymentType = new uint8[](1);
        uint128[] memory amount=new uint128[](1);
        bytes32[] memory  _key=new bytes32[](1);
        bytes32[] memory itemKey= new bytes32[](1);
        _paymentType[0] =0;
        amount[0] =0;
        _key[0] = "2";
        itemKey[0] = "1";
        escrowInstance.buyerPlaceOrder{value: 2 ether + per}(
            _paymentType,
            amount,
            _key,
            itemKey
        );
        vm.stopPrank();
        vm.startPrank(seller);
        escrowInstance.sellerDispatchItem(bytes32("2"));
        vm.stopPrank();

        escrowInstance.adminCompleteOrder(bytes32("2"), bytes32("1"));
        assertGt((2 ether - per), (seller.balance - 4 ether));
    }

    receive() external payable {}
}
