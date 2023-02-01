// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./AmphiTrans.sol";
error FileException(string, LibProject.FileState);
contract AmphiTranImpl is AmphiTrans{
    event acceptTaskEv(
        uint256 taskIndex,
        uint256[] fileIndex,
        address taskerAddress,
        bool isTrans
    );
    event acceptTaskEv(
        uint256 taskIndex,
        uint256 fileIndex,
        address taskerAddress,
        bool isTrans
    );
    function receivePass(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex
    ) external {
        changeTaskVfState(
            _index,
            _taskerIndex,
            _fileIndex,
            LibProject.TaskerState.Completed
        );
        changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.Accepted
        );
    }
    function returnTaskerByBuyer(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex
    ) external {
        changeTaskVfState(
            _index,
            _taskerIndex,
            _fileIndex,
            LibProject.TaskerState.Return
        );
        changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.WaitVfModify
        );
    }
    function closeFileState(uint256 _index, uint256 _fileIndex) external {
        changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.Closed
        );
    }
    function updateTaskerStateByVf(
        uint256 _index,
        address _taskerAddress,
        uint256[] memory _fileIndex,
        LibProject.TaskerState _state
    ) public {
        for (uint256 i = 0; i < _fileIndex.length; i++) {
            changeTaskVfState(
                _index,
                _taskerAddress,
                _fileIndex[i],
                _state
            );
        }
    }
    function acceptTransToFileState(uint256 _index, uint256 _fileIndex)
        public
    {
        LibProject.FileState _state = getFileState(_index, _fileIndex);
        //根据目前文件状态，修改文件状态
        if (_state == LibProject.FileState.Waiting) {
            changeFileState(
                _index,
                _fileIndex,
                LibProject.FileState.WaitingForVf
            );
        } else if (_state == LibProject.FileState.WaitingForTrans) {
            changeFileState(
                _index,
                _fileIndex,
                LibProject.FileState.Translating
            );
        } else {
            revert FileException("File:Error file state", _state);
        }
    }

    function acceptVfToFileState(uint256 _index, uint256 _fileIndex) public {
        LibProject.FileState _state = getFileState(_index, _fileIndex);
        //根据目前文件状态，修改文件状态
        if (_state == LibProject.FileState.Waiting) {
            changeFileState(
                _index,
                _fileIndex,
                LibProject.FileState.WaitingForTrans
            );
        } else if (_state == LibProject.FileState.WaitingForVf) {
            changeFileState(
                _index,
                _fileIndex,
                LibProject.FileState.Translating
            );
        } else {
            revert FileException("Error file state", _state);
        }
    }
    function returnTaskerByVf(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex
    ) external {
        //修改任务者状态&修改文件状态
        changeTaskTransState(
            _index,
            _taskerIndex,
            _fileIndex,
            LibProject.TaskerState.Return
        );
        changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.WaitTransModify
        );
    }
    function updateTaskerStateByTrans(
        uint256 _index,
        address _taskerAddress,
        uint256[] memory _fileIndex,
        LibProject.TaskerState _state
    ) public {
        for (uint256 i = 0; i < _fileIndex.length; i++) {
            changeTaskTransState(
                _index,
                _taskerAddress,
                _fileIndex[i],
                _state
            );
        }
    }
    function  sumbitVfTask(
        uint256 _index,
        address _transIndex,
        address _vfIndex,
        uint256 _fileIndex,
        string memory _file
    ) external {
        changeTaskTransState(
            _index,
            _transIndex,
            _fileIndex,
            LibProject.TaskerState.Completed
        );
        changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.BuyerReview
        );
        changeTaskVfState(
            _index,
            _vfIndex,
            _fileIndex,
            LibProject.TaskerState.Submitted
        );
        submitFileByVf(_index, _vfIndex, _fileIndex, _file);
    }
    function sumbitTaskTrans(
        uint256 _index,
        uint256 _fileIndex,
        string memory _file,
        address _tasker
    ) external {
        changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.Validating
        );
        submitFileByTrans(_index, _tasker, _fileIndex, _file);
        changeTaskTransState(
            _index,
            _tasker,
            _fileIndex,
            LibProject.TaskerState.Submitted
        );
    }
    function closeTask(uint256 _index) external {
        changeProjectState(_index, LibProject.ProjectState.Closed);
    }
     function onNoOnePink(uint256 _index) external {
        changeProjectState(_index, LibProject.ProjectState.NoOnePick);
        changeVerActive(_index, false);
    }
    function getTaskInfo(uint256 _index)
        public
        view
        returns (LibProject.ReturnTask memory)
    {
        LibProject.ReturnTask memory _info;
        _info.pro = getProjectOne(_index);
        uint256 transLen = getTransNumber(_index);
        uint256 vfLen = getVfNumber(_index);
        address[] memory transList = getTranslatorsList(_index);
        address[] memory vfList = getVfList(_index);
        LibProject.ReturnTasker[]
            memory _transInfo = new LibProject.ReturnTasker[](transLen);
        LibProject.ReturnTasker[]
            memory _vfInfo = new LibProject.ReturnTasker[](vfLen);
        for (uint256 i = 0; i < transLen; i++) {
            _transInfo[i] = getTransTaskInfo(_index, transList[i]);
        }
        for (uint256 i = 0; i < vfLen; i++) {
            _vfInfo[i] = getVfTaskInfo(_index, vfList[i]);
        }
        _info.transInfo = _transInfo;
        _info.vfInfo = _vfInfo;
        return _info;
        // return service.getProjectOne(_index);
    }
     //超时未提交-翻译者
    function overTimeTrans(uint256 _index, address _taskerIndex,uint256[] memory _unCompleted)
        external
        returns (uint256)
    {
        //修改任务状态
        updateTaskerStateByTrans(
            _index,
            _taskerIndex,
            _unCompleted,
            LibProject.TaskerState.Overtime
        );
        uint256 _allBounty;
        if (isCustomizeState(_index)) {
            for (uint256 i = 0; i < _unCompleted.length; i++) {
                _allBounty += getFileBounty(_index, _unCompleted[i]);
            }
        } else {
            _allBounty = getTaskBounty(_index);
        }
        return _allBounty;
    }
 function overTimeVf(uint256 _index, address _taskerIndex,uint256[] memory _unCompleted)
        external
        returns (uint256)
    {
        updateTaskerStateByVf(
            _index,
            _taskerIndex,
            _unCompleted,
            LibProject.TaskerState.Overtime
        );
        //计算罚金
        uint256 _allBounty;
        if (isCustomizeState(_index)) {
            for (uint256 i = 0; i < _unCompleted.length; i++) {
                _allBounty += getFileBounty(_index, _unCompleted[i]);
            }
        } else {
            _allBounty = getTaskBounty(_index);
        }
        return _allBounty;
    }

    function acceptVf(
        uint256 _index,
        uint256[] memory _fileIndex,
        address _taskerIndex
    ) external {
        //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
        if (getAcceptVfNumber(_index, _taskerIndex) == 0) {
            addVf(_index, _taskerIndex);
        }
        for (uint256 q = 0; q < _fileIndex.length; q++) {
            acceptVfToFileState(_index, _fileIndex[q]);
            pushTaskVfIndex(_index, _taskerIndex, _fileIndex[q]);
        }
        //文件状态修改为翻译中
        addVfNumber(_index);
        if (isFull(_index, false)) {
            changeVerActive(_index, false);
            if (isFull(_index, true)) {
                changeProjectState(
                    _index,
                    LibProject.ProjectState.Processing
                );
            } else {
                changeProjectState(
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
    ) external {
        //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
        if (getAcceptTransNumber(_index, _taskerIndex) == 0) {
            addTranslators(_index, _taskerIndex);
        }
        for (uint256 q = 0; q < _fileIndex.length; q++) {
            acceptTransToFileState(_index, _fileIndex[q]);
            pushTaskTransIndex(_index, _taskerIndex, _fileIndex[q]);
        }
        //
        addTransNumber(_index);
        if (isFull(_index, true)) {
            changeTransActive(_index, false);
            if (isFull(_index, false)) {
                changeProjectState(
                    _index,
                    LibProject.ProjectState.Processing
                );
            } else {
                changeProjectState(
                    _index,
                    LibProject.ProjectState.WaitingForVf
                );
            }
        }
    }
    function distrToTrans (uint256 _index,LibProject.TaskInfo[] memory _tasks,uint256 _transNumber) external {
        address[] memory _list = getTranslatorsList(_index);
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
                            getAcceptTransNumber(_index, _list[q]) >
                            _tasks.length / _transNumber
                        ) {
                            continue;
                        }
                        //将当前任务分配给翻译者
                        addTransNumber(_index);
                        pushTaskTransIndex(_index, _list[q], i);
                        acceptTransToFileState(_index, i);
                        emit acceptTaskEv(_index, i, _list[q], true);
                        break;
                    }
                }
            }
            changeTransActive(_index, false);
            if (isFull(_index, false)) {
                changeProjectState(
                    _index,
                    LibProject.ProjectState.Processing
                );
            } else {
                changeProjectState(
                    _index,
                    LibProject.ProjectState.WaitingForVf
                );
            }
    }
    function distrToVf(uint256 _index,LibProject.TaskInfo[] memory _tasks,uint256 _vfNumber) external {
         //若有部分人接收
            // uint256 _count = _tasks.length;
            // uint256 _acceptedNum = vfNumber;
            // uint256 avgNum = _tasks.length / _vfNumber;
            address[] memory _list = getVfList(_index);
            for (uint256 i = 0; i < _tasks.length; i++) {
                //任务为待接收状态
                if (_tasks[i].state == LibProject.FileState.Waiting) {
                    //为未分配任务分配任务者
                    for (uint256 q = 0; q < _vfNumber; q++) {
                        //超出分配线，不予分配
                        if (
                            getAcceptVfNumber(_index, _list[q]) > _tasks.length / _vfNumber
                        ) {
                            continue;
                        }
                        //将当前任务分配给翻译者
                        addVfNumber(_index);
                        pushTaskVfIndex(_index, _list[q], i);
                        acceptVfToFileState(_index, i);
                        emit acceptTaskEv(_index, i, _list[q], false);
                        break;
                    }
                }
            }
            changeVerActive(_index, false);
            if (isFull(_index, true)) {
                changeProjectState(
                    _index,
                    LibProject.ProjectState.Processing
                );
            } else {
                changeProjectState(
                    _index,
                    LibProject.ProjectState.WaitingForTrans
                );
            }
    }
}