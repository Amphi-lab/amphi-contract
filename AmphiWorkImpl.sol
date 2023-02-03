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
interface AmphiWorkOther {
    function addTask(LibProject.ProParm memory _t)
        external
        returns (uint256);
    function updateTaskByBuyer(uint256 _index, LibProject.ProParm memory _t)
        external;
    function endTransAccept(uint256 _index)
        external
        returns (bool, string memory);    
    function endTransVf(uint256 _index)
        external
        returns (bool, string memory);
    function acceptVf(
        uint256 _index,
        uint256[] memory _fileIndex,
        address _taskerIndex
    ) external;
    function acceptTrans(
        uint256 _index,
        uint256[] memory _fileIndex,
        address _taskerIndex
    ) external;
     function receiveTask(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex,
        bool _isPass
    ) external; 
    function validate(
        uint256 _index,
        address _transAddress,
        address _vfAddress,
        uint256 _fileIndex,
        bool _isPass,
        string memory _file
    ) external returns (uint256 _payBounty);
     function sumbitTaskTrans(
        uint256 _index,
        uint256 _fileIndex,
        string memory _file,
        address _tasker
    ) external;
    function overTimeTrans(uint256 _index, address _taskerIndex)
        external 
        returns (uint256,uint256);
    function overTimeVf(uint256 _index, address _taskerIndex)
        external
        returns (uint256,uint256);
    function deductPay(address _to,uint256 _value) external;
    function closeTask(uint256 _index) external;
     function getTransferState(address _address) external view returns(bool);
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
    AmphiPass amphi;
    CalculateUtils utils;
    AmphiTrans service;
    AmphiWorkOther other;
    // address otherAddress;
    // address utilsAddress;
    // address passAddress;
    mapping(address => bool) private isNoTransferState;
    uint256 constant NUMBER = 1e18;
     uint256 constant FIRST_RATE =30;
     uint256 constant END_RATE = 70;
    constructor(
        address _passAddress,
        address _utilsAddress,
        address _serviceAddress,
        address _otherAddress 
    ) {
        amphi = AmphiPass(_passAddress);
        utils = CalculateUtils(_utilsAddress);
        other = AmphiWorkOther(_otherAddress);
        service = AmphiTrans(_serviceAddress);
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
    //  AmphiWorkOther other;
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
        if (msg.value < utils.getPercentage(_t.bounty * NUMBER, FIRST_RATE)) {
            revert ErrorValue("Incorrect value", msg.value);
        }
        isNoTransferState[msg.sender] = true;
        //  other = AmphiWorkOther(otherAddress);
        _index = other.addTask(_t);
         emit postProjectEv(msg.sender, _index, _t);
         transderToContract();
    }

    function updateTask(uint256 _index, LibProject.ProParm memory _t)
        public
        payable
        isExist(_index)
        onlyBuyer(_index)
    {
        if (msg.value != utils.getPercentage(_t.bounty * NUMBER, FIRST_RATE)) {
            revert ErrorValue("Incorrect value", msg.value);
        }
        // other = AmphiWorkOther(otherAddress);
        isNoTransferState[msg.sender] = true;
        other.updateTaskByBuyer(_index, _t);
        emit postProjectEv(msg.sender, _index, _t);
        transderToContract();
    }

    //截至日期处理
    function endTransAccept(uint256 _index) public isExist(_index) onlyOwner{
        // other = AmphiWorkOther(otherAddress);
        other.endTransAccept(_index);
    }

    function endTransVf(uint256 _index) public isExist(_index) onlyOwner returns(bool,string memory){
        // other = AmphiWorkOther(otherAddress);
        // service = AmphiTrans(serviceAddress);
       (bool _bool,string memory _string) = other.endTransVf(_index);
       if(_bool == false)  {
            uint256 _bounty = utils.getPercentage(
                service.getTaskBounty(_index),
                FIRST_RATE
            );
           toTaskerBounty(service.getBuyer(_index), _bounty);
       }
       return (_bool,_string);
    }

    function acceptForTranslator(uint256 _index, uint256[] memory _fileIndex)
        public
        isHasNftPass
        isExist(_index)
        isCanAcceptTrans(_index)
        hasFine(msg.sender)
    {
        // other = AmphiWorkOther(otherAddress);
        other.acceptTrans(_index, _fileIndex, msg.sender);
        emit acceptTaskEv(_index, _fileIndex, msg.sender, true);
    }

