// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Escrow.sol";

contract EscrowScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
// sepolia :: 0x694AA1769357215DE4FAC081bf1f309aDC325306
// polygon :: 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
        Escrow escrow = new Escrow(0x2B575390e64C5A03F624B14b8d0D077d3cDa77C7 , 0xE3E172D49e6569B334B1BF4F4984Fc9C830a73Ab);
        console.logAddress(address(escrow));
        vm.stopBroadcast();
    }
}
