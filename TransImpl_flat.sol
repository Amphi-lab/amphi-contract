
// File: contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: TransferService.sol


pragma solidity ^0.8.0;

contract TransferService {
    address constant AMPHI_ADDRESS = 0x6CA0189baF54f88684ED158193021e45745F810e;
    event payEv(address,address,uint256);
    //锁
    bool locked;
 
    modifier noLock() {
        require(!locked, "The lock is locked.");
        locked = true;
        _;
        locked = false;
    }
    // 向合约账户转账 
    function transderToContract()  public payable{
        (bool sent,) = payable(address(this)).call{value: msg.value}("");
        require(sent, "Call failed");
        emit payEv(msg.sender,address(this),msg.value);
        //payable(address(this)).transfer(msg.value);
    }
    
    // 获取合约账户余额 
    function getBalanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }
    //提取合约金额
    function _withdraw(uint256 _money) internal  {
        //  (bool callSuccess, ) = payable(AMPHI_ADDRESS).call{value: address(this).balance}("");
        (bool callSuccess, ) = payable(AMPHI_ADDRESS).call{value: _money *1e18}("");
        require(callSuccess, "Call failed");
        emit payEv(address(this),msg.sender,address(this).balance);
    }
    function _withdrawAll() internal  {
         (bool callSuccess, ) = payable(AMPHI_ADDRESS).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
        emit payEv(address(this),msg.sender,address(this).balance);
    }
    //合约给指定用户转账
    // function toTaskerBounty(address _to,uint256 _bounty) internal{
    //   require(getBalanceOfContract()>= _bounty *1e18, "The balance is not sufficient.");
    //   (bool callSuccess, ) =  payable(_to).call{value: _bounty *1e18}("");
    //     require(callSuccess, "Call failed");
    //     emit payEv(address(this),_to,_bounty);
    // }
    function toTaskerBounty(address _to,uint256 _bounty) internal{
      require(getBalanceOfContract()>= _bounty, "The balance is not sufficient.");
      (bool callSuccess, ) =  payable(_to).call{value: _bounty}("");
        require(callSuccess, "Call failed");
        emit payEv(address(this),_to,_bounty);
    }
    //转账
    function pay(address _to,uint256 _money) internal  noLock{
       (bool callSuccess, )= payable(_to).call{value: _money}("");
       require(callSuccess, "Call failed");
       emit payEv(msg.sender,_to,_money);
    }
   
    fallback() external payable {}
    
    receive() external payable {}
}
// File: contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: utils/calculateUtils.sol


pragma solidity ^0.8.0;

error ParameterException(string);
library CalculateUtils {
    uint256 constant RATE = 273;
    uint256 constant VF_N = 3;
   // uint256 private TransRate ;
    //获得罚金比率
    function punishRatio(uint256 _bounts) public pure returns(uint256) {
        uint256 ratio;
        if (_bounts <RATE) {
            ratio = 1;
        }else if(_bounts>=RATE&&_bounts<RATE*1e1) {
            ratio = 1e1;
        }else if(_bounts >=RATE*1e1 && _bounts <RATE*1e2){
            ratio = 1e2;
        }else if(_bounts >=RATE*1e2 && _bounts < RATE*1e3) {
            ratio = 1e3;
        }else if(_bounts>=RATE*1e3 && _bounts <=RATE*1e4) {
            ratio = 1e4;
        }else if(_bounts>=RATE*1e4 && _bounts <=RATE*1e5) {
            ratio = 1e5;
        }else{
            revert ParameterException("Unable to calculate,Please submit a request");
        }
        return ratio;
    }
    //修改汇率
    // function setRate(uint256 _rate) internal onlyOwner{
    //     rate = _rate;
    // }
    //校对工作量（人） 校对人数= 翻译人数/校对工作量
    // function setvfN(uint256 _vfN) internal onlyOwner {
    //     vfN =_vfN;
    // }
    function getMatNumber(uint256 _transNumber)external pure returns(uint256 ){
        uint256 _maxV;
        if(_transNumber<=VF_N){
                 _maxV = 1;
        }else{
                  _maxV = SafeMath.div(_transNumber, VF_N);
        }
        return _maxV;
    }
    //计算任务赏金-翻译者
     function getTaskTrans(uint256 _bounty) internal pure returns(uint256 _money) {
        _money = getPercentage(_bounty,54);
    }
    function getTaskTransEnd(uint256 _bounty) internal pure returns(uint256 _money) {
        _money = getPercentage(_bounty,24);
    }
    function getTaskTransFirst(uint256 _bounty) internal pure returns(uint256 _money){
        _money = getPercentage(_bounty,30);
    }
    //计算任务赏金-校验者
    function getTaskVf(uint256 _bounty) internal pure returns(uint256 _money) {
        _money = getPercentage(_bounty,36);
    }
    //计算任务赏金
    function getPercentage(uint256 _number, uint256 _ratio) pure internal returns(uint256 returnNumber) {
        returnNumber = SafeMath.mul(_number,_ratio)/100;
    }
    //计算罚金
    function getPunish(uint256 _ratio,uint256 _bounty) public pure returns(uint256) {
        return SafeMath.div(_bounty,_ratio);
    }
    //计算扣除的赏金
    function getDeductMoney(uint256 _bounty,uint256 _deduct) public pure returns(uint256) {
        return getPercentage(_bounty,_deduct);
    }
    
}
// File: LibProject.sol


