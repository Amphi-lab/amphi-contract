
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
            //revert ParameterException("Unable to calculate,Please submit a request");
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
        uint256 _taskBounty = _getPercentage(_bounty,90);
        _money = _getPercentage(_taskBounty,60);
    }
    //计算任务赏金-校验者
    function getTaskVf(uint256 _bounty) internal pure returns(uint256 _money) {
        uint256 _taskBounty = _getPercentage(_bounty,90);
        _money = _getPercentage(_taskBounty,40);
    }
    //计算任务赏金
    function _getPercentage(uint256 _number, uint256 _ratio) pure internal returns(uint256 returnNumber) {
        returnNumber = SafeMath.mul(_number,_ratio)/100;
    }
    //计算罚金
    function getPunish(uint256 _ratio,uint256 _bounty) public pure returns(uint256) {
        return SafeMath.div(_bounty,_ratio);
    }
    //计算扣除的赏金
    function getDeductMoney(uint256 _bounty,uint256 _deduct) public pure returns(uint256) {
        return _getPercentage(_bounty,_deduct);
    }
}
// File: LibProject.sol


pragma solidity ^0.8.0;
library LibProject {
//项目状态：已发布、进行中、超时、无人选择、已关闭,已完成
 enum ProjectState { Published,Processing,Overtime, NoOnePick, Closed,Completed }
 // 校验者||翻译者状态 
 enum TaskerState { Waiting, Processing, Submitted,Return,Completed,Overtime }
 //文件状态
 enum FileState { Waiting, Translating, Validating, WaitTransModify, BuyerReview, WaitVfModify,Accepted,NoOnePick}
 //文件
 struct FileInfo {
     string  name;
     uint256 size;
     uint256 videoLength;
     uint256 Page;
     uint256 words;
     uint256 fileType;
     string  path;
 }
 //子任务详情
 struct TaskInfo {
     FileInfo file; 
     uint256 bounty; 
     string info;
     FileState state;
     uint256 lastUpload;
 }
 struct SubtaskInfo {
     uint256 taskIndex;
     uint256 TaskerState;
     string file;
 }
 struct Tasker {
     address taskerAddress;
     uint256[] taskIndex;
     TaskerState[] states;
     string[] files;
     uint256 bounty;
     //SubtaskInfo[] taskInfo;
     //string[] files;
 }
 //项目
 struct TranslationPro {
        address buyer;
        uint256 releaseTime;  //发布时间
        string introduce;     //项目介绍
        string need;          //项目需求说明
        uint256 deadline;     //截至日期
        string sourceLanguage;//源语言
        string goalLanguage;  //目标语言
        string[] preferList;  //偏好
        uint256 translationType;//类型
        uint256 workLoad;
        bool isNonDisclosure; //是否保密
        bool isCustomize;     //是否为自定义支付
        uint256 bounty;        //赏金
        TaskInfo[] tasks;     //子任务
        Tasker[] translators; //翻译者
        Tasker[] verifiers;   //校验者
        uint256 maxT;        //翻译者最大人数
        uint256 maxV;        //校验者最大人数
        bool isTransActive;  //翻译者状态: true.开启 false：关闭 
        bool isVerActive;    //校验者状态: true:开启 false:关闭
        ProjectState state;        //项目状态
 }
 //项目
 struct ProParm {
        uint256 releaseTime;  //发布时间
        string introduce;     //项目介绍
        string need;          //项目需求说明
        uint256 deadline;     //截至日期
        string sourceLanguage;//源语言
        string goalLanguage;  //目标语言
        string[] preferList;  //偏好
        uint256 translationType;//类型
        uint256 workLoad;
        bool isNonDisclosure; //是否保密
        bool isCustomize;     //是否为自定义支付
        uint256 bounty;        //赏金
        TaskInfo[] tasks;     //子任务
        // uint256 maxT;        //翻译者最大人数
        // uint256 maxV;        //校验者最大人数
 }
}
// File: TransService.sol


pragma solidity ^0.8.0;



