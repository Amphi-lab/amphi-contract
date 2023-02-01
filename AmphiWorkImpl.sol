// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./AmphiTranImpl.sol";
import "./LibProject.sol";
import "./CalculateUtils.sol";
import "./TransferService.sol";
error OperationException(string);
error ErrorValue(string, uint256);
error Permissions(string);
// error FileException(string, LibProject.FileState);

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
    AmphiTranImpl service;
    CalculateUtils utils;
    mapping(address => bool) private isNoTransferState;
    uint256 constant  NUMBER = 1e18;
    uint256 constant POST_PAY_RATE = 30;
    uint256 constant END_PAY_RATE = 70;
    constructor(
        address _passAddress,
        address _serviceAddress,
        address _utilsAddress
    ) {
        amphi = AmphiPass(_passAddress);
        service = AmphiTranImpl(_serviceAddress);
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
            revert ParameterException("Wrong index!");
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
        uint256 _bounty = utils.getPercentage(_t.bounty * NUMBER, POST_PAY_RATE);
        if (msg.value < _bounty) {
            revert ErrorValue("Incorrect value", msg.value);
        }
        isNoTransferState[msg.sender] = true;
        transderToContract();
    }

    function updateTask(uint256 _index, LibProject.ProParm memory _t)
        public
        payable
        onlyBuyer(_index)
    {
        _updateTask(_index, _t);
        uint256 _bounty = utils.getPercentage(_t.bounty, POST_PAY_RATE);
        if (msg.value != _bounty * NUMBER) {
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
        service.acceptTrans(_index, _fileIndex, msg.sender);
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
        service.acceptVf(_index, _fileIndex, msg.sender);
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
        service.sumbitTaskTrans(_index, _fileIndex, _file, msg.sender);
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
            uint256 _payMoney = utils.getPercentage(_bounty * NUMBER, END_PAY_RATE);
            if (msg.value < _payMoney) {
                revert ErrorValue("error : Incorrect value", msg.value);
            }
            transderToContract();
            uint256 _vfBounty = utils.getTaskVf(_bounty * NUMBER);
            uint256 _transBounty = utils.getTaskTransEnd(_bounty * NUMBER);
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
        if (msg.value > service.getPay(_to) * NUMBER) {
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

    function newAmphiTransImpl(address _newAddress) public onlyOwner {
        service = AmphiTranImpl(_newAddress);
    }

    function closeTask(uint256 _index) public {
        service.closeTask(_index);
    }

    function closeFileState(uint256 _index, uint256 _fileIndex) public {
        service.closeFileState(
            _index,
            _fileIndex
        );
    }

    function getTaskInfo(uint256 _index)
        public
        view
        isExist(_index)
        returns (LibProject.TranslationPro memory)
    {
      return  service.getProjectOne(_index);
    //     LibProject.ReturnTask memory _info;
    //     _info.pro = service.getProjectOne(_index);
    //    // uint256 transLen = service.getTransNumber(_index);
    //   //  uint256 vfLen = service.getVfNumber(_index);
    //     address[] memory transList = service.getTranslatorsList(_index);
    //     address[] memory vfList = service.getVfList(_index);
    //     LibProject.ReturnTasker[]
    //         memory _transInfo = new LibProject.ReturnTasker[](service.getTransNumber(_index));
    //     LibProject.ReturnTasker[]
    //         memory _vfInfo = new LibProject.ReturnTasker[](service.getVfNumber(_index));
    //     for (uint256 i = 0; i < service.getTransNumber(_index); i++) {
    //         _transInfo[i] = service.getTransTaskInfo(_index, transList[i]);
    //     }
    //     for (uint256 i = 0; i < service.getVfNumber(_index); i++) {
    //         _vfInfo[i] = service.getVfTaskInfo(_index, vfList[i]);
    //     }
    //     _info.transInfo = _transInfo;
    //     _info.vfInfo = _vfInfo;
        //return _info;
        // return service.getProjectOne(_index);
    }
    // function getTransInfo(uint256 _index) public view{
        // address[] memory transList = service.getTranslatorsList(_index);
        // address[] memory vfList = service.getVfList(_index);
        // LibProject.ReturnTasker[]
        //     memory _transInfo = new LibProject.ReturnTasker[](service.getTransNumber(_index));
        // LibProject.ReturnTasker[]
        //     memory _vfInfo = new LibProject.ReturnTasker[](service.getVfNumber(_index));
        // for (uint256 i = 0; i < service.getTransNumber(_index); i++) {
        //     _transInfo[i] = service.getTransTaskInfo(_index, transList[i]);
        // }
        // for (uint256 i = 0; i < service.getVfNumber(_index); i++) {
        //     _vfInfo[i] = service.getVfTaskInfo(_index, vfList[i]);
        // }
    // }

    // function getFileState(uint256 _index, uint256 _fileIndex)
    //     public
    //     view
    //     returns (LibProject.FileState)
    // {
    //     return service.getFileState(_index, _fileIndex);
    // }

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
            service.receivePass(_index, _taskerIndex, _fileIndex);
            delete isNoTransferState[_taskerIndex];
            // delete isNoTransferState[_taskerIndex];
        } else {
            //任务不通过，将任务者的状态修改为被打回状态
            service.returnTaskerByBuyer(_index, _taskerIndex, _fileIndex);
        }
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
         uint256 _allBounty = service.overTimeTrans(_index,_taskerIndex,_unCompleted);
        //计算罚金
        //   uint256 _rate=  CalculateUtils.punishRatio(service.getTranslators(_index,_taskerIndex).bounty);
        delete isNoTransferState[_taskerIndex];
        //返回罚金
        return utils.getPunish(_money, utils.punishRatio(utils.getTaskTrans(_allBounty)));
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
       
        //计算罚金
        uint256 _allBounty= service.overTimeVf(_index,_taskerIndex,_unCompleted);
        //1.根据赏金获得处罚比率

        delete isNoTransferState[_taskerIndex];
        return utils.getPunish(_money, utils.punishRatio(utils.getTaskVf(_allBounty)));
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

    // //到截至日期后，调用该方法,//若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
    // //若有部分人接收，进入任务强分配
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
            service.distrToTrans(_index,_tasks,_transNumber);
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
           // service.changeVerActive(_index, false);
            return (false, "verifiers number =0");
        } else if (vfNumber == 0 && _transNumber == 0) {
            //若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
            service.onNoOnePink(_index);
            //退还金额给需求方
            toTaskerBounty(service.getBuyer(_index), utils.getPercentage(
                service.getTaskBounty(_index),
                POST_PAY_RATE
            ));
            return (false, "no one pink");
        } else {
           service.distrToVf(_index,_tasks,vfNumber);
             return (false, "Allocation completed");
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
            service.sumbitVfTask(_index, _transIndex, msg.sender, _fileIndex, _file);
            if (service.isCustomizeState(_index)) {
                _payBounty = service.getFileBounty(_index, _fileIndex);
            } else {
                _payBounty = service.getTaskBounty(_index);
            }
            //校验者验收，支付翻译者30%赏金
            _payBounty = utils.getPercentage(_payBounty * NUMBER, POST_PAY_RATE);
            delete isNoTransferState[_transIndex];
        } else {
            //任务不通过，将任务者的状态修改为被打回状态
            service.returnTaskerByVf(_index, _transIndex, _fileIndex);
            _payBounty = 0;
        }
    }
}
