// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Wallet.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
// sepolia :: 0x694AA1769357215DE4FAC081bf1f309aDC325306
// polygon :: 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
        Shieldpay wallet = new Shieldpay(0xAE140507D1539Bc53d7CEe05f62e282E033500f2, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
        console.logAddress(address(wallet));
        vm.stopBroadcast();
    }
}
