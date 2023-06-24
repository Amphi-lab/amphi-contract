// SPDX-License-Identifier: MIT;
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../interfaces/IERC20.sol";
import "./LibProject.sol";
import "./AmphiTrans.sol";
import "./FundsContract.sol";

interface IAmphiPass {
    function walletOfOwner(
        address _owner
    ) external view returns (uint256[] memory);
}

contract CalculateUtils {
    uint256 constant RATE = 100;

    //获得罚金比率
    function punishRatio(uint256 _bounts) public pure returns (uint256) {
        uint256 ratio;
        if (_bounts < RATE) {
            ratio = 1;
        } else if (_bounts >= RATE && _bounts < RATE * 1e1) {
            ratio = 1e1;
        } else if (_bounts >= RATE * 1e1 && _bounts < RATE * 1e2) {
            ratio = 1e2;
        } else if (_bounts >= RATE * 1e2 && _bounts < RATE * 1e3) {
            ratio = 1e3;
        } else if (_bounts >= RATE * 1e3 && _bounts <= RATE * 1e4) {
            ratio = 1e4;
        } else if (_bounts >= RATE * 1e4 && _bounts <= RATE * 1e5) {
            ratio = 1e5;
        } else {
            ratio = 0;
        }
        return ratio;
    }

    //计算任务赏金
    function getPercentage(
        uint256 _number,
        uint256 _ratio
    ) internal pure returns (uint256 returnNumber) {
        returnNumber = (_number * _ratio) / 100;
    }

    //计算罚金
    function getPunish(
        uint256 _ratio,
        uint256 _bounty
    ) internal pure returns (uint256) {
        return _bounty / _ratio;
    }

    //计算扣除的赏金
    function getDeductMoney(
        uint256 _bounty,
        uint256 _deduct
    ) internal pure returns (uint256) {
        return getPercentage(_bounty, _deduct);
    }
}

