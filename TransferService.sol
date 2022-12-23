// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./contracts/access/Ownable.sol";
contract TransferService {
    address constant AMPHI_ADDRESS = 0x6CA0189baF54f88684ED158193021e45745F810e;
    event payEv(address,address,uint256);
    //锁
    bool locked;
 
    modifier noLock() {
        require(!locked, "The lock is locked.");
        locked = true;
        _;
        locked = false;
    }
    // 向合约账户转账 
    function transderToContract()  public payable{
        (bool sent,) = payable(address(this)).call{value: msg.value}("");
        require(sent, "Call failed");
        emit payEv(msg.sender,address(this),msg.value);
        //payable(address(this)).transfer(msg.value);
    }
    
    // 获取合约账户余额 
    function getBalanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }
    //提取合约金额
    function _withdraw(uint256 _money) internal  {
        //  (bool callSuccess, ) = payable(AMPHI_ADDRESS).call{value: address(this).balance}("");
        (bool callSuccess, ) = payable(AMPHI_ADDRESS).call{value: _money *1e18}("");
        require(callSuccess, "Call failed");
        emit payEv(address(this),msg.sender,address(this).balance);
    }
    //合约给指定用户转账
    function toTaskerBounty(address _to,uint256 _bounty) internal{
      require(getBalanceOfContract()>= _bounty *1e18, "The balance is not sufficient.");
      (bool callSuccess, ) =  payable(_to).call{value: _bounty *1e18}("");
        require(callSuccess, "Call failed");
        emit payEv(address(this),_to,_bounty);
    }
    //转账
    function pay(address _to) public payable noLock{
       (bool callSuccess, )= payable(_to).call{value: msg.value}("");
       require(callSuccess, "Call failed");
       emit payEv(msg.sender,_to,msg.value);
    }
   
    fallback() external payable {}
    
    receive() external payable {}
}