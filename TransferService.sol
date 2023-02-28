// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./contracts/access/Ownable.sol";

contract TransferService is Ownable{
   // address internal amphi_address;
    event payEv(address from, address to, uint256 money);
    bool locked;
    address private accessAddress;
    // constructor() {
    //     amphi_address = msg.sender;
    // }
    modifier noLock() {
        require(!locked, "The lock is locked.");
        locked = true;
        _;
        locked = false;
    }
    function setAccessAddress(address _address) public onlyOwner{
        accessAddress = _address;
    }
    // 向合约账户转账
    function transderToContract() public payable {
        (bool sent, ) = payable(address(this)).call{value: msg.value}("");
        require(sent, "Call failed");
        emit payEv(msg.sender, address(this), msg.value);
        //payable(address(this)).transfer(msg.value);
    }

    // 获取合约账户余额
    function getBalanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }

    //提取合约金额
    function withdraw(uint256 _money) public onlyOwner{
        //  (bool callSuccess, ) = payable(AMPHI_ADDRESS).call{value: address(this).balance}("");
        (bool callSuccess, ) = payable(owner()).call{
            value: _money * 1e18
        }("");
        require(callSuccess, "Call failed");
        emit payEv(address(this), msg.sender, address(this).balance);
    }

    function withdrawAll() public onlyOwner{
        (bool callSuccess, ) = payable(owner()).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
        emit payEv(address(this), msg.sender, address(this).balance);
    }

    function toTaskerBounty(address _to, uint256 _bounty) public noLock {
        require(msg.sender == accessAddress,"Error Access Address!");
        require(
            getBalanceOfContract() >= _bounty,
            "The balance is not sufficient."
        );
        (bool callSuccess, ) = payable(_to).call{value: _bounty}("");
        require(callSuccess, "Call failed");
        emit payEv(address(this), _to, _bounty);
    }
    fallback() external payable {}

    receive() external payable {}
}
