// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/WalletBinance.sol";

contract MyScriptBinance is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Shieldpay wallet = new Shieldpay(0xd1a5444F99BE6C3EefBc6998c5e7F0F069025d98,address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56) ,  address(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE));
        console.logAddress(address(wallet));
        vm.stopBroadcast();
    }
}
