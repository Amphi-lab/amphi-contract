// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MBT is ERC20{
    constructor(uint _totalSuperNum,string memory name,string memory symbol) ERC20(name,symbol) {
        _mint(msg.sender,_totalSuperNum);
    }
}