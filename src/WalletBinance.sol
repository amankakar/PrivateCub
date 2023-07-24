
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


  import "@openzeppelin/contracts/token/ERC20/IERC20.sol";





contract Shieldpay {
    address private _owner;
    int256 private _feeBNB;
    uint256 private _feeBUSD ;

    address private _busdAddress;
    AggregatorV3Interface internal priceFeed; // testnet address :: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526


    error ZeroAmountSent();
    error NotOwner();
    constructor(
        address owner,
        address busdAddress,
        address priceFeedAddress
    ) {
        _owner = owner;
        _busdAddress = busdAddress;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        _feeBNB= 99 * 1e6;
        _feeBUSD = 0.99 * 1e18; // initial fee 0.99$ = 990000000000000000. formula = 0.99 * 1e18 
    }

    modifier onlyOwner() {
        if(msg.sender != _owner) revert  NotOwner();
        _;
    }

    function setBNBFee(int256 fee) public onlyOwner {
        _feeBNB = fee;
    }


    function setNewOwner(address owner) public onlyOwner {
        _owner = owner;
    }
     function setBUSDFee(uint256 feeBUSD) public onlyOwner {
        _feeBUSD = feeBUSD;
    }

    function transferBusd(address recipient, uint256 amount) public {
        if(amount == 0) revert ZeroAmountSent();
        IERC20(_busdAddress).transferFrom(msg.sender, _owner, (_feeBUSD));
        IERC20(_busdAddress).transferFrom(msg.sender, recipient, (amount - _feeBUSD));
    }

    function transfer(address receipent) public payable {
        if(msg.value == 0) revert ZeroAmountSent();
        uint256 fee  = uint256(getFeeRate());
           // send  Fee to owner
          (bool success, bytes memory returnError) = payable(_owner).call{
            value: fee
        }("");
        require(success, string(returnError));

        // send remaining amount to mes.sender
        (bool successAmount, bytes memory returnErrorAmount) = payable(receipent).call{
            value: (msg.value - fee)
        }("");
        require(successAmount, string(returnErrorAmount));
    }
    /// chain link aggragtor to get price of native currency  in usd
    function getFeeRate() private view returns (int256) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        // emit PriceScan(price);
        return (_feeBNB * 1e18)/(price);

    }
}