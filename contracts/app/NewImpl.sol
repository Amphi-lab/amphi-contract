// SPDX-License-Identifier: MIT;
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LibProject.sol";
import "./AmphiTrans.sol";

interface IAmphiPass {
    function walletOfOwner(
        address _owner
    ) external view returns (uint256[] memory);
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract CalculateUtils {
    uint256 constant RATE = 100;
    uint256 constant VF_N = 3;

    // uint256 private TransRate ;
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

    function getMatNumber(
        uint256 _transNumber
    ) external pure returns (uint256) {
        uint256 _maxV;
        if (_transNumber <= VF_N) {
            _maxV = 1;
        } else {
            _maxV = _transNumber / VF_N;
        }
        return _maxV;
    }

    //计算任务赏金-翻译者
    function getBountyForTrans(
        uint256 _bounty
    ) public pure returns (uint256 _money) {
        _money = getPercentage(_bounty, 60);
    }

    function getBountyForVf(
        uint256 _bounty
    ) external pure returns (uint256 _money) {
        _money = getPercentage(_bounty, 40);
    }

    function getBountyForAmphi(
        uint256 _bounty
    ) external pure returns (uint256 _money) {
        _money = getPercentage(_bounty, 10);
    }

    //计算任务赏金
    function getPercentage(
        uint256 _number,
        uint256 _ratio
    ) public pure returns (uint256 returnNumber) {
        returnNumber = (_number * _ratio) / 100;
    }

    //计算罚金
    function getPunish(
        uint256 _ratio,
        uint256 _bounty
    ) public pure returns (uint256) {
        return _bounty / _ratio;
    }

    //计算扣除的赏金
    function getDeductMoney(
        uint256 _bounty,
        uint256 _deduct
    ) public pure returns (uint256) {
        return getPercentage(_bounty, _deduct);
    }
}

//新合约
// 1.合约接单完成后提交到链上
// 2.发单人去掉nft限制
// 3.发单时不再分小任务，只需要一个翻译者一个校验者接单
contract NewImpl is CalculateUtils, Ownable {
    IAmphiPass private amphi;
    CalculateUtils private utils;
    AmphiTrans private service;
    //IAmphiWorkOther private  other;
    IERC20 private erc;
    mapping(address => bool) private isAmphi;
    uint256 constant PO_RATE = 70;
    uint256 constant PO_RATE_TWO = 110;
    address private amphiFee;
    mapping(address => bool) private isNoTransferState;
    mapping(uint256 => LibProject.ReturnRecord) returnRecordList;

    constructor(
        address _passAddress,
        address _utilsAddress,
        address _serviceAddress,
        address _ercAddress
    ) {
        amphi = IAmphiPass(_passAddress);
        utils = CalculateUtils(_utilsAddress);
        service = AmphiTrans(_serviceAddress);
        erc = IERC20(_ercAddress);
        amphiFee = owner();
    }

    event returnFileEv(
        uint256 index,
        address to,
        string returnFile,
        string illustrate
    );
    event acceptTaskEv(
        uint256 taskIndex,
        uint256 fileIndex,
        address taskerAddress,
        bool isTrans
    );
    event postProjectEv(address buyer, uint256 taskIndex);
    event acceptTaskEv(
        uint256 taskIndex,
        uint256[] fileIndex,
        address taskerAddress,
        bool isTrans
    );
    //任务索引值，文件索引值，文件状态，操作者
    event changeFileStateEv(
        uint256 taskIndex,
        LibProject.FileState fileSate,
        address opSender
    );
    //任务索引值，文件状态，操作者
    // event changeProjectStateEv(
    //     uint256 taskIndex,
    //     LibProject.TaskerState taskState,
    //     address opSender
    // );
    //任务索引值、任务者地址、文件索引值，任务者状态，是否为翻译者,操作者
    event changeTaskerStateEv(
        uint256 taskIndex,
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
        uint256 uploadtime,
        string[] file,
        address sender,
        bool isTrans
    );
    event addPayEv(address tasker, uint256 money);
    event decutPayEv(address tasker, uint256 money);
    event newSubmitFile(uint256 _index, bool _isTrans);
    modifier onlyAmphi(address _amphiAddress) {
        require(isAmphi[_amphiAddress], "only amphi team can call the method");
        _;
    }
    modifier onlyBuyer(uint256 _index) {
        require(service.getBuyer(_index) == msg.sender, "Only buyer");
        _;
    }
    modifier isExist(uint256 _index) {
        require(_index <= service.getCount(), "Wrong index value!");
        _;
    }
    modifier hasFine(address _address) {
        require(service.getPay(_address) == 0, "unpaid penalty!");
        _;
    }
    modifier isHasNftPass() {
        require(_isHasNftPass(msg.sender), "Not Have Pass NFT!");
        _;
    }

    //  AmphiWorkOther other;
    //发布任务-改成质押100%
    //文件状态修改：翻译等待，校验等待
    function postTask(
        LibProject.TranslationPro memory _t
    ) public hasFine(msg.sender) returns (uint256 _index) {
        //判断用户是否有授权额度
        require(
            erc.allowance(msg.sender, address(this)) >=
                getPercentage(_t.bounty, PO_RATE_TWO),
            "not hava enought approve"
        );
        //截至时间不能低于发布时间
        require(
            _t.releaseTime < _t.deadline,
            "The releaseTime is greater than the deadline"
        );
        // 新增
        _index = _addTask(_t);
        emit postProjectEv(msg.sender, _index);
        return _index;
    }

    //翻译者提交文件
    function sumbitTaskTrans(
        uint256 _index,
        string[] memory _files
    ) public isExist(_index) {
        LibProject.FileState _taskState = service.getTaskState(_index);
        require(
            _taskState == LibProject.FileState.WaitingForVf ||
                _taskState == LibProject.FileState.Translating ||
                _taskState == LibProject.FileState.WaitTransModify,
            "this file state cannot submit"
        );
        //文件不能为空
        // require(keccak256(abi.encode(_file)) != keccak256(abi.encode("")),"file cannot null");
        //是否为校验者
        require(
            service.isTranslator(_index, msg.sender),
            "sender not translator"
        );
        _sumbitTaskTrans(_index, _files);
    }

    //校验者提交文件
    function sumbitVf(
        uint256 _index,
        string[] memory _files
    ) public isExist(_index) {
        LibProject.FileState _fileState = service.getTaskState(_index);
        require(
            _fileState == LibProject.FileState.WaitVfModify ||
                _fileState == LibProject.FileState.BuyerReview ||
                _fileState == LibProject.FileState.Validating ||
                _fileState == LibProject.FileState.WaitingForTrans,
            "this file state cannot submit"
        );
        //是否为校验者
        require(service.isVerfier(_index, msg.sender), "sender not verifiers");
        _sumbitVf(_index, _files);
    }

    function validate(
        uint256 _index,
        bool _isPass,
        string memory _file,
        string[] memory _files,
        string memory _illustrate
    ) public isExist(_index) {
        LibProject.FileState _taskState = service.getTaskState(_index);
        require(
            _taskState == LibProject.FileState.Validating ||
                _taskState == LibProject.FileState.Translating ||
                _taskState == LibProject.FileState.WaitTransModify,
            "this file state cannot validate"
        );
        //文件不能为空
        require(
            keccak256(abi.encode(_file)) != keccak256(abi.encode("")),
            "file cannot null"
        );
        //是否为校验者
        require(service.isVerfier(_index, msg.sender), "sender not verifiers");
        uint256 _bounty = _validate(
            _index,
            service.getTransloator(_index),
            msg.sender,
            _isPass,
            _file,
            _files,
            _illustrate
        );
        uint256 _passBounty = utils.getPercentage(_bounty, PO_RATE);
        address _buyer = service.getBuyer(_index);
        require(
            erc.allowance(_buyer, address(this)) >= _passBounty &&
                erc.balanceOf(_buyer) >= _passBounty,
            "buyer not hava enought approve or balance"
        );
        //校验者验收，支付翻译者60%赏金,平台10%的赏金
        //发赏金
        if (_bounty > 0) {
            erc.transferFrom(
                _buyer,
                service.getTransloator(_index),
                utils.getBountyForTrans(_bounty)
            );
            erc.transferFrom(
                _buyer,
                amphiFee,
                utils.getBountyForAmphi(_bounty)
            );
        }
    }

    function overTimeTrans(
        uint256 _index,
        address _tasker
    ) public isExist(_index) onlyAmphi(msg.sender) returns (uint256) {
        uint256 _money = _overTimeTrans(_index, _tasker);
        uint256 _rate = utils.punishRatio(utils.getBountyForTrans(_money));
        uint256 _punish = utils.getPunish(_money, _rate);
        addPay(_tasker, _punish);
        return _punish;
    }

    function overTimeVf(
        uint256 _index,
        address _tasker
    ) public isExist(_index) onlyAmphi(msg.sender) returns (uint256) {
        uint256 _money = _overTimeVf(_index, _tasker);
        //1.根据赏金获得处罚比率
        uint256 _punish = utils.getPunish(
            _money,
            utils.punishRatio(utils.getBountyForVf(_money))
        );
        addPay(_tasker, _punish);
        return _punish;
    }

    function receiveTask(
        uint256 _index,
        bool _isPass,
        string memory _file,
        string memory _illustrate
    ) public isExist(_index) onlyBuyer(_index) {
        uint256 _taskType = service.getTranslationType(_index);
        uint256 _passBounty;
        uint256 _bounty;
        _bounty = service.getTaskBounty(_index);
        _receiveTask(_index, _isPass, _file, _illustrate);
        //验收通过
        if (_isPass && _bounty > 0) {
            //任务的翻译类型为validation或interpreting
            if (_taskType == 1 || _taskType == 5) {
                _passBounty = utils.getPercentage(_bounty, PO_RATE_TWO);
            } else {
                _passBounty = utils.getBountyForVf(_bounty);
            }
            require(
                erc.allowance(msg.sender, address(this)) >= _passBounty &&
                    erc.balanceOf(msg.sender) >= _passBounty,
                "buyer not hava enought approve or balance"
            );
            // address _buyer = service.getBuyer(_index);
            if (_taskType == 1 || _taskType == 5) {
                erc.transferFrom(
                    msg.sender,
                    service.getVerfier(_index),
                    _bounty
                );
                erc.transferFrom(
                    msg.sender,
                    amphiFee,
                    utils.getBountyForAmphi(_bounty)
                );
            } else {
                erc.transferFrom(
                    msg.sender,
                    service.getVerfier(_index),
                    utils.getBountyForVf(_bounty)
                );
            }
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
    function _sumbitTaskTrans(uint256 _index, string[] memory _files) internal {
        //     service = AmphiTrans(serviceAddess);
        if (
            service.getTaskState(_index) == LibProject.FileState.WaitTransModify
        ) {
            emit newSubmitFile(_index, true);
        }
        service.changeProjectState(_index, LibProject.FileState.Validating);
        emit changeFileStateEv(
            _index,
            LibProject.FileState.Validating,
            msg.sender
        );
        uint256 _time = service.submitFileByTrans(_index, _files);
        emit submitFileEv(_index, _time, _files, msg.sender, true);
        service.changeTaskTransState(_index, LibProject.TaskerState.Submitted);
        emit changeTaskerStateEv(
            _index,
            LibProject.TaskerState.Submitted,
            true,
            msg.sender
        );
    }

    //校验者验收
    function _validate(
        uint256 _index,
        address _transAddress,
        address _vfAddress,
        bool _isPass,
        string memory _file,
        string[] memory _files,
        string memory _illustrate
    ) internal returns (uint256 _payBounty) {
        // service = AmphiTrans(serviceAddess);
        //若校验通过，将任务者的状态修改为已完成
        if (_isPass) {
            //_sumbitVfTask(_index, _transAddress, _vfAddress, _fileIndex, _file);
            service.changeTaskTransState(
                _index,
                LibProject.TaskerState.Completed
            );
            emit changeTaskerStateEv(
                _index,
                LibProject.TaskerState.Completed,
                true,
                msg.sender
            );
            _sumbitVf(_index, _files);
            return service.getTaskBounty(_index);
        } else {
            //任务不通过，将任务者的状态修改为被打回状态
            service.changeTaskTransState(_index, LibProject.TaskerState.Return);
            emit changeTaskerStateEv(
                _index,
                LibProject.TaskerState.Return,
                true,
                msg.sender
            );

            service.changeProjectState(
                _index,
                LibProject.FileState.WaitTransModify
            );
            emit changeFileStateEv(
                _index,
                LibProject.FileState.WaitTransModify,
                msg.sender
            );
            _payBounty = 0;
        }
        //记录打回记录_transAddress
        // service.addReturnRecord(_index,_transAddress,_vfAddress,_file,_illustrate);
        returnRecordList[_index] = LibProject.ReturnRecord(
            _transAddress,
            _file,
            _illustrate
        );
        emit returnFileEv(_index, _transAddress, _file, _illustrate);
    }

    function _sumbitVf(uint256 _index, string[] memory _files) internal {
        // service = AmphiTrans(serviceAddess);
        if (service.getTaskState(_index) == LibProject.FileState.WaitVfModify) {
            emit newSubmitFile(_index, false);
        }
        service.changeProjectState(_index, LibProject.FileState.BuyerReview);
        emit changeFileStateEv(
            _index,
            LibProject.FileState.BuyerReview,
            msg.sender
        );
        service.changeTaskVfState(_index, LibProject.TaskerState.Submitted);
        emit changeTaskerStateEv(
            _index,
            LibProject.TaskerState.Submitted,
            false,
            msg.sender
        );
        uint256 _time = service.submitFileByVf(_index, _files);
        emit submitFileEv(_index, _time, _files, msg.sender, false);
    }

    //超时未提交-翻译者
    function _overTimeTrans(
        uint256 _index,
        address _taskerIndex
    ) public returns (uint256) {
        // service = AmphiTrans(serviceAddess);
        uint256 _money = service.getTaskBounty(_index);
        //修改任务状态
        service.changeTaskTransState(_index, LibProject.TaskerState.Overtime);
        emit changeTaskerStateEv(
            _index,
            LibProject.TaskerState.Overtime,
            true,
            msg.sender
        );
        // uint256 _allBounty;
        // if (service.isCustomizeState(_index)) {
        //     for (uint256 i = 0; i < _unCompleted.length; i++) {
        //         _allBounty += service.getFileBounty(_index, _unCompleted[i]);
        //     }
        // } else {
        //     _allBounty = service.getTaskBounty(_index);
        // }
        delete isNoTransferState[_taskerIndex];
        //返回罚金
        return _money;
    }

    //超时未提交-校验者
    function _overTimeVf(
        uint256 _index,
        address _taskerIndex
    ) public returns (uint256) {
        // service = AmphiTrans(serviceAddess);
        //查询超时任务
        //查询超时任务数
        uint256 _money = service.getTaskBounty(_index);
        service.changeTaskVfState(_index, LibProject.TaskerState.Overtime);
        emit changeTaskerStateEv(
            _index,
            LibProject.TaskerState.Overtime,
            false,
            msg.sender
        );
        delete isNoTransferState[_taskerIndex];
        return (_money);
    }

    //发布者验收
    function _receiveTask(
        uint256 _index,
        bool _isPass,
        string memory _file,
        string memory _illustrate
    ) public {
        // service = AmphiTrans(serviceAddess);
        address buyer = service.getBuyer(_index);
        //若校验通过，将任务者的状态修改为已完成
        if (_isPass) {
            service.changeTaskVfState(_index, LibProject.TaskerState.Completed);
            emit changeTaskerStateEv(
                _index,
                LibProject.TaskerState.Completed,
                false,
                buyer
            );
            service.changeProjectState(_index, LibProject.FileState.Completed);
            emit changeFileStateEv(
                _index,
                LibProject.FileState.Completed,
                buyer
            );
        } else {
            //任务不通过，将任务者的状态修改为被打回状态
            service.changeTaskVfState(_index, LibProject.TaskerState.Return);
            emit changeTaskerStateEv(
                _index,
                LibProject.TaskerState.Return,
                false,
                buyer
            );
            service.changeProjectState(
                _index,
                LibProject.FileState.WaitVfModify
            );
            emit changeFileStateEv(
                _index,
                LibProject.FileState.WaitVfModify,
                service.getVerfier(_index)
            );
            //service.addReturnRecord(_index,_address,buyer,_file,_illustrate);
            returnRecordList[_index] = LibProject.ReturnRecord(
                service.getVerfier(_index),
                _file,
                _illustrate
            );
            emit returnFileEv(
                _index,
                service.getVerfier(_index),
                _file,
                _illustrate
            );
        }
    }

    function deductPay(address _to, uint256 _value) public {
        // service = AmphiTrans(serviceAddess);
        service.deductPay(_to, _value);
        emit decutPayEv(_to, _value);
    }

    function addPay(address _to, uint256 _value) public {
        // service = AmphiTrans(serviceAddess);
        service.addPay(_to, _value);
        emit addPayEv(_to, _value);
    }

    function closeTask(uint256 _index) public {
        // service = AmphiTrans(serviceAddess);
        service.changeProjectState(_index, LibProject.FileState.Closed);
        emit changeFileStateEv(_index, LibProject.FileState.Closed, msg.sender);
    }

    function _isHasNftPass(address _address) internal view returns (bool) {
        // uint256[] memory _list = amphi.walletOfOwner(_address);
        if (amphi.walletOfOwner(_address).length > 0) {
            return true;
        }
        return false;
    }
}
