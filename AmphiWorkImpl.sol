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
    function addTask(LibProject.ProParm memory _t,address _address)
        external
        returns (uint256);
    function updateTaskByBuyer(uint256 _index, LibProject.ProParm memory _t,address _address)
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
        bool _isPass,
        address _address,
        string memory _file,
        string memory _illustrate
    ) external; 
    function validate(
        uint256 _index,
        address _transAddress,
        address _vfAddress,
        uint256 _fileIndex,
        bool _isPass,
        string memory _file, 
        string memory _illustrate
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
    function sumbitVf(
        uint256 _index,
        uint256 _fileIndex,
        string memory _file,
        address _tasker
    ) external;
    function deductPay(address _to,uint256 _value) external;
    function closeTask(uint256 _index) external;
     function getTransferState(address _address) external view returns(bool);
     function addPay(address _to,uint256 _value) external;
     function closeFileState(uint256 _index,uint256 _fileIndex,address _address) external;
}
contract AmphiWorkImpl is Ownable {
    AmphiPass amphi;
    CalculateUtils utils;
    AmphiTrans service;
    AmphiWorkOther other;
    TransferService transferService;
    // address otherAddress;
    // address utilsAddress;
    // address passAddress;
    mapping(address => bool) private isNoTransferState;
    // uint256 constant NUMBER = 1e18;
     uint256 constant FIRST_RATE =30;
     uint256 constant END_RATE = 70;
     bool private locked;
     address payable private transferAddress;
    constructor (
        address _passAddress,
        address _utilsAddress,
        address _serviceAddress,
        address _otherAddress,
        address payable _transferAddress
    )  {
        amphi = AmphiPass(_passAddress);
        utils = CalculateUtils(_utilsAddress);
        other = AmphiWorkOther(_otherAddress);
        service = AmphiTrans(_serviceAddress);
        transferAddress = _transferAddress;
        //transferService = TransferService(transferAddress);
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
        // isHasNftPass
        hasFine(msg.sender)
        returns (uint256 _index)
    {
        if (msg.value < utils.getPercentage(_t.bounty, FIRST_RATE)) {
            revert ErrorValue("Incorrect value", msg.value);
        }
        isNoTransferState[msg.sender] = true;
        //  other = AmphiWorkOther(otherAddress);
        _index = other.addTask(_t,msg.sender);
        (bool callSuccess, ) =payable(transferAddress).call{value:msg.value}("transderToContract");
        //  require(callSuccess, "transderToContract failed");
         if(!callSuccess){
             revert OperationException("transderToContract failed");
         }
        //  transferService.transderToContract();
    }

    function updateTask(uint256 _index, LibProject.ProParm memory _t)
        public
        payable
        isExist(_index)
        onlyBuyer(_index)
    {
        if (msg.value != utils.getPercentage(_t.bounty, FIRST_RATE)) {
            revert ErrorValue("Incorrect value", msg.value);
        }
        // other = AmphiWorkOther(otherAddress);
        isNoTransferState[msg.sender] = true;
        other.updateTaskByBuyer(_index, _t,msg.sender);
        (bool callSuccess, ) =payable(transferAddress).call{value:msg.value}("transderToContract");
        //  require(callSuccess, "transderToContract failed");
         if(!callSuccess){
             revert OperationException("transderToContract failed");
         }
        // transferService.transderToContract();
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
          transferService= TransferService(transferAddress);
           transferService.toTaskerBounty(service.getBuyer(_index), _bounty);
       }
       return (_bool,_string);
    }

    function acceptForTranslator(uint256 _index, uint256[] memory _fileIndex)
        public
        // isHasNftPass
        isExist(_index)
        isCanAcceptTrans(_index)
        hasFine(msg.sender)
    {
        // other = AmphiWorkOther(otherAddress);
        other.acceptTrans(_index, _fileIndex, msg.sender);
        // emit acceptTaskEv(_index, _fileIndex, msg.sender, true);
    }

    function acceptForVerifer(uint256 _index, uint256[] memory _fileIndex)
        public
        // isHasNftPass
        isExist(_index)
        isCanAcceptVf(_index)
        hasFine(msg.sender)
    {
        // other = AmphiWorkOther(otherAddress);
        other.acceptVf(_index, _fileIndex, msg.sender);
        // emit acceptTaskEv(_index, _fileIndex, msg.sender, false);
    }

    function validate(
        uint256 _index,
        address _trans,
        uint256 _fileIndex,
        bool _isPass,
        string memory _file,
        string memory _illustrate
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
            _file,
            _illustrate
        );
        //校验者验收，支付翻译者30%赏金
        //发赏金
        if (_bounty > 0) {
         _bounty = utils.getPercentage(_bounty, FIRST_RATE);
         transferService= TransferService(transferAddress);
        transferService.toTaskerBounty(_trans, _bounty);
        }
    }

    function sumbitTaskTrans(
        uint256 _index,
        uint256 _fileIndex,
        string memory _file
    ) public isExist(_index) {
        if (service.getFileState(_index, _fileIndex) >= LibProject.FileState.BuyerReview) {
            revert OperationException("unable to submit");
        }
        // other = AmphiWorkOther(otherAddress);
        other.sumbitTaskTrans(_index, _fileIndex, _file, msg.sender);
    }
    function sumbitVf(uint256 _index, uint256 _fileIndex,
        string memory _file) public isExist(_index) {
            if (service.getFileState(_index, _fileIndex) > LibProject.FileState.WaitVfModify) {
            revert OperationException("unable to submit");
        }
        other.sumbitVf(_index,_fileIndex,_file,msg.sender);
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
        other.addPay(_tasker, _punish);
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
        other.addPay(_tasker, _punish);
        return _punish;
    }

    function receiveTask(
        uint256 _index,
        address _taskerIndex,
        uint256 _fileIndex,
        bool _isPass,
        address _transAddress,
        string memory _file,
        string memory _illustrate
    ) public payable isExist(_index) onlyBuyer(_index) {
        uint256 _bounty;
        if (service.isCustomizeState(_index)) {
            _bounty = service.getFileBounty(_index, _fileIndex);
        } else {
            _bounty = service.getTaskBounty(_index);
        }
        // other = AmphiWorkOther(otherAddress);
        other.receiveTask(_index, _taskerIndex, _fileIndex, _isPass,msg.sender,_file,_illustrate);
        //若验收通过，将合约剩余的70%的钱存入合约中
        if (_isPass) {
            uint256 _payMoney = utils.getPercentage(_bounty, END_RATE);
            if (msg.value < _payMoney) {
                revert ErrorValue("error : Incorrect value", msg.value);
            }
             (bool callSuccess, ) =payable(transferAddress).call{value:msg.value}("transderToContract");
             if(!callSuccess){
             revert OperationException("transderToContract failed");
         }
            // transferService.transderToContract();
            uint256 _vfBounty = utils.getTaskVf(_bounty );
            uint256 _transBounty = utils.getTaskTransEnd(_bounty);
            transferService= TransferService(transferAddress);
            transferService.toTaskerBounty(_taskerIndex, _vfBounty);
            transferService.toTaskerBounty(_transAddress, _transBounty);
            delete isNoTransferState[msg.sender];
        }
        
    }
    // function withdraw(uint256 _money) public onlyOwner {
    //     transferService._withdraw(_money);
    // }

    // function withdrawAll() public onlyOwner {
    //     _withdrawAll();
    // }

    //支付罚金
    function payFine(address _to) public payable {
        if (locked){
            revert Permissions("The lock is locked.");
        }
        if (msg.value != service.getPay(_to) * 1e18) {
            revert ErrorValue("value is high", msg.value);
        }
        locked = true;
        // other = AmphiWorkOther(otherAddress);
        other.deductPay(_to, service.getPay(_to));
        (bool callSuccess, ) = payable(_to).call{value: msg.value}("");
        require(callSuccess, "Call failed");
        locked = false;
        // transferService.pay(_to, msg.value);
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
    function newTransferAddress(address payable _address) public onlyOwner {
        transferAddress = _address;
    }
    function closeTask(uint256 _index) public onlyOwner{
        // other = AmphiWorkOther(otherAddress);
        other.closeTask(_index);
    }

    function closeFileState(uint256 _index, uint256 _fileIndex) public {
        other.closeFileState(_index,_fileIndex,msg.sender);
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
        // other = AmphiWorkOther(otherAddress);
        return other.getTransferState(_address);
    }
    function isAccepted(address _address,uint256[] memory _info) public view returns(bool) {
       return service.isAccept(_address, _info[0], _info[1]);
    }

    function _isHasNftPass(address _address) internal view returns (bool) {
        // uint256[] memory _list = amphi.walletOfOwner(_address);
        if (amphi.walletOfOwner(_address).length > 0) {
            return true;
        }
        return false;
    }
 
    //提交任务-翻译者
    
}