pragma solidity ^0.8.0;
library LibProject {
//项目状态：已发布、进行中、超时、无人选择、已关闭,已完成
 enum ProjectState {Waiting ,Published,Processing,Overtime, NoOnePick, Closed,Completed }
 // 校验者||翻译者状态 
 enum TaskerState {  Processing, Submitted,Return,Completed,Overtime }
 //文件状态 Waiting-等待翻译者、校验者接单 WaitingForTrans-等待翻译者接单，校验者已接单 , WaitingForVf-等待校验者接单，翻译者已接单
 enum FileState { Waiting,WaitingForTrans,WaitingForVf, Translating, Validating, WaitTransModify, BuyerReview, WaitVfModify,Accepted,NoOnePick,Overtime,Closed}
 //文件
 struct FileInfo {
     string  name; 
     uint256 size;
     uint256 videoLength;
     uint256 Page;
     uint256 words;
     uint256 fileType; //文件类型
     string  path;     //文件链接
 }
 //子任务详情
 struct TaskInfo {
     FileInfo file;    //文件信息
     uint256 bounty;  //赏金
     string info;     //任务说明
     FileState state; //任务状态
     uint256 lastUpload; //最后更新时间
 }
 struct FileIndexInfo {
     TaskerState state;
     string file;
    //  uint256 bounty;
 }
 //任务者
  struct Tasker {
     uint256[] taskIndex;   //任务（文件）索引
     mapping(uint256 => FileIndexInfo) info;
 }
 struct ReturnTasker {
    address taskerAddress; //任务者地址
    ReturnFileInfo[] taskerinfo;
}
struct ReturnFileInfo {
    uint256 taskIndex; //文件索引值
    TaskerState state;//文件状态
    string file;     //文件链接
    // uint256 bounty;  //赏金
}

// struct PayInfo {
//     uint256 id;
//     uint256 
// }
 //项目
 struct TranslationPro {
        address buyer;        //发布者
        uint256 releaseTime;  //发布时间
        string introduce;     //项目介绍
        string need;          //项目需求说明
        uint256 deadline;     //截至日期
        uint256 sourceLanguage;//源语言
        uint256 goalLanguage;  //目标语言
        uint256[] preferList;  //偏好
        uint256 translationType;//类型
        uint256 workLoad;       //工作量
        bool isNonDisclosure; //是否保密
        bool isCustomize;     //是否为自定义支付
        uint256 bounty;        //赏金
        TaskInfo[] tasks;     //子任务
        address[] translators;
        address[] verifiers;
        mapping(address => Tasker)transInfo;
        mapping(address => Tasker ) vfInfo;
        // Tasker[] translators; //翻译者
        // Tasker[] verifiers;   //校验者
        uint256 maxT;        //任务总量-翻译
        uint256 maxV;        //任务总量-校验
        uint256 numberT;     //已接任务数-翻译
        uint256 numberV;     //已接任务数-校对
        bool isTransActive;  //翻译者状态: true.开启 false：关闭 
        bool isVerActive;    //校验者状态: true:开启 false:关闭
        ProjectState state;        //项目状态
 }
 //项目发布参数
 struct ProParm {
        uint256 releaseTime;  //发布时间
        string introduce;     //项目介绍
        string need;          //项目需求说明
        uint256 deadline;     //截至日期
        uint256 sourceLanguage;//源语言
        uint256 goalLanguage;  //目标语言
        uint256[] preferList;  //偏好
        uint256 translationType;//类型
        uint256 workLoad;
        bool isNonDisclosure; //是否保密
        bool isCustomize;     //是否为自定义支付
        uint256 bounty;        //赏金
        TaskInfo[] tasks;     //子任务
 }
 //返回任务详情
 struct ReturnTask {
        address buyer;        //发布者
        uint256 releaseTime;  //发布时间
        string introduce;     //项目介绍
        string need;          //项目需求说明
        uint256 deadline;     //截至日期
        uint256 sourceLanguage;//源语言
        uint256 goalLanguage;  //目标语言
        uint256[] preferList;  //偏好
        uint256 translationType;//类型
        uint256 workLoad;       //工作量
        bool isNonDisclosure; //是否保密
        bool isCustomize;     //是否为自定义支付
        uint256 bounty;        //赏金
        ReturnFileInfo[] fileInfo;
        TaskInfo[] tasks;     //子任务
        ReturnTasker[] translators; //翻译者
        ReturnTasker[] verifiers;   //校验者
        uint256 maxT;        //任务总量-翻译
        uint256 maxV;        //任务总量-校验
        uint256 numberT;     //已接任务数-翻译
        uint256 numberV;     //已接任务数-校对
        bool isTransActive;  //翻译者状态: true.开启 false：关闭 
        bool isVerActive;    //校验者状态: true:开启 false:关闭
        ProjectState state;        //项目状态
 }
}
// File: TransService.sol


pragma solidity ^0.8.0;


