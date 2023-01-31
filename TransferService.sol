// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./contracts/access/Ownable.sol";

contract TransferService is Ownable{
    address internal amphi_address;
    event payEv(address from, address to, uint256 money);
    bool locked;
    constructor() {
        amphi_address = msg.sender;
    }
    modifier noLock() {
        require(!locked, "The lock is locked.");
        locked = true;
        _;
        locked = false;
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
    function _withdraw(uint256 _money) internal onlyOwner{
        //  (bool callSuccess, ) = payable(AMPHI_ADDRESS).call{value: address(this).balance}("");
        (bool callSuccess, ) = payable(amphi_address).call{
            value: _money * 1e18
        }("");
        require(callSuccess, "Call failed");
        emit payEv(address(this), msg.sender, address(this).balance);
    }

    function _withdrawAll() internal onlyOwner{
        (bool callSuccess, ) = payable(amphi_address).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
        emit payEv(address(this), msg.sender, address(this).balance);
    }

    function toTaskerBounty(address _to, uint256 _bounty) internal noLock {
        require(
            getBalanceOfContract() >= _bounty,
            "The balance is not sufficient."
        );
        (bool callSuccess, ) = payable(_to).call{value: _bounty}("");
        require(callSuccess, "Call failed");
        emit payEv(address(this), _to, _bounty);
    }

    //转账
    function pay(address _to, uint256 _money) internal noLock {
        (bool callSuccess, ) = payable(_to).call{value: _money}("");
        require(callSuccess, "Call failed");
        emit payEv(msg.sender, _to, _money);
    }

    fallback() external payable {}

    receive() external payable {}
}
