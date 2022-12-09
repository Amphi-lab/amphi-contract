// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./utils/calculateUtils.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
contract TransService is CalculateUtils{
    //mapping(uint256 => LibProject.TranslationPro ) 
    mapping(address =>  mapping(uint256 =>  LibProject.TranslationPro))  taskList;
    // function postProject(address buyer, LibProject.TranslationPro memory _t)  public returns(uint256) {
    //      LibProject.TranslationPro storage pro = taskList[buyer][0];
    //      pro= _t;
    // }
}