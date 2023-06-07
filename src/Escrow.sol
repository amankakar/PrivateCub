// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 import "@openzeppelin/contracts/access/Ownable.sol";
 import "./IShieldpay.sol";

contract Escrow is Ownable {
     string public name = "escrow contract";
     enum ItemState { PLACE,OFFERED, AWAITING_DELIVERY, COMPLETE , CANCEL }
    IShieldpay public shieldPay;  //Reference to BossoinCoin contract   

struct Item{
        address  seller;
        uint8 quantity;
        uint128 price;
        bytes32  key; //unique string identifier          
    }

     struct EscrowItem{
        address  seller;
        address  buyer;   
        uint8 paymentType; 
        ItemState state;
        uint128 price;
        bytes32  key; //unique string identifier    
              
    } //item published for sale in escrow arragement
    
    mapping (bytes32 => Item) public stocks; //balances from each buyer/seller and escrow account
    mapping (bytes32 => EscrowItem) public escrowItems; 

    error InvalidType();
    error ItemNotInList();
    error AmountIsNotValid();
    error CanNotBeSame();
    error CanNotPlaceOffer();
    error SellerCanNotZero();
    error  ItemAlreadyCompleted( );

    //@dev: constructor for BossonEscrow
    //@params: takes in the address of the ShieldPay contract 
    constructor (address _shieldPay) {
         shieldPay = IShieldpay(_shieldPay);         
    }

    // onlyOwner , onlyseller , onlybuyer

    modifier onlySeller(bytes32 _key){
     EscrowItem memory item = escrowItems[_key];
     if(item.seller != _msgSender()) revert();
     _;
    }

      modifier onlyBuyer(bytes32 _key){
     EscrowItem memory item = escrowItems[_key];
     if(item.buyer != _msgSender()) revert();
     _;
    }
     
     //@dev:  add item to the list
    function addItem(address _seller , bytes32 _key , uint128 _price , uint8 _quantity) public{
        if(_seller == address(0)) revert SellerCanNotZero();
        Item memory itemList;
        itemList.seller = _seller;
        itemList.price = _price;
        itemList.quantity = _quantity;
        stocks[_key] = itemList;
    }

     //@dev:  buyer funds are transfered to escrow account

     function buyerPlaceOrder( uint8 _paymentType, uint128 amount , bytes32 _key , bytes32 itemKey)  public payable {
        if( !(_paymentType == 0 || _paymentType ==1)) revert InvalidType();
        Item memory itemList = stocks[itemKey];
        if(itemList.seller == address(0)) revert ItemNotInList();
        if(!(itemList.price + calculatePercentage(itemList.price) == uint128(msg.value))) revert AmountIsNotValid();
        EscrowItem memory item;
        item.seller = itemList.seller;
        item.buyer = msg.sender;
        item.state = ItemState.PLACE;
        if(_paymentType == 0){ // for native currency
         item.price = uint128(msg.value);
        } else if(_paymentType == 1){
            item.price= amount;
        }
        escrowItems[_key] = item;

     }

         //@dev:  buyer funds are transfered to escrow account
     function sellerOfferItem( bytes32 _key) onlySeller(_key) public payable {
               EscrowItem memory item = escrowItems[_key];
               if(item.seller != _msgSender()) revert CanNotPlaceOffer();
               item.state = ItemState.OFFERED;
     }


          //@dev:  buyer funds are transfered to escrow account
     function sellerDispatchItem( bytes32 _key) onlySeller(_key)public payable {
               EscrowItem memory item = escrowItems[_key];
               item.state = ItemState.AWAITING_DELIVERY;
     }

             //@dev:  buyer funds are transfered to seller and admin account 
     function buyerCompleteOrder( bytes32 _key , bytes32 _itemKey)  onlyBuyer(_key) public  {
              Item memory itemList = stocks[_itemKey];
        if(itemList.seller == address(0)) revert ItemNotInList();

               EscrowItem memory item = escrowItems[_key];
                if(item.state == ItemState.COMPLETE) revert ItemAlreadyCompleted();
               item.state = ItemState.COMPLETE;
               itemList.quantity -=1;
               // total of 5% = 2.5 from buyer and seller
               uint128 buyerCut = calculatePercentage(item.price);
                uint128 sellerCut = calculatePercentage(item.price - buyerCut);
                  (bool success, ) = payable(owner()).call{
            value: (sellerCut + buyerCut)
        }("");
        if(!success) revert();
      
        shieldPay.transfer{value:item.price - (buyerCut + sellerCut)}(item.seller);
            
     }
     function calculatePercentage(uint128 price) private pure returns(uint128){
        return ((price) * 25) / 1000;
        
     }


      receive() external payable {
        }
 }