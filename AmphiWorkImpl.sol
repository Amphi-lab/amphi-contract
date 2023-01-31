// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./AmphiTrans.sol";
import "./LibProject.sol";
import "./CalculateUtils.sol";
import "./TransferService.sol";
error OperationException(string);
error ErrorValue(string, uint256);
error Permissions(string);
error FileException(string, LibProject.FileState);

interface AmphiPass {
    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory);
}

contract AmphiWorkImpl is TransferService {
    event postProjectEv(
        address buyer,
        uint256 taskIndex,
        LibProject.ProParm taskInfo
    );
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

    AmphiPass amphi;
    AmphiTrans service;
    CalculateUtils utils;
    mapping(address => bool) private isNoTransferState;

    constructor(
        address _passAddress,
        address _serviceAddress,
        address _utilsAddress
    ) {
        amphi = AmphiPass(_passAddress);
        service = AmphiTrans(_serviceAddress);
        utils = CalculateUtils(_utilsAddress);
    }

    modifier isCanAcceptTrans(uint256 _index) {
        if (!service.getTaskStateTrans(_index)) {
            revert OperationException("Can't receive task");
        }
        _;
    }
    modifier isCanAcceptVf(uint256 _index) {
        if (!service.getTaskStateVf(_index)) {
            revert OperationException("Can't receive task");
        }
        _;
    }
    modifier onlyBuyer(uint256 _index) {
        require(service.getBuyer(_index) == msg.sender, "Only buyer");
        _;
    }
    modifier isExist(uint256 _index) {
        if (_index > service.getCount()) {
            revert ParameterException("Wrong index value!");
        }
        _;
    }
    modifier hasFine(address _address) {
        uint256 _money = service.getPay(_address);
        if (_money > 0) {
            revert Permissions("unpaid penalty!");
        }
        _;
    }
    modifier isHasNftPass() {
        if (!_isHasNftPass(msg.sender)) {
            revert Permissions("Not Have Pass NFT!");
        }
        _;
    }

    //发布任务
    //质押30%，校验通过，30%给翻译者，需求方验收通过，支付其余的赏金。
    //文件状态修改：翻译等待，校验等待
    function postTask(LibProject.ProParm memory _t)
        public
        payable
        isHasNftPass
        hasFine(msg.sender)
        returns (uint256 _index)
    {
        _index = _postTask(_t);
        //质押30%赏金
        uint256 _bounty = utils.getPercentage(_t.bounty * 1e18, 30);
        if (msg.value < _bounty) {
            revert ErrorValue("Incorrect value", msg.value);
        }
        isNoTransferState[msg.sender] = true;
        transderToContract();
    }

    function updateTask(uint256 _index, LibProject.ProParm memory _t)
        public
        payable
        isExist(_index)
        onlyBuyer(_index)
    {
        _updateTask(_index, _t);
        uint256 _bounty = utils.getPercentage(_t.bounty, 30);
        if (msg.value != _bounty * 1e18) {
            revert ErrorValue("Incorrect value", msg.value);
        }
        isNoTransferState[msg.sender] = true;
        transderToContract();
    }

    //截至日期处理
    function endTransAccept(uint256 _index) public isExist(_index) {
        _endTransAccept(_index);
    }

    function endTransVf(uint256 _index) public isExist(_index) {
        _endTransVf(_index);
    }

    function acceptForTranslator(uint256 _index, uint256[] memory _fileIndex)
        public
        isHasNftPass
        isExist(_index)
        isCanAcceptTrans(_index)
        hasFine(msg.sender)
    {
        _acceptTrans(_index, _fileIndex, msg.sender);
        emit acceptTaskEv(_index, _fileIndex, msg.sender, true);
        isNoTransferState[msg.sender] = true;
    }

    function acceptForVerifer(uint256 _index, uint256[] memory _fileIndex)
        public
        isHasNftPass
        isExist(_index)
        isCanAcceptVf(_index)
        hasFine(msg.sender)
    {
        _acceptVf(_index, _fileIndex, msg.sender);
        emit acceptTaskEv(_index, _fileIndex, msg.sender, false);
        isNoTransferState[msg.sender] = true;
    }

    function validate(
        uint256 _index,
        address _traner,
        uint256 _fileIndex,
        bool _isPass,
        string memory _file
    ) public isExist(_index) {
        LibProject.FileState _fileState;
        _fileState = service.getFileState(_index, _fileIndex);
        if (_fileState > LibProject.FileState.WaitVfModify) {
            revert OperationException("unable to submit");
        }
        uint256 _bounty = _validate(
            _index,
            _traner,
            _fileIndex,
            _isPass,
            _file
        );
        //发赏金
        if (_bounty > 0) {
            //   service.deductBounty(_index,_traner,_fileIndex,_bounty,true);
            toTaskerBounty(_traner, _bounty);
        }
    }

    function sumbitTaskTrans(
        uint256 _index,
        uint256 _fileIndex,
        string memory _file
    ) public isExist(_index) {
        LibProject.FileState _fileState;
        _fileState = service.getFileState(_index, _fileIndex);
        if (_fileState > LibProject.FileState.BuyerReview) {
            revert OperationException("unable to submit");
        }
        _sumbitTaskTrans(_index, _fileIndex, _file, msg.sender);
    }

    function overTimeTrans(uint256 _index, address _tasker)
        public
        isExist(_index)
        returns (uint256)
    {
        uint256 _money = _overTimeTrans(_index, _tasker);
        service.addPay(_tasker, _money);
        return _money;
    }

    function overTimeVf(uint256 _index, address _tasker)
        public
        isExist(_index)
        returns (uint256)
    {
        uint256 _money = _overTimeVf(_index, _tasker);
        service.addPay(_tasker, _money);
        return _money;
    }

    function receiveTask(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex,
        bool _isPass,
        address _transAddress
    ) public payable isExist(_index) onlyBuyer(_index) {
        uint256 _bounty;
        if (service.isCustomizeState(_index)) {
            _bounty = service.getFileBounty(_index, _fileIndex);
        } else {
            _bounty = service.getTaskBounty(_index);
        }
        _receiveTask(_index, _taskerIndex, _fileIndex, _isPass);
        //若验收通过，将合约剩余的70%的钱存入合约中
        if (_isPass) {
            uint256 _payMoney = utils.getPercentage(_bounty * 1e18, 70);
            if (msg.value < _payMoney) {
                revert ErrorValue("error : Incorrect value", msg.value);
            }
            transderToContract();
            uint256 _vfBounty = utils.getTaskVf(_bounty * 1e18);
            uint256 _transBounty = utils.getTaskTransEnd(_bounty * 1e18);
            toTaskerBounty(_taskerIndex, _vfBounty);
            toTaskerBounty(_transAddress, _transBounty);
        }
        delete isNoTransferState[msg.sender];
    }

    function withdraw(uint256 _money) public onlyOwner {
        _withdraw(_money);
    }

    function withdrawAll() public onlyOwner {
        _withdrawAll();
    }

    //支付罚金
    function payFine(address _to) public payable {
        if (msg.value > service.getPay(_to) * 1e18) {
            revert ErrorValue("value is too high", msg.value);
        }
        service.deductPay(_to, msg.value);
        pay(_to, msg.value);
    }

    function newAmphiPass(address _newAddress) public onlyOwner {
        amphi = AmphiPass(_newAddress);
    }

    function newCalculateUtils(address _newAddress) public onlyOwner {
        utils = CalculateUtils(_newAddress);
    }

    function newAmphiTrans(address _newAddress) public onlyOwner {
        service = AmphiTrans(_newAddress);
    }

    function closeTask(uint256 _index) public {
        service.changeProjectState(_index, LibProject.ProjectState.Closed);
    }

    function closeFileState(uint256 _index, uint256 _fileIndex) public {
        service.changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.Closed
        );
    }

    function getTaskInfo(uint256 _index)
        public
        view
        isExist(_index)
        returns (LibProject.ReturnTask memory)
    {
        LibProject.ReturnTask memory _info;
        _info.pro = service.getProjectOne(_index);
        uint256 transLen = service.getTransNumber(_index);
        uint256 vfLen = service.getVfNumber(_index);
        address[] memory transList = service.getTranslatorsList(_index);
        address[] memory vfList = service.getVfList(_index);
        LibProject.ReturnTasker[]
            memory _transInfo = new LibProject.ReturnTasker[](transLen);
        LibProject.ReturnTasker[]
            memory _vfInfo = new LibProject.ReturnTasker[](vfLen);
        for (uint256 i = 0; i < transLen; i++) {
            _transInfo[i] = service.getTransTaskInfo(_index, transList[i]);
        }
        for (uint256 i = 0; i < vfLen; i++) {
            _vfInfo[i] = service.getVfTaskInfo(_index, vfList[i]);
        }
        _info.transInfo = _transInfo;
        _info.vfInfo = _vfInfo;
        return _info;
        // return service.getProjectOne(_index);
    }

    function getFileState(uint256 _index, uint256 _fileIndex)
        public
        view
        returns (LibProject.FileState)
    {
        return service.getFileState(_index, _fileIndex);
    }

    function getPay(address _address) public view returns (uint256) {
        return service.getPay(_address);
    }

    function getCount() public view returns (uint256) {
        return service.getCount();
    }

    function getTaskState(uint256 _index)
        public
        view
        returns (LibProject.ProjectState)
    {
        return service.getTaskState(_index);
    }

    function getIsTransferState(address _address) public view returns (bool) {
        return !(isNoTransferState[_address]);
    }

    //发布者验收
    function _receiveTask(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex,
        bool _isPass
    ) internal {
        //若校验通过，将任务者的状态修改为已完成
        if (_isPass) {
            _receivePass(_index, _taskerIndex, _fileIndex);
            delete isNoTransferState[_taskerIndex];
            // delete isNoTransferState[_taskerIndex];
        } else {
            //任务不通过，将任务者的状态修改为被打回状态
            _returnTaskerByBuyer(_index, _taskerIndex, _fileIndex);
        }
    }

    function _receivePass(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex
    ) internal {
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
    }

    //超时未提交-翻译者
    function _overTimeTrans(uint256 _index, address _taskerIndex)
        internal
        returns (uint256)
    {
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted, _money) = service.overTimeTasker(
            _index,
            _taskerIndex,
            true
        );
        if (_unCompleted.length == 0) {
            return 0;
        }
        // service.changeTaskTransState(_index,_taskerIndex,)
        //修改任务状态
        _updateTaskerStateByTrans(
            _index,
            _taskerIndex,
            _unCompleted,
            LibProject.TaskerState.Overtime
        );
        uint256 _allBounty;
        if (service.isCustomizeState(_index)) {
            for (uint256 i = 0; i < _unCompleted.length; i++) {
                _allBounty += service.getFileBounty(_index, _unCompleted[i]);
            }
        } else {
            _allBounty = service.getTaskBounty(_index);
        }
        //计算罚金
        //   uint256 _rate=  CalculateUtils.punishRatio(service.getTranslators(_index,_taskerIndex).bounty);
        uint256 _rate = utils.punishRatio(utils.getTaskTrans(_allBounty));
        uint256 _punish = utils.getPunish(_money, _rate);
        delete isNoTransferState[_taskerIndex];
        //返回罚金
        return _punish;
    }

    //批量修改
    function _updateTaskerStateByTrans(
        uint256 _index,
        address _taskerAddress,
        uint256[] memory _fileIndex,
        LibProject.TaskerState _state
    ) internal {
        for (uint256 i = 0; i < _fileIndex.length; i++) {
            service.changeTaskTransState(
                _index,
                _taskerAddress,
                _fileIndex[i],
                _state
            );
        }
    }

    function _updateTaskerStateByVf(
        uint256 _index,
        address _taskerAddress,
        uint256[] memory _fileIndex,
        LibProject.TaskerState _state
    ) internal {
        for (uint256 i = 0; i < _fileIndex.length; i++) {
            service.changeTaskVfState(
                _index,
                _taskerAddress,
                _fileIndex[i],
                _state
            );
        }
    }

    //超时未提交-校验者
    function _overTimeVf(uint256 _index, address _taskerIndex)
        internal
        returns (uint256)
    {
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted, _money) = service.overTimeTasker(
            _index,
            _taskerIndex,
            false
        );
        if (_unCompleted.length == 0) {
            return 0;
        }
        _updateTaskerStateByVf(
            _index,
            _taskerIndex,
            _unCompleted,
            LibProject.TaskerState.Overtime
        );
        //计算罚金
        uint256 _allBounty;
        if (service.isCustomizeState(_index)) {
            for (uint256 i = 0; i < _unCompleted.length; i++) {
                _allBounty += service.getFileBounty(_index, _unCompleted[i]);
            }
        } else {
            _allBounty = service.getTaskBounty(_index);
        }
        //1.根据赏金获得处罚比率
        uint256 _rate = utils.punishRatio(utils.getTaskVf(_allBounty));
        uint256 _punish = utils.getPunish(_money, _rate);
        delete isNoTransferState[_taskerIndex];
        return _punish;
    }

    function _isHasNftPass(address _address) internal view returns (bool) {
        uint256[] memory _list = amphi.walletOfOwner(_address);
        if (_list.length > 0) {
            return true;
        }
        return false;
    }

    function _postTask(LibProject.ProParm memory _t)
        internal
        returns (uint256)
    {
        uint256 _index = service.addProject(_t);
        emit postProjectEv(msg.sender, _index, _t);
        return _index;
    }

    //支付赏金-发布
    //function postPay(uint256 _index)
    //修改任务
    function _updateTask(uint256 _index, LibProject.ProParm memory _t)
        internal
    {
        service.updateProject(_index, _t);
        emit postProjectEv(msg.sender, _index, _t);
    }

    //到截至日期后，调用该方法,//若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
    //若有部分人接收，进入任务强分配
    function _endTransAccept(uint256 _index)
        internal
        returns (bool, string memory)
    {
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

    //
    function _endTransVf(uint256 _index)
        internal
        onlyOwner
        returns (bool, string memory)
    {
        uint256 vfNumber = service.getVfNumber(_index);
        uint256 _transNumber = service.getTransNumber(_index);
        LibProject.TaskInfo[] memory _tasks = service.getFiles(_index);
        if (service.isFull(_index, false)) {
            return (true, "");
        } else if (vfNumber == 0 && _transNumber != 0) {
            service.changeVerActive(_index, false);
            return (false, "verifiers number =0");
        } else if (vfNumber == 0 && _transNumber == 0) {
            //若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
            _onNoOnePink(_index);
            address _buyer = service.getBuyer(_index);
            uint256 _bounty = utils.getPercentage(
                service.getTaskBounty(_index),
                30
            );
            //退还金额给需求方
            toTaskerBounty(_buyer, _bounty);
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
        return (false, "Allocation completed");
    }

    function _acceptTransToFileState(uint256 _index, uint256 _fileIndex)
        internal
    {
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

    function _acceptVfToFileState(uint256 _index, uint256 _fileIndex) internal {
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

    function _onNoOnePink(uint256 _index) internal {
        service.changeProjectState(_index, LibProject.ProjectState.NoOnePick);
        service.changeVerActive(_index, false);
    }

    function _acceptTrans(
        uint256 _index,
        uint256[] memory _fileIndex,
        address _taskerIndex
    ) internal {
        //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
        if (service.getAcceptTransNumber(_index, _taskerIndex) == 0) {
            service.addTranslators(_index, _taskerIndex);
        }
        for (uint256 q = 0; q < _fileIndex.length; q++) {
            _acceptTransToFileState(_index, _fileIndex[q]);
            service.pushTaskTransIndex(_index, _taskerIndex, _fileIndex[q]);
        }
        //
        service.addTransNumber(_index);
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

    function _acceptVf(
        uint256 _index,
        uint256[] memory _fileIndex,
        address _taskerIndex
    ) internal {
        //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
        if (service.getAcceptVfNumber(_index, _taskerIndex) == 0) {
            service.addVf(_index, _taskerIndex);
        }
        for (uint256 q = 0; q < _fileIndex.length; q++) {
            _acceptVfToFileState(_index, _fileIndex[q]);
            service.pushTaskVfIndex(_index, _taskerIndex, _fileIndex[q]);
        }
        //文件状态修改为翻译中
        service.addVfNumber(_index);
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

    //校验者验收
    function _validate(
        uint256 _index,
        address _transIndex,
        uint256 _fileIndex,
        bool _isPass,
        string memory _file
    ) internal returns (uint256 _payBounty) {
        //若校验通过，将任务者的状态修改为已完成
        if (_isPass) {
            //若用户为自定义支付，则完成后支付任务者赏金
            _sumbitVfTask(_index, _transIndex, msg.sender, _fileIndex, _file);
            bool _Customize = service.isCustomizeState(_index);
            if (_Customize) {
                _payBounty = service.getFileBounty(_index, _fileIndex);
            } else {
                _payBounty = service.getTaskBounty(_index);
            }
            //校验者验收，支付翻译者30%赏金
            _payBounty = utils.getPercentage(_payBounty * 1e18, 30);
            delete isNoTransferState[_transIndex];
        } else {
            //任务不通过，将任务者的状态修改为被打回状态
            _returnTaskerByVf(_index, _transIndex, _fileIndex);
            _payBounty = 0;
        }
    }

    function _returnTaskerByVf(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex
    ) internal {
        //修改任务者状态&修改文件状态
        service.changeTaskTransState(
            _index,
            _taskerIndex,
            _fileIndex,
            LibProject.TaskerState.Return
        );
        service.changeFileState(
            _index,
            _fileIndex,
            LibProject.FileState.WaitTransModify
        );
    }

    function _returnTaskerByBuyer(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex
    ) internal {
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

    function _sumbitVfTask(
        uint256 _index,
        address _transIndex,
        address _vfIndex,
        uint256 _fileIndex,
        string memory _file
    ) internal {
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

    //提交任务-翻译者
    function _sumbitTaskTrans(
        uint256 _index,
        uint256 _fileIndex,
        string memory _file,
        address _tasker
    ) internal {
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
}