error FileException(string,LibProject.FileState);
contract TransService {
    //任务索引值，文件索引值，文件状态，操作者
    event changeFileStateEv(uint256,uint256,LibProject.FileState,address);
    //任务索引值，文件状态，操作者
    event changeProjectStateEv(uint256,LibProject.ProjectState,address);
    //任务索引值、任务者地址、文件索引值，任务者状态，是否为翻译者,操作者
    event changeTaskerStateEv(uint256,address,uint256,LibProject.TaskerState,bool,address);
    //任务索引值，是否关闭，操作者
    event changeTransActive(uint256,bool,address);
    event changeVerActive(uint256,bool,address);
    mapping (uint256 => LibProject.TranslationPro) private taskList;
    mapping (address => uint256) private payList;
    uint256 private count;
    function addPay(address _tasker,uint256 _money) internal {
        payList[_tasker] += _money;
    }
    function deductPay(address _tasker, uint256 _money) internal {
        payList[_tasker]-= _money;
    }
    function getPay(address _tasker) public view returns(uint256) {
        return payList[_tasker];
    }
    //增加项目
    function addProject(LibProject.ProParm memory _t)  internal returns(uint256) {
       count++;
       //  taskIndex[_buyer].push(count);
        LibProject.TranslationPro storage _pro= taskList[count];
        _pro.buyer = msg.sender;
        _pro.releaseTime = _t.releaseTime;
        _pro.introduce = _t.introduce;
        _pro.need=_t.need;
        _pro.deadline=_t.deadline;
        _pro.sourceLanguage=_t.sourceLanguage;
        _pro.goalLanguage=_t.goalLanguage;
        _pro.preferList = _t.preferList;
        _pro.translationType=_t.translationType;
        _pro.workLoad = _t.workLoad;
        _pro.bounty=_t.bounty;
        _pro.isNonDisclosure = _t.isNonDisclosure;
        _pro.isCustomize = _t.isCustomize;
        if(_t.isCustomize) {
            _pro.maxT = _t.tasks.length; 
             _pro.maxV = _t.tasks.length;
            
         }else{
            _pro.maxT =1;
            _pro.maxV =1;
         }
        _pro.state = LibProject.ProjectState.Published;
        _pro.isTransActive = true;
        _pro.isVerActive = true;
        for(uint256 i=0;i< _t.tasks.length;i++) {
            _t.tasks[i].state= LibProject.FileState.Waiting;
            _pro.tasks.push(_t.tasks[i]);
        }
        return count;
    }
    function updateProject(uint256 _index,LibProject.ProParm memory _t)  internal{
        LibProject.TranslationPro storage _pro= taskList[_index];
        _pro.releaseTime = _t.releaseTime;
        _pro.introduce = _t.introduce;
        _pro.need=_t.need;
        _pro.deadline=_t.deadline;
        _pro.sourceLanguage=_t.sourceLanguage;
        _pro.goalLanguage=_t.goalLanguage;
        _pro.preferList = _t.preferList;
        _pro.translationType=_t.translationType;
        _pro.workLoad = _t.workLoad;
        _pro.bounty=_t.bounty;
        _pro.isNonDisclosure = _t.isNonDisclosure;
        _pro.isCustomize = _t.isCustomize;
        _pro.state = LibProject.ProjectState.Published;
       if(_t.isCustomize) {
            _pro.maxT = _t.tasks.length; 
             _pro.maxT = _t.tasks.length;
            
         }else{
            _pro.maxT =1;
            _pro.maxT =1;
         }
        _pro.isTransActive = true;
        _pro.state = LibProject.ProjectState.Published;
        for(uint256 i=0;i< _t.tasks.length;i++) {
            _pro.tasks.push(_t.tasks[i]);
        }
    }
    //修改项目状态
    function updateState(uint256 _index, LibProject.ProjectState _state) internal {
        taskList[_index].state = _state;
        emit changeProjectStateEv(_index,_state,msg.sender);
    }
    //批量修改任务状态
    function updateTaskerState(uint256 _index,address  _taskerAddress,uint256[] memory _fileIndex,LibProject.TaskerState _state, bool _isTrans) internal {
        if(_isTrans){
            //  _tasker=taskList[_index].transInfo[_taskerAddress];
        for(uint256 i=0;i<_fileIndex.length;i++) {
            taskList[_index].transInfo[_taskerAddress].info[_fileIndex[i]].state = _state;
            emit changeTaskerStateEv(_index,_taskerAddress,_fileIndex[i],_state,true,msg.sender);
        }
        }else{
        for(uint256 i=0;i<_fileIndex.length;i++) {
            taskList[_index].vfInfo[_taskerAddress].info[_fileIndex[i]].state = _state;
            emit changeTaskerStateEv(_index,_taskerAddress,_fileIndex[i],_state,false,msg.sender);
        }
        }
    }
    function returnTasker(uint256 _index,address _taskerIndex,uint256 _fileIndex,bool _isTrans)internal {
        //修改任务者状态&修改文件状态
        if(_isTrans) {
            taskList[_index].transInfo[_taskerIndex].info[_fileIndex].state=LibProject.TaskerState.Return;
             emit changeTaskerStateEv(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Return,true,msg.sender);
            taskList[_index].tasks[_fileIndex].state = LibProject.FileState.WaitTransModify;
            emit changeFileStateEv(_index,_fileIndex,LibProject.FileState.WaitTransModify,msg.sender);
        }else {
            taskList[_index].vfInfo[_taskerIndex].info[_fileIndex].state=LibProject.TaskerState.Return;
            emit changeTaskerStateEv(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Return,false,msg.sender);
            taskList[_index].tasks[_fileIndex].state = LibProject.FileState.WaitVfModify;
            emit changeFileStateEv(_index,_fileIndex,LibProject.FileState.WaitVfModify,msg.sender);
        }
    }
    function onNoOnePink(uint256 _index) internal {
        taskList[_index].state = LibProject.ProjectState.NoOnePick;
        emit changeProjectStateEv(_index,LibProject.ProjectState.NoOnePick,msg.sender);
        taskList[_index].isVerActive = false;
        emit changeTransActive(_index,false,msg.sender);
    }
    function closeTransAccept(uint256 _index) internal {
        taskList[_index].isTransActive = false;
        emit changeTransActive(_index,false,msg.sender);
    }
    function _closeFileState(uint256 _index,uint256 _fileIndex) internal {
        taskList[_index].tasks[_fileIndex].state = LibProject.FileState.Closed;
        emit changeFileStateEv(_index,_fileIndex,LibProject.FileState.Closed,msg.sender);
    }
    function getTaskBounty(uint256 _index,uint256 _fileIndex) public view returns(uint256) {
        return taskList[_index].tasks[_fileIndex].bounty;
    }
    function getTaskBounty(uint256 _index) public view returns(uint256) {
        return taskList[_index].bounty;
    }
    function closeVfAccept( uint256 _index) internal {
        taskList[_index].isVerActive = false;
        emit changeVerActive(_index,false,msg.sender);
    }
    //翻译者提交任务
    function sumbitTransTask(uint256 _index,address _taskerIndex, uint256 _fileIndex,string memory _file) internal {
         LibProject.TranslationPro storage _pro= taskList[_index];
        _pro.tasks[_fileIndex].state = LibProject.FileState.Validating;
        emit changeFileStateEv(_index,_fileIndex,LibProject.FileState.Validating,msg.sender);
        _pro.tasks[_fileIndex].lastUpload = block.timestamp;
        _pro.transInfo[_taskerIndex].info[_fileIndex].file = _file;
        _pro.transInfo[_taskerIndex].info[_fileIndex].state= LibProject.TaskerState.Submitted;
        emit changeTaskerStateEv(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Submitted,true,msg.sender);
    }
    //校验者验收&提交任务
    function sumbitVfTask(uint256 _index,address _transIndex,address _vfIndex, uint256 _fileIndex,string memory _file) internal {
        
         LibProject.TranslationPro storage _pro= taskList[_index];
         _pro.transInfo[_transIndex].info[_fileIndex].state =LibProject.TaskerState.Completed;
         emit changeTaskerStateEv(_index,_transIndex,_fileIndex,LibProject.TaskerState.Completed,true,msg.sender);
         //校验者提交任务
         _pro.tasks[_fileIndex].state = LibProject.FileState.BuyerReview;
         emit changeFileStateEv(_index,_fileIndex,LibProject.FileState.BuyerReview,msg.sender);
        _pro.tasks[_fileIndex].lastUpload = block.timestamp;
        _pro.vfInfo[_vfIndex].info[_fileIndex].file = _file;
        _pro.vfInfo[_vfIndex].info[_fileIndex].state = LibProject.TaskerState.Submitted;
         emit changeTaskerStateEv(_index,_vfIndex,_fileIndex,LibProject.TaskerState.Submitted,false,msg.sender);
    }
    //翻译者接收任务
    function acceptTrans(uint256 _index,uint256[] memory _fileIndex, address _taskerIndex) internal{
       //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
       LibProject.Tasker storage _taskerInfo = taskList[_index].transInfo[_taskerIndex];
       if(_taskerInfo.taskIndex.length==0) {
           taskList[_index].translators.push(_taskerIndex);
        }
        LibProject.FileState _state;
        for(uint256 q=0;q<_fileIndex.length;q++) {
            _state =taskList[_index].tasks[_fileIndex[q]].state;
            //根据目前文件状态，修改文件状态
            if(_state== LibProject.FileState.Waiting) {
                taskList[_index].tasks[_fileIndex[q]].state = LibProject.FileState.WaitingForVf;
                emit changeFileStateEv(_index,_fileIndex[q],LibProject.FileState.WaitingForVf,msg.sender);
            }else if(_state == LibProject.FileState.WaitingForTrans) {
                taskList[_index].tasks[_fileIndex[q]].state= LibProject.FileState.Translating;
                emit changeFileStateEv(_index,_fileIndex[q],LibProject.FileState.Translating,msg.sender);
            }else{
                revert FileException("Error file state",_state);
            }
            _taskerInfo.taskIndex.push(_fileIndex[q]);
           
        }
        //    //文件状态修改为翻译中
       taskList[_index].numberT++;
       if(isFull(_index,true)) {
          taskList[_index].isTransActive = false;
          emit changeTransActive(_index,false,msg.sender);
       }
    }
     //校验者接收任务
    function acceptVf(uint256 _index,uint256[] memory _fileIndex, address _taskerIndex) internal {
       //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
       LibProject.Tasker storage _taskerInfo = taskList[_index].vfInfo[_taskerIndex];
       if(_taskerInfo.taskIndex.length==0) {
           taskList[_index].verifiers.push(_taskerIndex);
        }
        LibProject.FileState _state;
        for(uint256 q=0;q<_fileIndex.length;q++) {
            _state =taskList[_index].tasks[_fileIndex[q]].state;
            //根据目前文件状态，修改文件状态
            if(_state == LibProject.FileState.Waiting) {
                taskList[_index].tasks[_fileIndex[q]].state = LibProject.FileState.WaitingForTrans;
                emit changeFileStateEv(_index,_fileIndex[q],LibProject.FileState.WaitingForTrans,msg.sender);
            }else if(_state == LibProject.FileState.WaitingForVf) {
                taskList[_index].tasks[_fileIndex[q]].state= LibProject.FileState.Translating;
                emit changeFileStateEv(_index,_fileIndex[q],LibProject.FileState.Translating,msg.sender);
            }else{
                revert FileException("Error file state",_state);
            }
            _taskerInfo.taskIndex.push(_fileIndex[q]);
           
        }
       //文件状态修改为翻译中
       taskList[_index].numberV++;
       if(isFull(_index,false)) {
          taskList[_index].isVerActive = false;
          emit changeVerActive(_index,false,msg.sender);
       }
    }
    function accept(uint256 _index,uint256  _fileIndex, address _taskerIndex, bool _isTrans) internal  {
         LibProject.FileIndexInfo storage _taskerInfo;
        if(_isTrans) {
            _taskerInfo = taskList[_index].transInfo[_taskerIndex].info[_fileIndex];
             taskList[_index].numberT++;
        }else{
            _taskerInfo = taskList[_index].vfInfo[_taskerIndex].info[_fileIndex];
             taskList[_index].numberV++;
        }
               taskList[_index].transInfo[_taskerIndex].taskIndex.push(_fileIndex);
    }
    //扣除罚金
    // function deductBounty(uint256 _index,address _taskerIndex,uint256 _fileIndex,uint256 _money,bool _isTrans) public  {
    //     if(_isTrans){
    //         taskList[_index].transInfo[_taskerIndex].info[_fileIndex].bounty-= _money;
    //     }else{
    //         taskList[_index].vfInfo[_taskerIndex].info[_fileIndex].bounty-= _money;
    //     }
    //     // emit deductBountyEv(_index,_taskerIndex,_money,msg.sender);
    // }
    //判断任务是否已满
    function isFull(uint256 _index, bool _isTrans) public view returns(bool) {
       if(_isTrans){
          return taskList[_index].maxT <= taskList[_index].numberT;
       }else{
          return taskList[_index].maxV <= taskList[_index].numberV;
       }
    }
    //关闭项目
    function _closeTask(uint256 _index) internal {
        taskList[_index].state = LibProject.ProjectState.Closed;
        emit changeProjectStateEv(_index,LibProject.ProjectState.Closed,msg.sender);
    }
    function completedTask(uint256 _index) internal {
        taskList[_index].state = LibProject.ProjectState.Completed;
         emit changeProjectStateEv(_index,LibProject.ProjectState.Completed,msg.sender);
    }
    function getProjectOne(uint256 _index) internal view returns(LibProject.ReturnTask memory) {
        LibProject.ReturnTask memory _returnTask;
        _returnTask.buyer =taskList[_index].buyer;
        _returnTask.releaseTime = taskList[_index].releaseTime;
        _returnTask.introduce = taskList[_index].introduce;
        _returnTask.need = taskList[_index].need;
        _returnTask.deadline = taskList[_index].deadline;
        _returnTask.sourceLanguage = taskList[_index].sourceLanguage;
        _returnTask.goalLanguage = taskList[_index].goalLanguage;
        _returnTask.preferList = taskList[_index].preferList;
        _returnTask.translationType = taskList[_index].translationType;
        _returnTask.workLoad = taskList[_index].workLoad;
        _returnTask.isNonDisclosure = taskList[_index].isNonDisclosure;
        _returnTask.isCustomize = taskList[_index].isCustomize;
        _returnTask.bounty = taskList[_index].bounty;
        _returnTask.maxT = taskList[_index].maxT;
        _returnTask.maxV = taskList[_index].maxV;
        _returnTask.numberT = taskList[_index].numberT;
        _returnTask.numberV = taskList[_index].numberV;
        _returnTask.isTransActive = taskList[_index].isTransActive;
        _returnTask.isVerActive = taskList[_index].isVerActive;
        _returnTask.state = taskList[_index].state;
        _returnTask.tasks = taskList[_index].tasks;
        for(uint256 i=0;i<taskList[_index].translators.length;i++) {
            LibProject.ReturnTasker memory  _taskerInfo;
            address _taskerAddress =taskList[_index].translators[i];
            _taskerInfo.taskerAddress = _taskerAddress;
            for(uint256 q=0;i<taskList[_index].transInfo[_taskerAddress].taskIndex.length;q++) {
                LibProject.ReturnFileInfo memory _fileInfo;
                _fileInfo.taskIndex =  taskList[_index].transInfo[_taskerAddress].taskIndex[q];
                _fileInfo.state = taskList[_index].transInfo[_taskerAddress].info[_fileInfo.taskIndex].state;
                _fileInfo.file = taskList[_index].transInfo[_taskerAddress].info[_fileInfo.taskIndex].file;
                // _fileInfo.bounty = taskList[_index].transInfo[_taskerAddress].info[_fileInfo.taskIndex].bounty;
                _taskerInfo.taskerinfo[q] = _fileInfo;
            }
            _returnTask.translators[i] = _taskerInfo;
        }
        for(uint256 i=0;i<taskList[_index].verifiers.length;i++) {
            LibProject.ReturnTasker memory  _taskerInfo;
            address _taskerAddress =taskList[_index].verifiers[i];
            _taskerInfo.taskerAddress = _taskerAddress;
            for(uint256 q=0;i<taskList[_index].vfInfo[_taskerAddress].taskIndex.length;q++) {
                LibProject.ReturnFileInfo memory _fileInfo;
                _fileInfo.taskIndex =  taskList[_index].vfInfo[_taskerAddress].taskIndex[q];
                _fileInfo.state = taskList[_index].vfInfo[_taskerAddress].info[_fileInfo.taskIndex].state;
                _fileInfo.file = taskList[_index].vfInfo[_taskerAddress].info[_fileInfo.taskIndex].file;
                // _fileInfo.bounty = taskList[_index].vfInfo[_taskerAddress].info[_fileInfo.taskIndex].bounty;
                _taskerInfo.taskerinfo[q] = _fileInfo;
            }
            _returnTask.verifiers[i] = _taskerInfo;
        }
       return _returnTask;
    }
    function getTasks(uint256 _index) public view returns(LibProject.TaskInfo[] memory) {
        return taskList[_index].tasks;
    }
    function getCount() public view returns(uint256) {
        return count;
    }
    //任务翻译者总数量
   function getTransNumber(uint256 _index) public view returns(uint256) {
       return taskList[_index].translators.length;
   }
   function getVfNumber(uint256 _index) public view returns(uint256) {
       return taskList[_index].verifiers.length;
   }
   //获得指定任务翻译者接单数
   function getAcceptTransNumber(uint256 _index,address _taskerIndex) public view returns(uint256) {
       return taskList[_index].transInfo[_taskerIndex].taskIndex.length;
   }
   function getAcceptVfNumber(uint256 _index, address _taskerIndex) public view returns(uint256) {
       return taskList[_index].vfInfo[_taskerIndex].taskIndex.length;
   }
   //获得翻译者名单
   function getTranslatorsList(uint256 _index) public view returns(address[] memory) {
       return taskList[_index].translators;
   }
   //获得校验者任务
   function getVfList(uint256 _index) public view returns(address[] memory) {
       return taskList[_index].verifiers;
   }
    function isCustomizeState(uint256 _index) public view returns(bool){
        return taskList[_index].isCustomize;
    }
    //查询任务者超时未完成任务数
    function overTimeTasker(uint256 _index, address _taskerIndex, bool _isTrans) public view returns(uint256[] memory,uint256) {
        uint256[] memory _filesIndex ;
        uint256[] memory _list;
        uint256 money;
        uint256 q;
        if(_isTrans) {
          _filesIndex  = taskList[_index].transInfo[_taskerIndex].taskIndex; 
        }else { 
            _filesIndex  = taskList[_index].vfInfo[_taskerIndex].taskIndex;
        }
        LibProject.FileIndexInfo memory  _info;
        for(uint256 i=0;i<_filesIndex.length;i++) {
           _info = taskList[_index].transInfo[_taskerIndex].info[_filesIndex[i]];
            if(_info.state == LibProject.TaskerState.Processing){
                _list[q] = _filesIndex[i];
                q++;
                money+= taskList[_index].tasks[_filesIndex[i]].bounty;
            }
        }   
        return (_list,money);
    }
    function receivePass(uint256 _index, address _taskerIndex,uint256 _fileIndex) internal {
        taskList[_index].vfInfo[_taskerIndex].info[_fileIndex].state=LibProject.TaskerState.Completed;
        emit changeTaskerStateEv(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Completed,false,msg.sender);
        taskList[_index].tasks[_fileIndex].state= LibProject.FileState.Accepted;
        emit changeFileStateEv(_index,_fileIndex, LibProject.FileState.Accepted,msg.sender);
    }
    // function getSubTaskBounty(uint256 _index,address _tasker,uint256 _fileIndex,bool _isTrans) public view returns(uint256){
    //     if(_isTrans) {
    //        return taskList[_index].transInfo[_tasker].info[_fileIndex].bounty;
    //     }else {
    //         return taskList[_index].vfInfo[_tasker].info[_fileIndex].bounty;
    //     }
    // }
    function getBuyer(uint256 _index) public view returns(address) {
        return taskList[_index].buyer;
    }
    function getTaskState(uint256 _index) public view returns(LibProject.ProjectState) {
        return taskList[_index].state;
    }
    function getFileState(uint256 _index,uint256 _fileIndex) public view returns(LibProject.FileState){
        return taskList[_index].tasks[_fileIndex].state;
    }
    function getTaskStateVf(uint256 _index) public view returns(bool) {
        return taskList[_index].isVerActive;
    }
    function getTaskStateTrans(uint256 _index) public view returns(bool) {
        return taskList[_index].isTransActive;
    }
}
// File: TransImpl.sol


