// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AmphiTrans is Ownable {
    mapping(string => LibProject.TranslationPro) private taskList;
    mapping(address => uint256) private payList;
    mapping(address => bool) private isNoTransferState; //地址是否为可转移状态
    mapping(address => bool) private isAccessList;

    modifier isAccess() {
        require(msg.sender == owner()||isAccessList[msg.sender], "Error Access Address!");
        _;
    }

    function setAccessAddress(address _address) public onlyOwner {
        isAccessList[_address] = true;
    }
    function isHasAccessRole(address _address) public view returns(bool)
    {
        return isAccessList[_address];
    }
    //payList
    function addPay(address _tasker, uint256 _money) external isAccess {
        payList[_tasker] += _money;
    }

    function deductPay(address _tasker, uint256 _money) external isAccess {
        payList[_tasker] -= _money;
    }

    function getPay(address _tasker) external view returns (uint256) {
        return payList[_tasker];
    }

    //判断该地址是否为任务的服务者
    function isTasker(
        string memory _index,
        address _address
    ) external view returns (bool) {
        if (_address == getTasker(_index)) {
            return true;
        } else {
            return false;
        }
    }

    //获得任务的服务者
    function getTasker(string memory _index) public view returns (address) {
        return taskList[_index].tasker;
    }

    //判断是否加入了AI翻译
    function isJoinAI(string memory _index) external view returns (bool) {
        return taskList[_index].isAITrans;
    }

    function getFiles(
        string memory _index
    ) external view returns (LibProject.FileInfo[] memory) {
        return taskList[_index].tasks;
    }

    //增加不可转移名单
    function addNoTransferAddress(address _address) public {
        isNoTransferState[_address] = true;
    }

    //删除不可转移名单
    function deleteNoTransferAddress(address _address) external {
        delete isNoTransferState[_address];
    }

    //获取该地址是否为可转移状态
    function getIsTransferState(address _address) public view returns (bool) {
        return !isNoTransferState[_address]; //true 可转移，false 不可转移
    }

    //获得任务的翻译类型
    function getTranslationType(
        string memory _index
    ) external view returns (uint256) {
        return taskList[_index].translationType;
    }

    function getBuyer(string memory _index) public view returns (address) {
        return taskList[_index].buyer;
    }

    function getTaskState(
        string memory _index
    ) external view returns (LibProject.TaskState) {
        return taskList[_index].state;
    }

    function getProjectOne(
        string memory _index
    ) external view returns (LibProject.TranslationPro memory) {
        return taskList[_index];
    }

    function getTaskBounty(string memory _index) external view returns (uint256) {
        return taskList[_index].bounty;
    }

    function changeTaskerState(
        string memory _index,
        LibProject.TaskerState _state
    ) public isAccess {
        taskList[_index].transState = _state;
    }

    //修改任务状态
    function changeProjectState(
        string memory _index,
        LibProject.TaskState _state
    ) public isAccess {
        taskList[_index].state = _state;
        // emit changeProjectStateEv(_index, _state, msg.sender);
    }

    function addProject(
        LibProject.TranslationPro memory _t
    ) public isAccess {
        LibProject.TranslationPro storage _pro = taskList[_t.translationIndex];
        _pro.buyer = _t.buyer;
        _pro.releaseTime = _t.releaseTime;
        _pro.introduce = _t.introduce;
        _pro.need = _t.need;
        _pro.deadline = _t.deadline;
        _pro.sourceLanguage = _t.sourceLanguage;
        _pro.goalLanguage = _t.goalLanguage;
        _pro.preferList = _t.preferList;
        _pro.translationType = _t.translationType;
        _pro.workLoad = _t.workLoad;
        _pro.workLoadType = _t.workLoadType;
        _pro.bounty = _t.bounty;
        _pro.isNonDisclosure = _t.isNonDisclosure;
        _pro.isCustomize = _t.isCustomize;
        _pro.bounty = _t.bounty;
        for (uint256 i = 0; i < _t.tasks.length; i++) {
            _pro.tasks.push(_t.tasks[i]);
        }
        _pro.tasker = _t.tasker;
        _pro.state = _t.state;
        //将该任务的发布者和服务者地址均存入到不可转移名单中
        addNoTransferAddress(_pro.buyer);
        addNoTransferAddress(_pro.tasker);
    }

    function submitFileByTasker(
        string memory _index,
        string[] memory _files
    ) public returns (uint256) {
        uint256 _time = block.timestamp;
        for (uint256 i = 0; i < _files.length; i++) {
            taskList[_index].tasks[i].transFile = _files[i];
            taskList[_index].tasks[i].lastUpload = _time;
        }
        return _time;
    }
}
