// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./contracts/access/Ownable.sol";
contract TransferService  is Ownable {
    event payEv(address,address,uint256);
    // 向合约账户转账 
    function transderToContract()  public payable{
        (bool sent,) = payable(address(this)).call{value: msg.value}("");
        require(sent, "Call failed");
        emit payEv(msg.sender,address(this),msg.value);
    }
    
    // 获取合约账户余额 
    function getBalanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }
    //提取合约金额
    function withdraw() public onlyOwner {
         (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
        emit payEv(address(this),msg.sender,address(this).balance);
    }
    //合约给指定用户转账
    function toTaskerBounty(address _to,uint256 _bounty) public{
      (bool callSuccess, ) =  payable(_to).call{value: _bounty *1e18}("");
        require(callSuccess, "Call failed");
        emit payEv(address(this),_to,_bounty);
    }
    function pay(address _to) public payable {
       (bool callSuccess, )= payable(_to).call{value: msg.value}("");
       require(callSuccess, "Call failed");
       emit payEv(msg.sender,_to,msg.value);
    }
   
    // fallback() external payable {}
    
    // receive() external payable {}
}