// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IShieldpay.sol";

contract Escrow is Ownable {
    enum ItemState {
        PLACE,
        OFFERED,
        AWAITING_DELIVERY,
        COMPLETE,
        CANCEL,
        DISPUTECOMPLETE
    }
    IShieldpay public shieldPay;
    IERC20 public BusdAddress;
    struct Item {
        address owner;
        uint8 quantity;
        uint128 price;
        uint128 priceBUSD;
        bytes32 key; //unique string identifier
    }

    struct EscrowItem {
        address seller;
        address buyer;
        uint8 paymentType;
        ItemState state;
        uint128 price;
        uint128 priceBUSD;
        bytes32 key; //unique string identifier
    } //item published for sale in escrow arragement

    mapping(bytes32 => Item) public stocks; //balances from each buyer/seller and escrow account
    mapping(bytes32 => EscrowItem) public escrowItems;

    error InvalidType();
    error ItemNotInList();
    error AmountIsNotValid();
    error CanNotBeSame();
    error CanNotPlaceOffer();
    error SellerCanNotZero();
    error ItemAlreadyCompleted();
    error LengthNotMatched();

    //@dev: constructor for BossonEscrow
    //@params: takes in the address of the ShieldPay contract
    constructor(address _shieldPay, address _busdAddres) {
        shieldPay = IShieldpay(_shieldPay);
        BusdAddress = IERC20(_busdAddres);
    }

    // onlyOwner , onlyseller , onlybuyer
    modifier onlySeller(bytes32 _key) {
        EscrowItem memory item = escrowItems[_key];
        if (item.seller != _msgSender()) revert();
        _;
    }

    modifier onlyBuyer(bytes32[]calldata  _key) {
      for (uint8 i ; i <_key.length;){
        EscrowItem memory item = escrowItems[_key[i]];
        if (item.buyer != _msgSender()) revert();
        _;
         
        unchecked {
        i++;
      }
      }
     
    }

    //@dev:  add item to the list
    function addItem(
        address _owner,
        bytes32 _key,
        uint128 _price,
        uint128 _priceBUSD,
        uint8 _quantity
    ) public {
        if (_owner == address(0)) revert SellerCanNotZero();
        Item memory itemList;
        itemList.owner = _owner;
        itemList.price = _price;
        itemList.quantity = _quantity;
        itemList.priceBUSD = _priceBUSD;
        stocks[_key] = itemList;
    }

    //@dev:  buyer funds are transfered to escrow account

    function buyerPlaceOrder(
        uint8[] calldata _paymentType,
        uint128[] calldata amount,
        bytes32[] memory  _key,
        bytes32[] memory itemKey
    ) public payable {
      uint128 value = uint128(msg.value);
      if((_paymentType.length != amount.length  && amount.length != _key.length && _key.length != itemKey.length)) revert LengthNotMatched();
      for(uint i; i <_paymentType.length; i++){
        if (!(_paymentType[i] == 0 || _paymentType[i] == 1)) revert InvalidType();
        Item memory itemList = stocks[itemKey[i]];
        if (itemList.owner == address(0) || !(itemList.quantity > 0))
            revert ItemNotInList();
        EscrowItem memory item;
        item.seller = itemList.owner;
        item.buyer = msg.sender;
        item.state = ItemState.PLACE;
        item.paymentType = _paymentType[i];
        if (_paymentType[i] == 0) {
           
            uint128 payablePrice = itemList.price + calculatePercentage(itemList.price, 25);
            if (
                !(payablePrice >=
                    uint128(value))
            ) revert AmountIsNotValid();
            item.price = payablePrice;
            value-=payablePrice;
        } else if (_paymentType[i] == 1) {
            if (
                !(itemList.priceBUSD +
                    calculatePercentage(itemList.priceBUSD, 25) ==
                    uint128(amount[i]))
            ) revert AmountIsNotValid();
            item.priceBUSD = amount[i];
            BusdAddress.transferFrom(msg.sender, address(this), amount[i]);
        }
        escrowItems[_key[i]] = item;
      }
    }

    //@dev:  seller send item
    function sellerDispatchItem(bytes32 _key) public  onlySeller(_key) {
        EscrowItem memory item = escrowItems[_key];
        item.state = ItemState.OFFERED;
        escrowItems[_key] = item;

    }

    //@dev:  buyer funds are transfered to seller and admin account
    function buyerCompleteOrder(
        bytes32[] calldata _key,
        bytes32[] calldata _itemKey
    ) public payable onlyBuyer(_key) {
      if(_key.length != _itemKey.length) revert LengthNotMatched();
      for(uint8 i ; i <_itemKey.length;){
        Item memory itemList = stocks[_itemKey[i]];
        if (itemList.owner == address(0)) revert ItemNotInList();

        EscrowItem memory item = escrowItems[_key[i]];
        if (item.state == ItemState.COMPLETE) revert ItemAlreadyCompleted();
        item.state = ItemState.COMPLETE;
        itemList.quantity -= 1;

        if (item.paymentType == 0) {
            // total of 5% = 2.5 from buyer and seller
            uint128 sellerCut = calculatePercentage(itemList.price, 25);
            (bool success, ) = payable(owner()).call{
                value: (sellerCut + item.price - itemList.price)
            }("");
            if (!success) revert();

            shieldPay.transfer{
                value: item.price - (item.price - itemList.price + sellerCut)
            }(item.seller);
        } else {
            // total of 5% = 2.5 from buyer and seller
            uint128 sellerCut = calculatePercentage(itemList.priceBUSD, 25);
            BusdAddress.transfer(
                owner(),
                (sellerCut + item.priceBUSD - itemList.priceBUSD)
            );
            uint256 transferAmount = item.priceBUSD -
                (item.priceBUSD - itemList.priceBUSD + sellerCut);
            BusdAddress.approve(address(shieldPay), transferAmount);
            shieldPay.transferBusd(item.seller, transferAmount);
        }
      unchecked {
        i++;
      }
      }
    }

    //@dev:  buyer funds are transfered to seller and admin account
    function adminCompleteOrder(
        bytes32 _key,
        bytes32 _itemKey
    ) public onlyOwner {
        Item memory itemList = stocks[_itemKey];
        if (itemList.owner == address(0)) revert ItemNotInList();

        EscrowItem memory item = escrowItems[_key];
        if (item.state == ItemState.COMPLETE) revert ItemAlreadyCompleted();
        item.state = ItemState.COMPLETE;
        itemList.quantity -= 1;
        // total of 5% = 2.5 from buyer and seller

        if (item.paymentType == 0) {
            // total of 5% = 2.5 from buyer and seller
            uint128 sellerCut = calculatePercentage(itemList.price, 25);
            (bool success, ) = payable(owner()).call{
                value: (sellerCut + item.price - itemList.price)
            }("");
            if (!success) revert();

            shieldPay.transfer{
                value: item.price - (item.price - itemList.price + sellerCut)
            }(item.seller);
        } else {
            // total of 5% = 2.5 from buyer and seller
            uint128 sellerCut = calculatePercentage(itemList.priceBUSD, 25);
            BusdAddress.transfer(
                owner(),
                (sellerCut + item.priceBUSD - itemList.priceBUSD)
            );
            uint256 transferAmount = item.priceBUSD -
                (item.priceBUSD - itemList.priceBUSD + sellerCut);
            BusdAddress.approve(address(shieldPay), transferAmount);
            shieldPay.transferBusd(item.seller, transferAmount);
        }
    }

    //@dev:  buyer funds are transfered to seller and admin account
    function adminResovleDispute(
        bytes32 _key,
        bytes32 _itemKey
    ) public onlyOwner {
        Item memory itemList = stocks[_itemKey];
        if (itemList.owner == address(0)) revert ItemNotInList();

        EscrowItem memory item = escrowItems[_key];
        if (item.state == ItemState.COMPLETE) revert ItemAlreadyCompleted();
        item.state = ItemState.DISPUTECOMPLETE;
        // total of 5% = 15 from buyer and seller
        if (item.paymentType == 0) {
            uint128 sellerCut = calculatePercentage(item.price, 150);
            shieldPay.transfer{value: sellerCut}(item.seller);
            shieldPay.transfer{value: (item.price - sellerCut)}(item.buyer);
        } else {
            uint128 sellerCut = calculatePercentage(item.priceBUSD, 150);
            shieldPay.transferBusd(item.seller, sellerCut);
            shieldPay.transferBusd(item.buyer, item.price - sellerCut);
        }
    }

    function calculatePercentage(
        uint128 price,
        uint8 persentage
    ) private pure returns (uint128) {
        return ((price) * persentage) / 1000;
    }

    receive() external payable {}
}