error OperationException(string,uint256);
error ParameterException(string);
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
contract TransService {
    
    mapping (uint256 => LibProject.TranslationPro) private taskList;
    uint256 private count;
    //增加项目
    function addProject(LibProject.ProParm memory _t)  public returns(uint256) {
       _addCount();
       //  taskIndex[_buyer].push(count);
        LibProject.TranslationPro storage _pro= taskList[count];
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
        if(!(_t.isCustomize)) {
            _pro.maxT =1;
            _pro.maxT =1;
         }else{
            _pro.maxT = _t.tasks.length; 
             _pro.maxT = _t.tasks.length;
             //_t.maxV=CalculateUtils.getMatNumber(_t.maxT );
         }
        // _pro.maxT = _t.maxT;
        // _pro.maxV = _t.maxV;
        _pro.isTransActive = true;
        _pro.isVerActive = true;
        for(uint256 i=0;i< _t.tasks.length;i++) {
            _pro.tasks.push(_t.tasks[i]);
        }
       // emit addProjectEv(msg.sender,count,_t);
        return getCount();
    }
        function updateProject(uint256 _index,LibProject.ProParm memory _t)  public{
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
         if(!(_t.isCustomize)) {
            _pro.maxT =1;
            _pro.maxT =1;
         }else{
            _pro.maxT = _t.tasks.length; 
             _pro.maxT = _t.tasks.length;
             //_t.maxV=CalculateUtils.getMatNumber(_t.maxT );
         }
        _pro.isTransActive = true;
        _pro.state = LibProject.ProjectState.Published;
        for(uint256 i=0;i< _t.tasks.length;i++) {
            _pro.tasks.push(_t.tasks[i]);
        }
     //   emit updateProjectEv(_index,_t);
    }
    //修改项目状态
    function updateState(uint256 _index, LibProject.ProjectState _state) public {
        taskList[_index].state = _state;
      //  emit updateProSateEv(_index,_state);
    }
    //修改文件状态
    function updateFileStateAndTime(uint256 _index,uint256 _fileIndex,LibProject.FileState _state) public {
        LibProject.TaskInfo storage _task= taskList[_index].tasks[_fileIndex];
        _task.state = _state;
        _task.lastUpload = block.timestamp;
      //  emit updateFileStateAndTimeEv(_index,_fileIndex,msg.sender,_state);
    }
    //修改任务者状态
    function updateTaskerState(uint256 _index,uint256 _taskerIndex,uint256 _stateIndex,LibProject.TaskerState _state, bool _isTrans) public {
        if(_isTrans){
            taskList[_index].translators[_taskerIndex].states[_stateIndex] = _state;
        }else{
           taskList[_index].verifiers[_taskerIndex].states[_stateIndex] = _state;
        }

      // emit updateTaskerStateEv(_index,_taskerIndex,_stateIndex,msg.sender,_state,_isTrans);
    }
    //修改/上传任务文件
    function updateFileInfo(uint256 _index,uint256 _taskerIndex,uint256 _fileIndex,string memory _fileInfo,bool _isTrans) public {
        if(_isTrans){
           taskList[_index].translators[_taskerIndex].files[_fileIndex] = _fileInfo;
        }else{
            taskList[_index].verifiers[_taskerIndex].files[_fileIndex] = _fileInfo;
        }
      //  emit updateFileInfoEv(_index,_taskerIndex,_fileIndex,msg.sender,_fileInfo,_isTrans);
    }
    function closeTransAccept(uint256 _index) public {
        taskList[_index].isTransActive = false;
       // emit uploadAcceptStateEv(msg.sender, _index,"ts",false);
    }
    function closeVfAccept( uint256 _index) public {
        taskList[_index].isVerActive = false;
       //  emit uploadAcceptStateEv(msg.sender, _index,"vf",false);
    }
    function openTransAccept( uint256 _index) public {
        taskList[_index].isTransActive = true;
        // emit uploadAcceptStateEv(msg.sender, _index,"ts",true);
    }
    function openVfAccept( uint256 _index) public {
        taskList[_index].isVerActive = true;
       //  emit uploadAcceptStateEv(msg.sender, _index,"ts",true);
    }
    //查询指定项目翻译者信息
    function getTranslators(uint256 _index, uint256 _taskerIndex) public view returns(LibProject.Tasker memory) {
        return taskList[_index].translators[_taskerIndex];
    }
    // //查询指定项目校验者名单
    function getVerifiers(uint256 _index,uint256 _taskerIndex) public view returns(LibProject.Tasker memory) {
        return taskList[_index].verifiers[_taskerIndex];
    }
    //翻译者接收任务
    function acceptTrans(uint256 _index,uint256[] memory _fileIndex, uint256 _taskerIndex,address _tasker) public{
       //若_taskerIndex为0，说明该任务者是首次接收该任务
       if(_taskerIndex==0) {
            LibProject.Tasker[] storage _taskerList= taskList[_index].translators;
           LibProject.Tasker memory _taskerInfo;
           
           _taskerInfo.taskerAddress = _tasker;
           _taskerInfo.taskIndex = _fileIndex;
           for(uint256 i=0;i<_fileIndex.length;i++){
               uint256 _bounty=getProjectOne(_index).tasks[i].bounty;
               _taskerInfo.bounty+= CalculateUtils.getTaskTrans(_bounty);
           }
           _taskerList.push(_taskerInfo);
         //  emit acceptTaskEv(_index,_fileIndex,_taskerList.length-1,_tasker,"translator");
       }else{
           LibProject.Tasker storage _taskerInfo = taskList[_index].translators[_taskerIndex];
           for(uint256 i=0;i<_fileIndex.length;i++) {
               _taskerInfo.taskIndex.push(_fileIndex[i]);
           }
           //emit acceptTaskEv(_index,_fileIndex,_taskerIndex,_tasker,"translators");
       }
       if(isFull(_index,true)) {
           closeTransAccept(_index);
       }
    }
    function acceptTrans(uint256 _index,uint256  _fileIndex, uint256 _taskerIndex) public {
           LibProject.Tasker storage _taskerInfo = taskList[_index].translators[_taskerIndex];
               _taskerInfo.taskIndex.push(_fileIndex);
               uint256 _bounty=getProjectOne(_index).tasks[_fileIndex].bounty;
               _taskerInfo.bounty+= CalculateUtils.getTaskTrans(_bounty);

          // emit acceptTaskEv(_index,_fileIndex,_taskerIndex,_tasker,"translators");
    }
     //校验者接收任务
    function acceptVf(uint256 _index,uint256[] memory _fileIndex, uint256 _taskerIndex,address _tasker) public {
       if(_taskerIndex==0) {
            LibProject.Tasker[] storage _taskerList= taskList[_index].verifiers;
           LibProject.Tasker memory _taskerInfo; 
           _taskerInfo.taskerAddress = _tasker;
           _taskerInfo.taskIndex = _fileIndex;
           for(uint256 i=0;i<_fileIndex.length;i++){
               uint256 _bounty=getProjectOne(_index).tasks[i].bounty;
               _taskerInfo.bounty+= CalculateUtils.getTaskVf(_bounty);
           }
           _taskerList.push(_taskerInfo);
           //emit acceptTaskEv(_index,_fileIndex,_taskerList.length-1,_tasker,"verifiers");
       }else{
           LibProject.Tasker storage _taskerInfo = taskList[_index].verifiers[_taskerIndex];
           for(uint256 i=0;i<_fileIndex.length;i++) {
               _taskerInfo.taskIndex.push(_fileIndex[i]);
           }
           //emit acceptTaskEv(_index,_fileIndex,_taskerIndex,_tasker,"verifiers");
       }
       if(isFull(_index,false)) {
           closeTransAccept(_index);
       }
    }
    function acceptVf(uint256 _index,uint256  _fileIndex, uint256 _taskerIndex) public  {
           LibProject.Tasker storage _taskerInfo = taskList[_index].verifiers[_taskerIndex];
               _taskerInfo.taskIndex.push(_fileIndex);
           uint256 _bounty=getProjectOne(_index).tasks[_fileIndex].bounty;
               _taskerInfo.bounty+= CalculateUtils.getTaskVf(_bounty);
          // emit acceptTaskEv(_index,_fileIndex,_taskerIndex,_tasker,"verifiers");
    }
    //扣除罚金
    function deductBounty(uint256 _index,uint256 _taskerIndex,uint256 _money,bool _isTrans) public  {
        if(_isTrans){
            taskList[_index].translators[_taskerIndex].bounty-= _money;
        }else{
            taskList[_index].verifiers[_taskerIndex].bounty-= _money;
        }
       // emit deductBountyEv(_index,_taskerIndex,_money,msg.sender);
    }
    //查询指定项目信息
    function getProject(uint256 _index) public view returns (LibProject.TranslationPro memory) {
        return taskList[_index];
    }
    //获得翻译者已接单任务数
    function getTransNumber(uint256 _index) public view returns(uint256) {
        LibProject.Tasker[] memory _taskers= taskList[_index].translators;
        uint256 num;
        for(uint256 i=0;i<_taskers.length;i++) {
            num+=_taskers[i].taskIndex.length;
        }
        return  num;
    }
    function getVfNumber(uint256 _index) public view returns(uint256) {
        LibProject.Tasker[] memory _taskers= taskList[_index].verifiers;
        uint256 num;
        for(uint256 i=0;i<_taskers.length;i++) {
            num+=_taskers[i].taskIndex.length;
        }
        return  num;
    }
    //判断任务是否已满
    function isFull(uint256 _index, bool _isTrans) public view returns(bool) {
       uint256 fileNumber = taskList[_index].tasks.length;
       uint256 acceptNumber;
       if(_isTrans){
          acceptNumber  = getTransNumber(_index);
       }else{
          acceptNumber  = getVfNumber(_index);
       }
       return acceptNumber == fileNumber;
    }
    function getProjectOne(uint256 _index) public view returns(LibProject.TranslationPro memory) {
        return taskList[_index];
    }
    function getCount() public view returns(uint256) {
        return count;
    }
    function _addCount() internal {
        count++;
    }
    function isCustomizeState(uint256 _index) public view returns(bool){
        return taskList[_index].isCustomize;
    }
    //查询任务者超时未完成任务数
    function overTimeTasker(uint256 _index, uint256 _taskerIndex, bool _isTrans) public view returns(uint256[] memory,uint256) {
        LibProject.TranslationPro memory _pro = getProject(_index);
        LibProject.TaskerState[] memory _states;
        uint256 money;
        if(_isTrans) {
            _states  = _pro.translators[_taskerIndex].states; 
        }else {
            _states  = _pro.verifiers[_taskerIndex].states; 
        }
        uint256[] memory _list;
        for(uint256 i=0;i<_states.length;i++) {
            if(_states[i]<LibProject.TaskerState.Submitted) {
               _list[_list.length] = i;
            }
            money+=_pro.tasks[i].bounty;
        }
        return (_list,money);
    }
    
}
// File: TransImpl.sol


