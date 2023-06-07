// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IShieldpay {
   function transfer(address receipent) external payable;
    function transferBusd(address recipient, uint256 amount) external;

}