    function acceptForVerifer(uint256 _index, uint256[] memory _fileIndex)
        public
        isHasNftPass
        isExist(_index)
        isCanAcceptVf(_index)
        hasFine(msg.sender)
    {
        // other = AmphiWorkOther(otherAddress);
        other.acceptVf(_index, _fileIndex, msg.sender);
        emit acceptTaskEv(_index, _fileIndex, msg.sender, false);
    }

    function validate(
        uint256 _index,
        address _trans,
        uint256 _fileIndex,
        bool _isPass,
        string memory _file
    ) public isExist(_index) {
        // other = AmphiWorkOther(otherAddress);
        if (service.getFileState(_index, _fileIndex) > LibProject.FileState.WaitVfModify) {
            revert OperationException("unable to submit");
        }
        uint256 _bounty = other.validate(
            _index,
            _trans,
            msg.sender,
            _fileIndex,
            _isPass,
            _file
        );
        //校验者验收，支付翻译者30%赏金
        //发赏金
        if (_bounty > 0) {
         _bounty = utils.getPercentage(_bounty * NUMBER, FIRST_RATE);
        toTaskerBounty(_trans, _bounty);
        }
    }

    function sumbitTaskTrans(
        uint256 _index,
        uint256 _fileIndex,
        string memory _file
    ) public isExist(_index) {
        if (service.getFileState(_index, _fileIndex) > LibProject.FileState.BuyerReview) {
            revert OperationException("unable to submit");
        }
        // other = AmphiWorkOther(otherAddress);
        other.sumbitTaskTrans(_index, _fileIndex, _file, msg.sender);
    }

    function overTimeTrans(uint256 _index, address _tasker)
        public
        isExist(_index)
        onlyOwner
        returns (uint256)
    {
        // other = AmphiWorkOther(otherAddress);
        (uint256 _money,uint256 _allBounty) = other.overTimeTrans(_index, _tasker);
        uint256 _rate = utils.punishRatio(utils.getTaskTrans(_allBounty));
         uint256 _punish =utils.getPunish(_money, _rate);
        service.addPay(_tasker, _punish);
        return _punish;
    }

    function overTimeVf(uint256 _index, address _tasker)
        public
        isExist(_index)
        returns (uint256)
    {
        // other = AmphiWorkOther(otherAddress);
        (uint256 _money ,uint256 _allBounty)= other.overTimeVf(_index, _tasker);
        //1.根据赏金获得处罚比率
        uint256 _rate = utils.punishRatio(utils.getTaskVf(_allBounty));
        uint256 _punish = utils.getPunish(_money, _rate);
        service.addPay(_tasker, _punish);
        return _punish;
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
        // other = AmphiWorkOther(otherAddress);
        other.receiveTask(_index, _taskerIndex, _fileIndex, _isPass);
        //若验收通过，将合约剩余的70%的钱存入合约中
        if (_isPass) {
            uint256 _payMoney = utils.getPercentage(_bounty * NUMBER, END_RATE);
            if (msg.value < _payMoney) {
                revert ErrorValue("error : Incorrect value", msg.value);
            }
            transderToContract();
            uint256 _vfBounty = utils.getTaskVf(_bounty * NUMBER);
            uint256 _transBounty = utils.getTaskTransEnd(_bounty * NUMBER);
            toTaskerBounty(_taskerIndex, _vfBounty);
            toTaskerBounty(_transAddress, _transBounty);
            delete isNoTransferState[msg.sender];
        }
        
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
        // other = AmphiWorkOther(otherAddress);
        other.deductPay(_to, msg.value);
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
    function updateOther(address _newAddress) public onlyOwner {
       other = AmphiWorkOther(_newAddress);
    }
    function closeTask(uint256 _index) public onlyOwner{
        // other = AmphiWorkOther(otherAddress);
        other.closeTask(_index);
    }

    // function closeFileState(uint256 _index, uint256 _fileIndex) public {
    //     service.changeFileState(
    //         _index,
    //         _fileIndex,
    //         LibProject.FileState.Closed
    //     );
    // }

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
        // other = AmphiWorkOther(otherAddress);
        return other.getTransferState(_address);
    }


    function _isHasNftPass(address _address) internal view returns (bool) {
        uint256[] memory _list = amphi.walletOfOwner(_address);
        if (_list.length > 0) {
            return true;
        }
        return false;
    }
 
    //提交任务-翻译者
    
}
