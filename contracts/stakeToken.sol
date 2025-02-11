// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20("StakingToken Token", "SLT") {
    address public owner;

    constructor() {
        owner = msg.sender;
        _mint(msg.sender, 100000e18);
    }

    function mint(uint _amount) external {
        require(msg.sender == owner, "you are not owner");
        _mint(msg.sender, _amount * 1e18);
    }
}