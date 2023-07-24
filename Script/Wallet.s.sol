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
        Shieldpay wallet = new Shieldpay(0xd1a5444F99BE6C3EefBc6998c5e7F0F069025d98, 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0);
        console.logAddress(address(wallet));
        vm.stopBroadcast();
    }
}
