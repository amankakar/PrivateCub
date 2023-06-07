// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/WalletBinance.sol";

contract MyScriptBinance is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Shieldpay wallet = new Shieldpay(0xAE140507D1539Bc53d7CEe05f62e282E033500f2,0xE3E172D49e6569B334B1BF4F4984Fc9C830a73Ab, 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);

        vm.stopBroadcast();
    }
}