contract NewImpl is CalculateUtils, Ownable {
    IAmphiPass private amphi;
    AmphiTrans private service;
    IERC20 private erc;
    FundsContract funds;
    mapping(address => bool) private isAmphi;
    uint256 constant PO_RATE = 90;
    address private fundsAddress;
    // mapping(address => bool) private isNoTransferState;
    mapping(uint256 => LibProject.ReturnRecord) returnRecordList;

    constructor(
        address _passAddress,
        address _serviceAddress,
        address _ercAddress,
        address _fundsAddress
    ) {
        amphi = IAmphiPass(_passAddress);
        service = AmphiTrans(_serviceAddress);
        erc = IERC20(_ercAddress);
        fundsAddress = _fundsAddress;
    }

    event returnFileEv(uint256 index, string returnFile, string illustrate);
    event postProjectEv(address buyer, uint256 taskIndex);
    //任务索引值，文件索引值，文件状态，操作者
    event changeTaskStateEv(
        uint256 taskIndex,
        LibProject.TaskState taskSate,
        address opSender
    );
    //任务索引值、任务者地址、文件索引值，任务者状态，,操作者
    event changeTaskerStateEv(
        uint256 taskIndex,
        LibProject.TaskerState taskerState,
        address opSender
    );
    event submitFileEv(
        uint256 index,
        uint256 uploadtime,
        string[] file,
        address sender
    );
    event addPayEv(address tasker, uint256 money);
    event decutPayEv(address tasker, uint256 money);
    event newSubmitFile(uint256 _index, bool _isTrans);
    modifier isExist(uint256 _index) {
        require(_index <= service.getCount(), "Wrong index value!");
        _;
    }
    modifier isHasNftModifer() {
        require(isHasNftPass(msg.sender), "Not Have Pass NFT!");
        _;
    }

    //  AmphiWorkOther other;
    //发布任务-改成质押100%
    //文件状态修改：翻译等待，校验等待
    function postTask(
        LibProject.TranslationPro memory _t
    ) external returns (uint256 _index) {
        //判断用户是否存在未支付罚金
        require(service.getPay(msg.sender) == 0, "unpaid penalty!");
        //判断用户是否有足够的金额支付赏金
        require(
            erc.balanceOf(msg.sender) >= (_t.bounty),
            "not hava enought approve"
        );
        //截至时间不能低于发布时间
        require(
            _t.releaseTime < _t.deadline,
            "The releaseTime is greater than the deadline"
        );
        // 新增
        _index = _addTask(_t);
        //将赏金质押给平台中
        require(erc.transfer(msg.sender, _t.bounty), "Transfer failed");
        emit postProjectEv(msg.sender, _index);
        return _index;
    }

    //服务者提交文件
    function sumbitTask(
        uint256 _index,
        string[] memory _files
    ) public isExist(_index) isHasNftModifer {
        //调用者是否为服务者
        require(service.isTasker(_index, msg.sender), "sender not tasker");
        LibProject.TaskState _taskState = service.getTaskState(_index);
        require(
            _taskState == LibProject.TaskState.Translating ||
                _taskState == LibProject.TaskState.WaitTaskerModify,
            "this tasker state cannot submit"
        );
        _sumbitTaskTrans(_index, _files, msg.sender);
    }

    function overTime(
        uint256 _index,
        address _tasker
    ) public isExist(_index) returns (uint256) {
        require(isAmphi[msg.sender], "only amphi team can call the method");
        uint256 _money = _overTime(_index);
        uint256 _rate = punishRatio(getPercentage(_money, PO_RATE));
        uint256 _punish = getPunish(_money, _rate);
        addPay(_tasker, _punish);
        return _punish;
    }

    function receiveTask(
        uint256 _index,
        bool _isPass,
        string memory _file,
        string memory _illustrate
    ) public isExist(_index) {
        require(
            service.getBuyer(_index) == msg.sender || isAmphi[msg.sender],
            "only amphi team or buyer can call the method"
        );
        uint256 _passBounty;
        uint256 _bounty;
        _bounty = service.getTaskBounty(_index);
        _receiveTask(_index, _isPass, _file, _illustrate, msg.sender);
        //验收通过
        if (_isPass && _bounty > 0) {
            //获得赏金比例
            _passBounty = getPercentage(_bounty, PO_RATE);
            require(
                erc.balanceOf(fundsAddress) >= _passBounty,
                "funds contract not hava enought balance"
            );
            funds = FundsContract(fundsAddress);
            funds.transferToAddress(service.getTasker(_index), _passBounty);
        }
    }

    //添加任务
    function _addTask(
        LibProject.TranslationPro memory _t
    ) public returns (uint256) {
        uint256 _index = service.addProject(_t);
        return _index;
    }

    //翻译者提交任务
    function _sumbitTaskTrans(
        uint256 _index,
        string[] memory _files,
        address _operAddress
    ) internal {
        if (
            service.getTaskState(_index) ==
            LibProject.TaskState.WaitTaskerModify
        ) {
            emit newSubmitFile(_index, true);
        }
        service.changeProjectState(_index, LibProject.TaskState.BuyerReview);
        emit changeTaskStateEv(
            _index,
            LibProject.TaskState.BuyerReview,
            _operAddress
        );
        uint256 _time = service.submitFileByTasker(_index, _files);
        emit submitFileEv(_index, _time, _files, _operAddress);
        service.changeTaskerState(_index, LibProject.TaskerState.Submitted);
        emit changeTaskerStateEv(
            _index,
            LibProject.TaskerState.Submitted,
            _operAddress
        );
    }

    //超时未提交
    function _overTime(uint256 _index) internal returns (uint256) {
        uint256 _money = service.getTaskBounty(_index);
        //修改任务状态
        service.changeTaskerState(_index, LibProject.TaskerState.Overtime);
        emit changeTaskerStateEv(
            _index,
            LibProject.TaskerState.Overtime,
            msg.sender
        );
        //移除不可转移nft名单
        service.deleteNoTransferAddress(service.getTasker(_index));
        // delete isNoTransferState[_taskerIndex];
        //返回罚金
        return _money;
    }

    //发布者验收
    function _receiveTask(
        uint256 _index,
        bool _isPass,
        string memory _file,
        string memory _illustrate,
        address _operAddress
    ) public {
        // service = AmphiTrans(serviceAddess);
        address buyer = service.getBuyer(_index);
        //若校验通过，将任务者的状态修改为已完成
        if (_isPass) {
            service.changeTaskerState(_index, LibProject.TaskerState.Completed);
            emit changeTaskerStateEv(
                _index,
                LibProject.TaskerState.Completed,
                buyer
            );
            service.changeProjectState(_index, LibProject.TaskState.Completed);
            emit changeTaskStateEv(
                _index,
                LibProject.TaskState.Completed,
                _operAddress
            );
            //移除不可转移nft名单
            service.deleteNoTransferAddress(service.getTasker(_index));
            service.deleteNoTransferAddress(service.getBuyer(_index));
        } else {
            //任务不通过，将任务者的状态修改为被打回状态
            service.changeTaskerState(_index, LibProject.TaskerState.Return);
            emit changeTaskerStateEv(
                _index,
                LibProject.TaskerState.Return,
                buyer
            );
            service.changeProjectState(
                _index,
                LibProject.TaskState.WaitTaskerModify
            );
            emit changeTaskStateEv(
                _index,
                LibProject.TaskState.WaitTaskerModify,
                _operAddress
            );
            returnRecordList[_index] = LibProject.ReturnRecord(
                service.getTasker(_index),
                _file,
                _illustrate
            );
            emit returnFileEv(_index, _file, _illustrate);
        }
    }

    function deductPay(address _to, uint256 _value) external {
        service.deductPay(_to, _value);
        emit decutPayEv(_to, _value);
    }

    function addPay(address _to, uint256 _value) internal {
        service.addPay(_to, _value);
        emit addPayEv(_to, _value);
    }

    function closeTask(uint256 _index) public {
        require(
            service.getBuyer(_index) == msg.sender || isAmphi[msg.sender],
            "only amphi team or buyer can call the method"
        );
        service.changeProjectState(_index, LibProject.TaskState.Closed);
        emit changeTaskStateEv(_index, LibProject.TaskState.Closed, msg.sender);
    }

    function isHasNftPass(address _address) public view returns (bool) {
        // uint256[] memory _list = amphi.walletOfOwner(_address);
        if (amphi.walletOfOwner(_address).length > 0) {
            return true;
        }
        return false;
    }
}