pragma solidity ^0.8.0;




error OperationException(string);
// error ParameterException(string);
error ErrorValue(string,uint256);
error Permissions(string);
contract TransImpl is Ownable,TransferService,TransService{
    event postProjectEv(address,uint256,LibProject.ProParm);
    event acceptTaskEv(uint256,uint256[],address,bool);
    event acceptTaskEv(uint256,uint256,address,bool);

    modifier isCanAcceptTrans(uint256 _index) {
        if(!TransService.getTaskStateTrans(_index)){
            revert OperationException("OperationException: Can't receive task");
        }
        _;
    }
    modifier isCanAcceptVf(uint256 _index) {
        if(!TransService.getTaskStateVf(_index)){
            revert OperationException("OperationException: Can't receive task");
        }
        _;
    }
    modifier onlyBuyer(uint256 _index) {
        require(TransService.getProjectOne(_index).buyer == msg.sender,"Only buyer can call this.");
        _;
    }
    modifier isExist(uint256 _index){
        if(_index>TransService.getCount()){
            revert ParameterException("Wrong index value!");
        }
        _;
    }
    modifier hasFine(address _address) {
        uint256 _money =TransService.getPay(_address);
        if(_money>0) {
            revert Permissions("There is an unpaid penalty!");
        }
        _;
    }
    // TransService service;
    // constructor(address _serAddress) {
    //    service = TransService(_serAddress);
    // }
    //质押30%，校验通过，30%给翻译者，需求方验收通过，支付其余的赏金。
    //文件状态修改：翻译等待，校验等待
    function postTask(LibProject.ProParm memory _t) public payable hasFine(msg.sender)  returns(uint256 _index) {
       _index =  _postTask(_t);
       //质押30%赏金
      uint256 _bounty = CalculateUtils.getPercentage(_t.bounty*1e18,30);
      if(msg.value <_bounty ) {
          revert ErrorValue("error : Incorrect value",msg.value);
        }
        transderToContract();
    }
  
    function updateTask(uint256 _index,LibProject.ProParm memory _t) public payable hasFine(msg.sender) isExist(_index){
        _updateTask(_index, _t);
        uint256 _bounty = CalculateUtils.getPercentage(_t.bounty,30);
        if(msg.value != _bounty *1e18) {
          revert ErrorValue("error : Incorrect value",msg.value);
        }
        transderToContract();
       
    }
    function endTransAccept(uint256 _index) public isExist(_index) {
        _endTransAccept( _index);
    }
     function endTransVf(uint256 _index) public isExist(_index) {
        _endTransVf( _index);
    }
    function acceptForTranslator(uint256 _index,uint256[] memory _fileIndex) public isExist(_index) isCanAcceptTrans(_index) hasFine(msg.sender){
        TransService.acceptTrans(_index,_fileIndex,msg.sender);
        emit acceptTaskEv(_index,_fileIndex,msg.sender,true);
    }
    function acceptForVerifer(uint256 _index,uint256[] memory _fileIndex) public isExist(_index) isCanAcceptVf(_index) hasFine(msg.sender){
        TransService.acceptVf(_index,_fileIndex,msg.sender);
         emit acceptTaskEv(_index,_fileIndex,msg.sender,false);
    }
    function validate(uint256 _index,address _traner,uint256 _fileIndex, bool _isPass,string memory _file) public isExist(_index){
      LibProject.FileState _fileState;
        _fileState=TransService.getFileState(_index,_fileIndex);
        if(_fileState>LibProject.FileState.WaitVfModify){
          revert OperationException("unable to submit");
        }
      uint256 _bounty =  _validate(_index,_traner,_fileIndex,_isPass,_file);
       //发赏金
      if(_bounty>0) {
        //   service.deductBounty(_index,_traner,_fileIndex,_bounty,true);
          toTaskerBounty(_traner,_bounty);
      }
    }
    function sumbitTaskTrans(uint256 _index, uint256 _fileIndex,string memory _file) public isExist(_index){
      LibProject.FileState _fileState;
      _fileState=TransService.getFileState(_index,_fileIndex);
      if(_fileState>LibProject.FileState.BuyerReview){
          revert OperationException("unable to submit");
      }
        _sumbitTaskTrans(_index,_fileIndex,_file);
    }
    function overTimeTrans(uint256 _index, address _tasker)public isExist(_index) returns(uint256) {
         uint256 _money =  _overTimeTrans(_index,_tasker);
         TransService.addPay(_tasker, _money);
         return _money;
    }
     function overTimeVf(uint256 _index, address _tasker)public isExist(_index) returns(uint256) {
        uint256 _money = _overTimeVf(_index,_tasker);
        TransService.addPay(_tasker, _money);
        return _money;
     }
     //支付罚金
     function payFine(address _to) public  payable{
         if(msg.value > TransService.getPay(_to)*1e18){
             revert ErrorValue("value is too high",msg.value);
         }
         TransService.deductPay(_to,msg.value);
         pay(_to,msg.value);
     }
     function receiveTask(uint256 _index,address _taskerIndex,uint256 _fileIndex, bool _isPass,address _transAddress) public payable isExist(_index) {
         uint256 _bounty;
         if(TransService.isCustomizeState(_index)){
                 _bounty = TransService.getTaskBounty(_index,_fileIndex);
         }else{
                 _bounty = TransService.getTaskBounty(_index);
          }
           _receiveTask(_index,_taskerIndex,_fileIndex,_isPass);
         //若验收通过，将合约剩余的70%的钱存入合约中
         if(_isPass){
             uint256 _payMoney = CalculateUtils.getPercentage(_bounty*1e18,70);
             if(msg.value < _payMoney) {
                 revert ErrorValue("error : Incorrect value",msg.value);
                 }
            transderToContract();
            uint256 _vfBounty = CalculateUtils.getTaskVf(_bounty*1e18);
             uint256 _transBounty = CalculateUtils.getTaskTransEnd(_bounty*1e18);
             toTaskerBounty(_taskerIndex,_vfBounty);
             toTaskerBounty(_transAddress,_transBounty);
        }    
     }
     function closeTask(uint256 _index) public {
         TransService._closeTask(_index);
     }
     function closeFileState(uint256 _index,uint256 _fileIndex) public {
         TransService._closeFileState(_index,_fileIndex);
     }
    //发布任务
     function _postTask(LibProject.ProParm memory _t) internal returns(uint256) {
     uint256 _index = TransService.addProject( _t);
     emit postProjectEv(msg.sender,_index,_t);
       return _index;
    }
    function getTaskInfo(uint256 _index) public view isExist(_index) returns(LibProject.ReturnTask memory) {
        return TransService.getProjectOne(_index);
    }
    //支付赏金-发布
    //function postPay(uint256 _index) 
    //修改任务
    function _updateTask(uint256 _index,LibProject.ProParm memory _t) internal {
         TransService.updateProject(_index,_t);
       emit postProjectEv(msg.sender,_index,_t);
    }  //到截至日期后，调用该方法，若到截至日期已经完成接单，则返回true,//若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
    //若有部分人接收，进入任务强分配
    function _endTransAccept( uint256 _index) internal returns(bool){
        uint256 _transNumber = TransService.getTransNumber(_index);
        LibProject.TaskInfo[] memory _tasks = TransService.getTasks(_index);
      if(TransService.isFull(_index,true)){
          return true;
          //若到翻译截至日期，仍无人接单，则关闭翻译接单状态
      }else if(_transNumber == 0) {
          //service.updateState(_index,LibProject.ProjectState.NoOnePick);
          TransService.closeTransAccept(_index);
          // emit uploadAcceptStateEv(msg.sender, _index,"ts",false);
          return false;
      }else {
          uint256 _count = _tasks.length;
          uint256 _acceptedNum = _transNumber;
          uint256 avgNum = _count/_acceptedNum;
          address[] memory _list = TransService.getTranslatorsList(_index);
          for(uint256 i =0;i<_tasks.length;i++) {
              //任务为待接收状态
              if(_tasks[i].state == LibProject.FileState.Waiting){
                  //为未分配任务分配任务者
                  for(uint256 q=0;q<_transNumber;q++){
                      //超出分配线，不予分配
                   if(TransService.getAcceptTransNumber(_index,_list[q])>avgNum){
                      continue;
                  }
                  //将当前任务分配给翻译者
                 TransService.accept(_index,i,_list[q],true);
                emit acceptTaskEv(_index,i,_list[q],true);
                  break;
              }
            }      
          }
          TransService.closeTransAccept(_index);
          return false;
      }
    }
    //
   function _endTransVf( uint256 _index) internal onlyOwner returns(bool) {
       uint256 vfNumber = TransService.getVfNumber(_index);
       uint256 _transNumber = TransService.getTransNumber(_index); 
       LibProject.TaskInfo[] memory _tasks = TransService.getTasks(_index);
      if(TransService.isFull(_index,false)){
          return true;
      }else if(vfNumber==0 && _transNumber!=0) {
          TransService.closeVfAccept(_index);
          return false;
      }
      else if(vfNumber == 0 && _transNumber ==0) {
           //若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
          TransService.onNoOnePink(_index);
          address _buyer =TransService.getBuyer(_index);
          uint256 _bounty = CalculateUtils.getPercentage(TransService.getTaskBounty(_index),30);
          //退还金额给需求方
          toTaskerBounty(_buyer,_bounty);
          return false;
      }else {
          //若有部分人接收
          uint256 _count = _tasks.length;
          uint256 _acceptedNum = vfNumber;
          uint256 avgNum = _count/_acceptedNum;
          address[] memory _list = TransService.getVfList(_index);
          for(uint256 i =0;i<_tasks.length;i++) {
              //任务为待接收状态
              if(_tasks[i].state == LibProject.FileState.Waiting){
                  //为未分配任务分配任务者
                  for(uint256 q=0;q<vfNumber;q++){
                      //超出分配线，不予分配
                  if(TransService.getAcceptVfNumber(_index,_list[q])>avgNum){
                      continue;
                  }
                  //将当前任务分配给翻译者
                   TransService.accept(_index,i,_list[q],false);
                   emit acceptTaskEv(_index,i,_list[q],false);
                  break;
              }
            }      
          }
          TransService.closeVfAccept(_index);
          return false;
      }
    }
    //提交任务-翻译者
    function _sumbitTaskTrans(uint256 _index, uint256 _fileIndex,string memory _file) internal {
       TransService.sumbitTransTask(_index,msg.sender,_fileIndex,_file);
    }

    //超时未提交-翻译者
    function _overTimeTrans(uint256 _index, address _taskerIndex)internal returns(uint256) {
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted,_money) = TransService.overTimeTasker(_index,_taskerIndex,true);
        if(_unCompleted.length ==0) {
            return 0;
        }
        //修改任务状态
        TransService.updateTaskerState(_index,_taskerIndex,_unCompleted,LibProject.TaskerState.Overtime,true);
        uint256 _allBounty;
        if(TransService.isCustomizeState(_index)){
            for(uint256 i=0;i<_unCompleted.length;i++) {
                _allBounty+=TransService.getProjectOne(_index).tasks[_unCompleted[i]].bounty;
            }
        }else{
            _allBounty =TransService.getProjectOne(_index).bounty;
        }
        //计算罚金 
    //   uint256 _rate=  CalculateUtils.punishRatio(service.getTranslators(_index,_taskerIndex).bounty);
       uint256 _rate=  CalculateUtils.punishRatio(CalculateUtils.getTaskTrans(_allBounty));  
      uint256 _punish = CalculateUtils.getPunish(_money,_rate);
        //返回罚金
        return _punish;
    }
      //超时未提交-校验者
    function _overTimeVf(uint256 _index, address _taskerIndex)internal returns(uint256) {
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted,_money) = TransService.overTimeTasker(_index,_taskerIndex,false);
        if(_unCompleted.length ==0) {
            return 0;
        }
        //修改任务状态
         TransService.updateTaskerState(_index,_taskerIndex,_unCompleted,LibProject.TaskerState.Overtime,false);   
        //计算罚金
        uint256 _allBounty;
        if(TransService.isCustomizeState(_index)){
            for(uint256 i=0;i<_unCompleted.length;i++) {
                _allBounty+=TransService.getProjectOne(_index).tasks[_unCompleted[i]].bounty;
            }
        }else{
            _allBounty =TransService.getProjectOne(_index).bounty;
        }
        //1.根据赏金获得处罚比率
        uint256 _rate=  CalculateUtils.punishRatio(CalculateUtils.getTaskVf(_allBounty));
        uint256 _punish = CalculateUtils.getPunish(_money,_rate);
        return _punish;
    }
    //校验者验收
     function _validate(uint256 _index,address _transIndex,uint256 _fileIndex, bool _isPass,string memory _file) internal returns(uint256 _payBounty) {
         //若校验通过，将任务者的状态修改为已完成
         if(_isPass) {
             //若用户为自定义支付，则完成后支付任务者赏金
             TransService.sumbitVfTask(_index,_transIndex,msg.sender,_fileIndex,_file);
             bool _Customize=TransService.isCustomizeState(_index);
             if(_Customize){
                 _payBounty = TransService.getTaskBounty(_index,_fileIndex);
             }else{
                 _payBounty = TransService.getTaskBounty(_index);
             }
             //校验者验收，支付翻译者30%赏金
            _payBounty = CalculateUtils.getPercentage(_payBounty*1e18,30);
         }else{
             //任务不通过，将任务者的状态修改为被打回状态 
             TransService.returnTasker(_index,_transIndex,_fileIndex,true);   
             _payBounty = 0; 
         }
         
     }
    //  扣除赏金
    //  function _deduct(uint256 _index, address _taskerIndex,uint256 _fileIndex,uint256 _deductNumeber, bool _isTrans) internal  {
    //      uint256 _bounty = service.getTaskBounty(_index,_fileIndex);
    //      uint256 _deductMoney ;
    //      if(_isTrans) {
    //        _deductMoney =  CalculateUtils.getDeductMoney( _bounty,_deductNumeber);
    //      }else {
    //        _deductMoney =  CalculateUtils.getDeductMoney( _bounty,_deductNumeber); 
    //      }
    //      service.deductBounty(_index,_taskerIndex,_fileIndex,_deductMoney,_isTrans);
    //  }
    //发布者验收
    function _receiveTask(uint256 _index,address _taskerIndex,uint256 _fileIndex, bool _isPass) internal{
         //若校验通过，将任务者的状态修改为已完成
         if(_isPass) {
             TransService.receivePass(_index,_taskerIndex,_fileIndex);
         }else{
             //任务不通过，将任务者的状态修改为被打回状态
             TransService.returnTasker(_index,_taskerIndex,_fileIndex,false);   
         }
     }
     function withdraw(uint256 _money) public onlyOwner {
         _withdraw(_money);
     }
     function withdrawAll() public onlyOwner {
         _withdrawAll();
     }
     
}