// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";

interface IAmphiTrans {}

contract AmphiTrans {
    mapping(uint256 => LibProject.TranslationPro) private taskList;
    mapping(address => uint256) private payList;
    mapping(uint256 => mapping(address => LibProject.Tasker)) transInfo; //翻译者接单信息
    mapping(uint256 => mapping(address => LibProject.Tasker)) vfInfo;
    uint256 private count;
    //任务索引值，文件索引值，文件状态，操作者
    event changeFileStateEv(
        uint256 taskIndex,
        uint256 fileInfo,
        LibProject.FileState fileSate,
        address opSender
    );
    //任务索引值，文件状态，操作者
    event changeProjectStateEv(
        uint256 taskIndex,
        LibProject.ProjectState taskState,
        address opSender
    );
    //任务索引值、任务者地址、文件索引值，任务者状态，是否为翻译者,操作者
    event changeTaskerStateEv(
        uint256 taskIndex,
        address tasker,
        uint256 fileIndex,
        LibProject.TaskerState taskerState,
        bool isTrans,
        address opSender
    );
    //任务索引值，是否关闭，操作者

    event changeTransActiveEv(
        uint256 taskIndex,
        bool transActive,
        address opSender
    );
    event changeVerActiveEv(
        uint256 taskIndex,
        bool verActive,
        address opSender
    );
    event submitFileEv(
        uint256 index,
        uint256 fileIndex,
        uint256 uploadtime,
        string file,
        address sender,
        bool isTrans
    );

    //count
    function addCount() external {
        ++count;
    }

    function getCount() external view returns (uint256) {
        return count;
    }

    //payList
    function addPay(address _tasker, uint256 _money) external {
        payList[_tasker] += _money;
    }

    function deductPay(address _tasker, uint256 _money) external {
        payList[_tasker] -= _money;
    }

    function getPay(address _tasker) external view returns (uint256) {
        return payList[_tasker];
    }

    //taskList

    //判断任务是否已被接满
    function isFull(uint256 _index, bool _isTrans) public view returns (bool) {
        if (_isTrans) {
            return taskList[_index].maxT <= taskList[_index].numberT;
        } else {
            return taskList[_index].maxV <= taskList[_index].numberV;
        }
    }

    function getFiles(uint256 _index)
        public
        view
        returns (LibProject.TaskInfo[] memory)
    {
        return taskList[_index].tasks;
    }

    //任务翻译者总数量
    function getTransNumber(uint256 _index) public view returns (uint256) {
        return taskList[_index].translators.length;
    }

    function getVfNumber(uint256 _index) public view returns (uint256) {
        return taskList[_index].verifiers.length;
    }

    //获得指定任务翻译者接单数
    function getAcceptTransNumber(uint256 _index, address _taskerIndex)
        public
        view
        returns (uint256)
    {
        return transInfo[_index][_taskerIndex].taskIndex.length;
    }

    function getAcceptVfNumber(uint256 _index, address _taskerIndex)
        public
        view
        returns (uint256)
    {
        return vfInfo[_index][_taskerIndex].taskIndex.length;
    }

    //获得翻译者名单
    function getTranslatorsList(uint256 _index)
        public
        view
        returns (address[] memory)
    {
        return taskList[_index].translators;
    }

    //获得校验者名单
    function getVfList(uint256 _index) public view returns (address[] memory) {
        return taskList[_index].verifiers;
    }

    //是否为自定义支付
    function isCustomizeState(uint256 _index) public view returns (bool) {
        return taskList[_index].isCustomize;
    }

    //查询任务者超时未完成任务数
    function overTimeTasker(
        uint256 _index,
        address _taskerIndex,
        bool _isTrans
    ) public view returns (uint256[] memory, uint256) {
        uint256[] memory _filesIndex;
        uint256[] memory _list;
        uint256 money;
        uint256 q;
        if (_isTrans) {
            _filesIndex = transInfo[_index][_taskerIndex].taskIndex;
        } else {
            _filesIndex = vfInfo[_index][_taskerIndex].taskIndex;
        }
        LibProject.FileIndexInfo memory _info;
        for (uint256 i = 0; i < _filesIndex.length; i++) {
            _info = transInfo[_index][_taskerIndex].info[_filesIndex[i]];
            if (_info.state == LibProject.TaskerState.Processing) {
                _list[q] = _filesIndex[i];
                q++;
                money += taskList[_index].tasks[_filesIndex[i]].bounty;
            }
        }
        return (_list, money);
    }

    function getBuyer(uint256 _index) public view returns (address) {
        return taskList[_index].buyer;
    }

    function getTaskState(uint256 _index)
        public
        view
        returns (LibProject.ProjectState)
    {
        return taskList[_index].state;
    }

    function getFileState(uint256 _index, uint256 _fileIndex)
        public
        view
        returns (LibProject.FileState)
    {
        return taskList[_index].tasks[_fileIndex].state;
    }

    function getTaskStateVf(uint256 _index) public view returns (bool) {
        return taskList[_index].isVerActive;
    }

    function getTaskStateTrans(uint256 _index) public view returns (bool) {
        return taskList[_index].isTransActive;
    }

    //获得翻译者任务详细信息
    function getTransTaskInfo(uint256 _index, address _address)
        public
        view
        returns (LibProject.ReturnTasker memory)
    {
        LibProject.ReturnTasker memory _taskerInfo;
        _taskerInfo.taskerAddress = _address;
        _taskerInfo.taskIndex = transInfo[_index][_address].taskIndex;
        LibProject.FileIndexInfo[]
            memory _fileIndexInfo = new LibProject.FileIndexInfo[](
                _taskerInfo.taskIndex.length
            );
        //  LibProject.FileIndexInfo memory _info;
        for (uint256 q = 0; q < _taskerInfo.taskIndex.length; q++) {
            _fileIndexInfo[q].state = transInfo[_index][_address]
                .info[_taskerInfo.taskIndex[q]]
                .state;
            _fileIndexInfo[q].file = transInfo[_index][_address]
                .info[_taskerInfo.taskIndex[q]]
                .file;
        }
        _taskerInfo.taskerinfo = _fileIndexInfo;
        return _taskerInfo;
    }

    function getProjectOne(uint256 _index)
        external
        view
        returns (LibProject.TranslationPro memory)
    {
        return taskList[_index];
    }

    //获得校验者任务详细信息
    function getVfTaskInfo(uint256 _index, address _address)
        public
        view
        returns (LibProject.ReturnTasker memory)
    {
        LibProject.ReturnTasker memory _taskerInfo;
        _taskerInfo.taskerAddress = _address;
        _taskerInfo.taskIndex = vfInfo[_index][_address].taskIndex;
        LibProject.FileIndexInfo[]
            memory _fileIndexInfo = new LibProject.FileIndexInfo[](
                _taskerInfo.taskIndex.length
            );
        for (uint256 q = 0; q < _taskerInfo.taskIndex.length; q++) {
            _fileIndexInfo[q].state = vfInfo[_index][_address]
                .info[_taskerInfo.taskIndex[q]]
                .state;
            _fileIndexInfo[q].file = vfInfo[_index][_address]
                .info[_taskerInfo.taskIndex[q]]
                .file;
        }
        _taskerInfo.taskerinfo = _fileIndexInfo;
        return _taskerInfo;
    }

    function getFileBounty(uint256 _index, uint256 _fileIndex)
        public
        view
        returns (uint256)
    {
        return taskList[_index].tasks[_fileIndex].bounty;
    }

    function getTaskBounty(uint256 _index) public view returns (uint256) {
        return taskList[_index].bounty;
    }

    function changeTaskVfState(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex,
        LibProject.TaskerState _state
    ) external {
        vfInfo[_index][_taskerIndex].info[_fileIndex].state = _state;
        emit changeTaskerStateEv(
            _index,
            _taskerIndex,
            _fileIndex,
            _state,
            false,
            msg.sender
        );
    }

    function changeTaskTransState(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex,
        LibProject.TaskerState _state
    ) external {
        transInfo[_index][_taskerIndex].info[_fileIndex].state = _state;
        emit changeTaskerStateEv(
            _index,
            _taskerIndex,
            _fileIndex,
            _state,
            true,
            msg.sender
        );
    }

    //修改文件状态
    function changeFileState(
        uint256 _index,
        uint256 _fileIndex,
        LibProject.FileState _state
    ) external {
        taskList[_index].tasks[_fileIndex].state = _state;
        emit changeFileStateEv(_index, _fileIndex, _state, msg.sender);
    }

    //修改任务状态
    function changeProjectState(uint256 _index, LibProject.ProjectState _state)
        external
    {
        taskList[_index].state = _state;
        emit changeProjectStateEv(_index, _state, msg.sender);
    }

    //修改翻译者接单状态
    function changeTransActive(uint256 _index, bool _bool) external {
        taskList[_index].isTransActive = _bool;
        emit changeTransActiveEv(_index, _bool, msg.sender);
    }

    //修改校验者接单状态
    function changeVerActive(uint256 _index, bool _bool) external {
        taskList[_index].isVerActive = _bool;
        emit changeVerActiveEv(_index, _bool, msg.sender);
    }

    //增加翻译者人数
    function addTransNumber(uint256 _index) external {
        taskList[_index].numberT++;
    }

    //增加校验则人数
    function addVfNumber(uint256 _index) external {
        taskList[_index].numberV++;
    }

    //添加翻译者接单任务-文件索引
    function pushTaskTransIndex(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex
    ) external {
        transInfo[_index][_taskerIndex].taskIndex.push(_fileIndex);
    }

    function pushTaskVfIndex(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex
    ) external {
        vfInfo[_index][_taskerIndex].taskIndex.push(_fileIndex);
    }

    //添加翻译者名单
    function addTranslators(uint256 _index, address _address) external {
        taskList[_index].translators.push(_address);
    }

    function addVf(uint256 _index, address _address) external {
        taskList[_index].verifiers.push(_address);
    }

    function addProject(LibProject.ProParm memory _t)
        external
        returns (uint256)
    {
        count++;
        //  taskIndex[_buyer].push(count);
        LibProject.TranslationPro storage _pro = taskList[count];
        _pro.buyer = msg.sender;
        _pro.releaseTime = _t.releaseTime;
        _pro.introduce = _t.introduce;
        _pro.need = _t.need;
        _pro.deadline = _t.deadline;
        _pro.sourceLanguage = _t.sourceLanguage;
        _pro.goalLanguage = _t.goalLanguage;
        _pro.preferList = _t.preferList;
        _pro.translationType = _t.translationType;
        _pro.workLoad = _t.workLoad;
        _pro.bounty = _t.bounty;
        _pro.isNonDisclosure = _t.isNonDisclosure;
        _pro.isCustomize = _t.isCustomize;
        if (_t.isCustomize) {
            _pro.maxT = _t.tasks.length;
            _pro.maxV = _t.tasks.length;
        } else {
            _pro.maxT = 1;
            _pro.maxV = 1;
        }
        // _pro.state = LibProject.ProjectState.Published;
        _pro.isTransActive = true;
        _pro.isVerActive = true;
        for (uint256 i = 0; i < _t.tasks.length; i++) {
            _t.tasks[i].state = LibProject.FileState.Waiting;
            _pro.tasks.push(_t.tasks[i]);
        }
        return count;
    }

    function updateProject(uint256 _index, LibProject.ProParm memory _t)
        external
    {
        LibProject.TranslationPro storage _pro = taskList[_index];
        _pro.releaseTime = _t.releaseTime;
        _pro.introduce = _t.introduce;
        _pro.need = _t.need;
        _pro.deadline = _t.deadline;
        _pro.sourceLanguage = _t.sourceLanguage;
        _pro.goalLanguage = _t.goalLanguage;
        _pro.preferList = _t.preferList;
        _pro.translationType = _t.translationType;
        _pro.workLoad = _t.workLoad;
        _pro.bounty = _t.bounty;
        _pro.isNonDisclosure = _t.isNonDisclosure;
        _pro.isCustomize = _t.isCustomize;
        // _pro.state = LibProject.ProjectState.Published;
        if (_t.isCustomize) {
            _pro.maxT = _t.tasks.length;
            _pro.maxT = _t.tasks.length;
        } else {
            _pro.maxT = 1;
            _pro.maxT = 1;
        }
        _pro.isTransActive = true;
        // _pro.state = LibProject.ProjectState.Published;
        for (uint256 i = 0; i < _t.tasks.length; i++) {
            _pro.tasks.push(_t.tasks[i]);
        }
    }

    function submitFileByTrans(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex,
        string memory _file
    ) external {
        uint256 _time = block.timestamp;
        taskList[_index].tasks[_fileIndex].lastUpload = _time;
        transInfo[_index][_taskerIndex].info[_fileIndex].file = _file;
        emit submitFileEv(_index, _fileIndex, _time, _file, _taskerIndex, true);
    }

    function submitFileByVf(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex,
        string memory _file
    ) external {
        uint256 _time = block.timestamp;
        taskList[_index].tasks[_fileIndex].lastUpload = block.timestamp;
        vfInfo[_index][_taskerIndex].info[_fileIndex].file = _file;
        emit submitFileEv(
            _index,
            _fileIndex,
            _time,
            _file,
            _taskerIndex,
            false
        );
    }
}
