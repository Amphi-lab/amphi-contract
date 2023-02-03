// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./AmphiTrans.sol";
import "./contracts/access/Ownable.sol";
error OperationException(string);
error ErrorValue(string, uint256);
error Permissions(string);
error FileException(string, LibProject.FileState);
contract AmphiWorkOther is Ownable{
     address private serviceAddess;
     address private accessAddress;
     AmphiTrans private service;
     mapping(address => bool) private isNoTransferState;
     constructor(address _serviceAddress) {
         serviceAddess = _serviceAddress;
     }
     event acceptTaskEv(
        uint256 taskIndex,
        uint256 fileIndex,
        address taskerAddress,
        bool isTrans
    );
    modifier isAccess() {
        if(msg.sender != accessAddress) {
            revert  AccessError("Error Access Address!");
        }
        _;
    }
    function setAccessAddress(address _address) public onlyOwner{
        accessAddress = _address;
    }
     function update(address _newAddress) public isAccess{
         if(_newAddress!= serviceAddess) {
             serviceAddess = _newAddress;
         }
     }
     function getTransferState(address _address) public view returns(bool) {
         return !(isNoTransferState[_address]);
     }
     //添加任务
     function addTask(LibProject.ProParm memory _t)
        public
        isAccess
        returns (uint256)
    {
        service = AmphiTrans(serviceAddess);
        uint256 _index = service.addProject(_t);
        return _index;
    }
    //修改任务
    function updateTaskByBuyer(uint256 _index, LibProject.ProParm memory _t)
        public
        isAccess
    {
        service = AmphiTrans(serviceAddess);
        service.updateProject(_index, _t);
    }
    function endTransAccept(uint256 _index)
        public
        isAccess
        returns (bool, string memory)
    {
        service = AmphiTrans(serviceAddess);
        uint256 _transNumber = service.getTransNumber(_index);
        LibProject.TaskInfo[] memory _tasks = service.getFiles(_index);
        if (service.isFull(_index, true)) {
            //若到截至日期已经完成接单，则返回true
            return (true, "");
            //若到翻译截至日期，仍无人接单，则关闭翻译接单状态
        } else if (_transNumber == 0) {
            service.changeTransActive(_index, false);
            return (false, "translators number = 0");
        } else {
            uint256 _count = _tasks.length;
            uint256 _acceptedNum = _transNumber;
            uint256 avgNum = _count / _acceptedNum;
            address[] memory _list = service.getTranslatorsList(_index);
            for (uint256 i = 0; i < _tasks.length; i++) {
                //任务为待接收状态
                if (
                    _tasks[i].state == LibProject.FileState.Waiting ||
                    _tasks[i].state == LibProject.FileState.WaitingForTrans
                ) {
                    //为未分配任务分配任务者
                    for (uint256 q = 0; q < _transNumber; q++) {
                        //超出分配线，不予分配
                        if (
                            service.getAcceptTransNumber(_index, _list[q]) >
                            avgNum
                        ) {
                            continue;
                        }
                        //将当前任务分配给翻译者
                        service.addTransNumber(_index);
                        service.pushTaskTransIndex(_index, _list[q], i);
                        _acceptTransToFileState(_index, i);
                        emit acceptTaskEv(_index, i, _list[q], true);
                        break;
                    }
                }
            }
            service.changeTransActive(_index, false);
            if (service.isFull(_index, false)) {
                service.changeProjectState(
                    _index,
                    LibProject.ProjectState.Processing
                );
            } else {
                service.changeProjectState(
                    _index,
                    LibProject.ProjectState.WaitingForVf
                );
            }
            return (false, "Allocation completed");
        }
    }
     function _acceptTransToFileState(uint256 _index, uint256 _fileIndex)
        internal
    {
        service = AmphiTrans(serviceAddess);
        LibProject.FileState _state = service.getFileState(_index, _fileIndex);
        //根据目前文件状态，修改文件状态
        if (_state == LibProject.FileState.Waiting) {
            service.changeFileState(
                _index,
                _fileIndex,
                LibProject.FileState.WaitingForVf
            );
        } else if (_state == LibProject.FileState.WaitingForTrans) {
            service.changeFileState(
                _index,
                _fileIndex,
                LibProject.FileState.Translating
            );
        } else {
            revert FileException("Error file state", _state);
        }
    }
    function endTransVf(uint256 _index)
        public
        isAccess
        returns (bool, string memory)
    {
         service = AmphiTrans(serviceAddess);
        uint256 vfNumber = service.getVfNumber(_index);
        uint256 _transNumber = service.getTransNumber(_index);
        LibProject.TaskInfo[] memory _tasks = service.getFiles(_index);
        if (service.isFull(_index, false)) {
            return (true, "is full");
        } else if (vfNumber == 0 && _transNumber != 0) {
            service.changeVerActive(_index, false);
            return (true, "verifiers number =0");
        } else if (vfNumber == 0 && _transNumber == 0) {
            //若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
            _onNoOnePink(_index);
            return (false, "no one pink");
        } else {
            //若有部分人接收
            uint256 _count = _tasks.length;
            uint256 _acceptedNum = vfNumber;
            uint256 avgNum = _count / _acceptedNum;
            address[] memory _list = service.getVfList(_index);
            for (uint256 i = 0; i < _tasks.length; i++) {
                //任务为待接收状态
                if (_tasks[i].state == LibProject.FileState.Waiting) {
                    //为未分配任务分配任务者
                    for (uint256 q = 0; q < vfNumber; q++) {
                        //超出分配线，不予分配
                        if (
                            service.getAcceptVfNumber(_index, _list[q]) > avgNum
                        ) {
                            continue;
                        }
                        //将当前任务分配给翻译者
                        service.addVfNumber(_index);
                        service.pushTaskVfIndex(_index, _list[q], i);
                        _acceptVfToFileState(_index, i);
                        emit acceptTaskEv(_index, i, _list[q], false);
                        break;
                    }
                }
            }
            service.changeVerActive(_index, false);
            if (service.isFull(_index, true)) {
                service.changeProjectState(
                    _index,
                    LibProject.ProjectState.Processing
                );
            } else {
                service.changeProjectState(
                    _index,
                    LibProject.ProjectState.WaitingForTrans
                );
            }
        }
        return (true, "Allocation completed");
    } 
    function acceptVf(
        uint256 _index,
        uint256[] memory _fileIndex,
        address _taskerIndex
    ) public isAccess{
         service = AmphiTrans(serviceAddess);
        //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
        if (service.getAcceptVfNumber(_index, _taskerIndex) == 0) {
            service.addVf(_index, _taskerIndex);
            isNoTransferState[_taskerIndex] = true;
        }
        for (uint256 q = 0; q < _fileIndex.length; q++) {
            _acceptVfToFileState(_index, _fileIndex[q]);
            service.pushTaskVfIndex(_index, _taskerIndex, _fileIndex[q]);
        }
        //文件状态修改为翻译中
        service.addVfNumber(_index);
        service.addVfWaitNumber(_index,_taskerIndex);
        if (service.isFull(_index, false)) {
            service.changeVerActive(_index, false);
            if (service.isFull(_index, true)) {
                service.changeProjectState(
                    _index,
                    LibProject.ProjectState.Processing
                );
            } else {
                service.changeProjectState(
                    _index,
                    LibProject.ProjectState.WaitingForTrans
                );
            }
        }
        
    }
    function acceptTrans(
        uint256 _index,
        uint256[] memory _fileIndex,
        address _taskerIndex
    ) public isAccess{
         service = AmphiTrans(serviceAddess);
        //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
        if (service.getAcceptTransNumber(_index, _taskerIndex) == 0) {
            service.addTranslators(_index, _taskerIndex);
            isNoTransferState[_taskerIndex] = true;
        }
        for (uint256 q = 0; q < _fileIndex.length; q++) {
            _acceptTransToFileState(_index, _fileIndex[q]);
            service.pushTaskTransIndex(_index, _taskerIndex, _fileIndex[q]);
        }
        //
        service.addTransNumber(_index);
        service.addTransWaitNumber(_index,_taskerIndex);
        if (service.isFull(_index, true)) {
            service.changeTransActive(_index, false);
            if (service.isFull(_index, false)) {
                service.changeProjectState(
                    _index,
                    LibProject.ProjectState.Processing
                );
            } else {
                service.changeProjectState(
                    _index,
                    LibProject.ProjectState.WaitingForVf
                );
            }
        }
    }
     //发布者验收
    function receiveTask(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex,
        bool _isPass
    ) public isAccess{
        service = AmphiTrans(serviceAddess);
        //若校验通过，将任务者的状态修改为已完成
        if (_isPass) {
             service.changeTaskVfState(
            _index,
            _taskerIndex,
            _fileIndex,
            LibProject.TaskerState.Completed
        );
        service.changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.Accepted
        );
        service.decutVfWaitNumber(_index,_taskerIndex);
        if(service.getVfWaitNumber(_index,_taskerIndex)<=0) {
            delete isNoTransferState[_taskerIndex];
        }
        } else {
            //任务不通过，将任务者的状态修改为被打回状态
            service.changeTaskVfState(
            _index,
            _taskerIndex,
            _fileIndex,
            LibProject.TaskerState.Return
        );
        service.changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.WaitVfModify
        );
        }
    }

     function _onNoOnePink(uint256 _index) internal {
        service = AmphiTrans(serviceAddess);
        service.changeProjectState(_index, LibProject.ProjectState.NoOnePick);
        service.changeVerActive(_index, false);
        delete isNoTransferState[service.getBuyer(_index)];
        address[] memory transList = service.getTranslatorsList(_index);
        address[] memory vflist = service.getVfList(_index);
        for(uint256 i=0;i<transList.length;i++) {
            delete isNoTransferState[transList[i]];
        }
        for(uint256 i=0;i<transList.length;i++) {
            delete isNoTransferState[vflist[i]];
        }
    }
     function _acceptVfToFileState(uint256 _index, uint256 _fileIndex) internal {
       service = AmphiTrans(serviceAddess);
        LibProject.FileState _state = service.getFileState(_index, _fileIndex);
        //根据目前文件状态，修改文件状态
        if (_state == LibProject.FileState.Waiting) {
            service.changeFileState(
                _index,
                _fileIndex,
                LibProject.FileState.WaitingForTrans
            );
        } else if (_state == LibProject.FileState.WaitingForVf) {
            service.changeFileState(
                _index,
                _fileIndex,
                LibProject.FileState.Translating
            );
        } else {
            revert FileException("Error file state", _state);
        }
    }
     //校验者验收
    function validate(
        uint256 _index,
        address _transAddress,
        address _vfAddress,
        uint256 _fileIndex,
        bool _isPass,
        string memory _file
    ) public isAccess returns (uint256 _payBounty) {
        service = AmphiTrans(serviceAddess);
        //若校验通过，将任务者的状态修改为已完成
        if (_isPass) {
            //若用户为自定义支付，则完成后支付任务者赏金
            _sumbitVfTask(_index, _transAddress, _vfAddress, _fileIndex, _file);
            bool _Customize = service.isCustomizeState(_index);
            if (_Customize) {
                _payBounty = service.getFileBounty(_index, _fileIndex);
            } else {
                _payBounty = service.getTaskBounty(_index);
            }
            service.decutTransWaitNumber(_index,_transAddress);
            if(service.getTransWaitNumber(_index,_transAddress) <=0) {
                delete isNoTransferState[_transAddress];
            }
            
        } else {
            //任务不通过，将任务者的状态修改为被打回状态
            service.changeTaskTransState(
            _index,
            _transAddress,
            _fileIndex,
            LibProject.TaskerState.Return
        );
        service.changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.WaitTransModify
        );
            _payBounty = 0;
        }
    }
    function sumbitTaskTrans(
        uint256 _index,
        uint256 _fileIndex,
        string memory _file,
        address _tasker
    ) public isAccess{
        service = AmphiTrans(serviceAddess);
        service.changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.Validating
        );
        service.submitFileByTrans(_index, _tasker, _fileIndex, _file);
        service.changeTaskTransState(
            _index,
            _tasker,
            _fileIndex,
            LibProject.TaskerState.Submitted
        );
    }
     //超时未提交-翻译者
    function overTimeTrans(uint256 _index, address _taskerIndex)
        public 
        isAccess
        returns (uint256,uint256)
    {
        service = AmphiTrans(serviceAddess);
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted, _money) = service.overTimeTasker(
            _index,
            _taskerIndex,
            true
        );
        if (_unCompleted.length == 0) {
            return (0,0);
        }
        //修改任务状态
        for (uint256 i = 0; i < _unCompleted.length; i++) {
            service.changeTaskTransState(
                _index,
                _taskerIndex,
                _unCompleted[i],
                LibProject.TaskerState.Overtime
            );
        }
        uint256 _allBounty;
        if (service.isCustomizeState(_index)) {
            for (uint256 i = 0; i < _unCompleted.length; i++) {
                _allBounty += service.getFileBounty(_index, _unCompleted[i]);
            }
        } else {
            _allBounty = service.getTaskBounty(_index);
        }
        delete isNoTransferState[_taskerIndex];
        //返回罚金
        return (_money,_allBounty);
    }

    //超时未提交-校验者
    function overTimeVf(uint256 _index, address _taskerIndex)
        public
        isAccess
        returns (uint256,uint256)
    {
        service = AmphiTrans(serviceAddess);
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted, _money) = service.overTimeTasker(
            _index,
            _taskerIndex,
            false
        );
        if (_unCompleted.length == 0) {
            return (0,0);
        }
         for (uint256 i = 0; i < _unCompleted.length; i++) {
            service.changeTaskVfState(
                _index,
                _taskerIndex,
                _unCompleted[i],
                LibProject.TaskerState.Overtime
            );
        }
        //计算罚金
        uint256 _allBounty;
        if (service.isCustomizeState(_index)) {
            for (uint256 i = 0; i < _unCompleted.length; i++) {
                _allBounty += service.getFileBounty(_index, _unCompleted[i]);
            }
        } else {
            _allBounty = service.getTaskBounty(_index);
        }
        delete isNoTransferState[_taskerIndex];
        return (_money,_allBounty);
    }
    function deductPay(address _to,uint256 _value) public isAccess{
        service = AmphiTrans(serviceAddess);
        service.deductPay(_to, _value);
    }
    function closeTask(uint256 _index) public isAccess{
        service = AmphiTrans(serviceAddess);
        service.changeProjectState(_index, LibProject.ProjectState.Closed);
    }
     function _sumbitVfTask(
        uint256 _index,
        address _transIndex,
        address _vfIndex,
        uint256 _fileIndex,
        string memory _file
    ) internal {
        service = AmphiTrans(serviceAddess);
        service.changeTaskTransState(
            _index,
            _transIndex,
            _fileIndex,
            LibProject.TaskerState.Completed
        );
        service.changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.BuyerReview
        );
        service.changeTaskVfState(
            _index,
            _vfIndex,
            _fileIndex,
            LibProject.TaskerState.Submitted
        );
        service.submitFileByVf(_index, _vfIndex, _fileIndex, _file);
    }
    
}