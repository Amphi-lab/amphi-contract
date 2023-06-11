// SPDX-License-Identifier: MIT;

pragma solidity 0.8.7;

import "http://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Erc20T is ERC20{


    constructor(uint _totalSuperNum) ERC20("T test","T") {
        _mint(msg.sender,_totalSuperNum);
    }

}