pragma solidity ^0.8.0;




contract TransImpl is Ownable{
    event addProjectEv(address,uint256,LibProject.ProParm);
    event updateProjectEv(uint256,LibProject.ProParm);
    event updateProSateEv(uint256,LibProject.ProjectState);
    event uploadAcceptStateEv(address,uint256,string,bool);
    event acceptTaskEv(uint256,uint256[],uint256,address,string);
    event acceptTaskEv(uint256,uint256,uint256,address,string);
    event updateFileStateAndTimeEv(uint256,uint256,address,LibProject.FileState);
    event updateTaskerStateEv(uint256,uint256,uint256,address,LibProject.TaskerState,bool);
    event updateFileInfoEv(uint256,uint256,uint256,address,string,bool);
    event deductBountyEv(uint256,uint256,uint256,address);

    modifier isCanAcceptTrans(uint256 _index) {
        if(service.getProjectOne(_index).isTransActive == false || service.isFull(_index,true)== true){
            revert OperationException("OperationException: Can't receive task",_index);
        }
        _;
    }
    modifier isCanAcceptVf(uint256 _index) {
        if(service.getProjectOne(_index).isVerActive == true || service.isFull(_index,false)== false){
            revert OperationException("OperationException: Can't receive task",_index);
        }
        _;
    }
    modifier onlyBuyer(uint256 _index) {
        require(service.getProjectOne(_index).buyer == msg.sender,"Only buyer can call this.");
        _;
    }
     modifier isExist(uint256 _index){
        if(_index>service.getCount()){
            revert ParameterException("Wrong index value!");
        }
        _;
    }
    TransService service;
    constructor(address _serAddress) {
       service = TransService(_serAddress);
    }
    
    function postProject(LibProject.ProParm memory _t) public returns(uint256){
        return _postProject(_t);
    }
    function updateProject(uint256 _index,LibProject.ProParm memory _t) public{
        _updateProject(_index, _t);
    }
    function endTransAccept(uint256 _index) public {
        _endTransAccept( _index);
    }
     function endTransVf(uint256 _index) public {
        _endTransVf( _index);
    }
    function acceptForTranslator(uint256 _index,uint256[] memory _fileIndex, uint256 _taskerIndex) public {
        service.acceptTrans(_index,_fileIndex,_taskerIndex,msg.sender);
    }
    function acceptForVerifer(uint256 _index,uint256[] memory _fileIndex, uint256 _taskerIndex) public {
        service.acceptVf(_index,_fileIndex,_taskerIndex,msg.sender);
    }
    function validate(uint256 _index,uint256 _transIndex,uint256 _vfIndex,uint256 _fileIndex, bool _isPass,string memory _file) public {
        _validate(_index,_transIndex,_vfIndex,_fileIndex,_isPass,_file);
    }
    function sumbitTaskTrans(uint256 _index,uint256 _taskerIndex, uint256 _fileIndex,string memory _file) public {
        _sumbitTaskTrans(_index,_taskerIndex,_fileIndex,_file);
    }
    function overTimeTrans(uint256 _index, uint256 _taskerIndex)public returns(bool){
      return  _overTimeTrans(_index,_taskerIndex);
    }
     function overTimeVf(uint256 _index, uint256 _taskerIndex)public returns(bool) {
        return _overTimeVf(_index,_taskerIndex);
     }
     function deduct(uint256 _index, uint256 _taskerIndex,uint256 _fileIndex,uint256 _deduct, bool _isTrans) public {
         deduct(_index,_taskerIndex,_fileIndex,_deduct,_isTrans);
     }
     function receiveProject(uint256 _index,uint256 _taskerIndex,uint256 _fileIndex, bool _isPass) public {
         _receiveProject(_index,_taskerIndex,_fileIndex,_isPass);
     }
    //发布任务
     function _postProject(LibProject.ProParm memory _t) internal returns(uint256) {
         uint256 _index;
       _index = service.addProject( _t);
       //如果用户为自定义付款，用户先将赏金存入到合约中
       
       if (_t.isCustomize)
       return _index;
    }
    //修改任务
    function _updateProject(uint256 _index,LibProject.ProParm memory _t) internal {
   
         service.updateProject(_index,_t);
    }
    //到截至日期后，调用该方法，若到截至日期已经完成接单，则返回true,//若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
    //若有部分人接收，进入任务强分配
    function _endTransAccept( uint256 _index) internal returns(bool){
      LibProject.TranslationPro memory _pro = service.getProject(_index);
      LibProject.Tasker[] memory _transList =  _pro.translators;
       LibProject.TaskInfo[] memory _tasks = _pro.tasks;
      if(service.isFull(_index,true)){
          return true;
      }else if(_transList.length == 0) {
          //service.updateState(_index,LibProject.ProjectState.NoOnePick);
          service.closeTransAccept(_index);
          return false;
      }else {
          uint256 _count = _pro.tasks.length;
          uint256 _acceptedNum = _transList.length;
          uint256 avgNum = _count/_acceptedNum;
          for(uint256 i =0;i<_tasks.length;i++) {
              //任务为待接收状态
              if(_tasks[i].state == LibProject.FileState.Waiting){
                  //为未分配任务分配任务者
                  for(uint256 q=0;q<_transList.length;q++){
                      //超出分配线，不予分配
                  if(_transList[q].taskIndex.length>avgNum){
                      continue;
                  }
                  //将当前任务分配给翻译者
                  service.acceptTrans(_index,i,q);
                  break;
              }
            }      
          }
          service.closeTransAccept(_index);
          return false;
      }
    }
    //
     function _endTransVf( uint256 _index) internal returns(bool){
      LibProject.TranslationPro memory _pro = service.getProject(_index);
      LibProject.Tasker[] memory _vfList =  _pro.verifiers;
       LibProject.TaskInfo[] memory _tasks = _pro.tasks;
      if(service.isFull(_index,false)){
          return true;
      }else if(_vfList.length == 0) {
           //若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
          service.updateState(_index,LibProject.ProjectState.NoOnePick);
          service.closeVfAccept(_index);
          return false;
      }else {
          //若有部分人接收
          uint256 _count = _pro.tasks.length;
          uint256 _acceptedNum = _vfList.length;
          uint256 avgNum = _count/_acceptedNum;
          for(uint256 i =0;i<_tasks.length;i++) {
              //任务为待接收状态
              if(_tasks[i].state == LibProject.FileState.Waiting){
                  //为未分配任务分配任务者
                  for(uint256 q=0;q<_vfList.length;q++){
                      //超出分配线，不予分配
                  if(_vfList[q].taskIndex.length>avgNum){
                      continue;
                  }
                  //将当前任务分配给翻译者
                  service.acceptTrans(_index,i,q);
                  break;
              }
            }      
          }
          service.closeVfAccept(_index);
          return false;
      }
    }
    //提交任务-翻译者
    function _sumbitTaskTrans(uint256 _index,uint256 _taskerIndex, uint256 _fileIndex,string memory _file) internal {
        //修改文件的状态和最新加载时间
        service.updateFileStateAndTime(_index,_taskerIndex,LibProject.FileState.Validating);
        //上传文件
        service.updateFileInfo(_index,_taskerIndex,_fileIndex,_file,true);
        //修改任务者状态
        service.updateTaskerState(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Submitted,true);
    }
   //提交任务-校验者
    function _sumbitTaskVf(uint256 _index,uint256 _taskerIndex, uint256 _fileIndex,string memory _file) internal {
        //修改文件的状态和最新加载时间
        service.updateFileStateAndTime(_index,_taskerIndex,LibProject.FileState.BuyerReview);
        //上传文件
        service.updateFileInfo(_index,_taskerIndex,_fileIndex,_file,false);
        //修改任务者状态
        service.updateTaskerState(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Submitted,false);
    }
    //超时未提交-翻译者
    function _overTimeTrans(uint256 _index, uint256 _taskerIndex)internal returns(bool) {
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted,_money) = service.overTimeTasker(_index,_taskerIndex,true);
        if(_unCompleted.length ==0) {
            return false;
        }
        //修改任务状态
        for(uint256 i=0;i<_unCompleted.length;i++){
             service.updateTaskerState(_index,_taskerIndex,i,LibProject.TaskerState.Overtime,true);
        }  
        //计算罚金
        //1.根据赏金获得处罚比率
      uint256 _rate=  CalculateUtils.punishRatio(service.getTranslators(_index,_taskerIndex).bounty);
      uint256 _punish = CalculateUtils.getPunish(_money,_rate);
        //将罚金转给发布者-待完成
        return true;
    }
      //超时未提交-校验者
    function _overTimeVf(uint256 _index, uint256 _taskerIndex)internal returns(bool) {
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted,_money) = service.overTimeTasker(_index,_taskerIndex,false);
        if(_unCompleted.length ==0) {
            return false;
        }
        //修改任务状态
        for(uint256 i=0;i<_unCompleted.length;i++){
             service.updateTaskerState(_index,_taskerIndex,i,LibProject.TaskerState.Overtime,false);
        }
       
        //计算罚金
        //1.根据赏金获得处罚比率
      uint256 _rate=  CalculateUtils.punishRatio(service.getVerifiers(_index,_taskerIndex).bounty);
      uint256 _punish = CalculateUtils.getPunish(_money,_rate);
        //将罚金转给发布者-待完成
        return true;
    }
    //校验者验收
     function _validate(uint256 _index,uint256 _transIndex,uint256 _vfIndex,uint256 _fileIndex, bool _isPass,string memory _file) internal {
         //若校验通过，将任务者的状态修改为已完成
         if(_isPass) {
             service.updateTaskerState(_index,_transIndex,_fileIndex,LibProject.TaskerState.Completed,true);
             _sumbitTaskVf(_index,_vfIndex,_fileIndex,_file);
             //若用户为自定义支付，则完成后支付任务者赏金
         }else{
             //任务不通过，将任务者的状态修改为被打回状态 
             service.updateTaskerState(_index,_vfIndex,_fileIndex,LibProject.TaskerState.Return,true);
             //文件状态修改为等待翻译者修改
              service.updateFileStateAndTime(_index,_fileIndex,LibProject.FileState.WaitTransModify);
         }
         
     }
      //扣除赏金
     function _deduct(uint256 _index, uint256 _taskerIndex,uint256 _fileIndex,uint256 _deduct, bool _isTrans) internal  {
         uint256 _bounty = service.getProjectOne(_index).tasks[_fileIndex].bounty;
         uint256 _deductMoney ;
         if(_isTrans) {
           _deductMoney =  CalculateUtils.getDeductMoney( CalculateUtils.getTaskTrans(_bounty),_deduct);
         }else {
           _deductMoney =  CalculateUtils.getDeductMoney( CalculateUtils.getTaskVf(_bounty),_deduct); 
         }
         service.deductBounty(_index,_taskerIndex,_deductMoney,_isTrans);
     }
    //发布者验收
    function _receiveProject(uint256 _index,uint256 _taskerIndex,uint256 _fileIndex, bool _isPass) internal {
         //若校验通过，将任务者的状态修改为已完成
         if(_isPass) {
             service.updateTaskerState(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Completed,false);
             service.updateFileStateAndTime(_index,_fileIndex,LibProject.FileState.Accepted);
             //若用户为自定义支付，则完成后支付校验者赏金，若为非自定义支付，则支付翻译者与校验者赏金
         }else{
             //任务不通过，将任务者的状态修改为被打回状态
             service.updateTaskerState(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Return,false);
              service.updateFileStateAndTime(_index,_fileIndex,LibProject.FileState.WaitVfModify);
         }
         
     }
}