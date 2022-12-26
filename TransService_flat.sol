
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
    function addPay(address _tasker,uint256 _money) public {
        payList[_tasker] += _money;
    }
    function deductPay(address _tasker, uint256 _money) public {
        payList[_tasker]-= _money;
    }
    function getPay(address _tasker) public view returns(uint256) {
        return payList[_tasker];
    }
    //增加项目
    function addProject(LibProject.ProParm memory _t)  public returns(uint256) {
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
            _pro.tasks.push(_t.tasks[i]);
        }
        return count;
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
    function updateState(uint256 _index, LibProject.ProjectState _state) public {
        taskList[_index].state = _state;
        emit changeProjectStateEv(_index,_state,msg.sender);
    }
    //批量修改任务状态
    function updateTaskerState(uint256 _index,address  _taskerAddress,uint256[] memory _fileIndex,LibProject.TaskerState _state, bool _isTrans) public {
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
    function returnTasker(uint256 _index,address _taskerIndex,uint256 _fileIndex,bool _isTrans)public {
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
    function onNoOnePink(uint256 _index) public {
        taskList[_index].state = LibProject.ProjectState.NoOnePick;
        emit changeProjectStateEv(_index,LibProject.ProjectState.NoOnePick,msg.sender);
        taskList[_index].isVerActive = false;
        emit changeTransActive(_index,false,msg.sender);
    }
    function closeTransAccept(uint256 _index) public {
        taskList[_index].isTransActive = false;
        emit changeTransActive(_index,false,msg.sender);
    }
    function closeFileState(uint256 _index,uint256 _fileIndex) public {
        taskList[_index].tasks[_fileIndex].state = LibProject.FileState.Closed;
        emit changeFileStateEv(_index,_fileIndex,LibProject.FileState.Closed,msg.sender);
    }
    function getTaskBounty(uint256 _index,uint256 _fileIndex) public view returns(uint256) {
        return taskList[_index].tasks[_fileIndex].bounty;
    }
    function getTaskBounty(uint256 _index) public view returns(uint256) {
        return taskList[_index].bounty;
    }
    function closeVfAccept( uint256 _index) public {
        taskList[_index].isVerActive = false;
        emit changeVerActive(_index,false,msg.sender);
    }
    //翻译者提交任务
    function sumbitTransTask(uint256 _index,address _taskerIndex, uint256 _fileIndex,string memory _file) public {
         LibProject.TranslationPro storage _pro= taskList[_index];
        _pro.tasks[_fileIndex].state = LibProject.FileState.Validating;
        emit changeFileStateEv(_index,_fileIndex,LibProject.FileState.Validating,msg.sender);
        _pro.tasks[_fileIndex].lastUpload = block.timestamp;
        _pro.transInfo[_taskerIndex].info[_fileIndex].file = _file;
        _pro.transInfo[_taskerIndex].info[_fileIndex].state= LibProject.TaskerState.Submitted;
        emit changeTaskerStateEv(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Submitted,true,msg.sender);
    }
    //校验者验收&提交任务
    function sumbitVfTask(uint256 _index,address _transIndex,address _vfIndex, uint256 _fileIndex,string memory _file) public {
        
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
    function acceptTrans(uint256 _index,uint256[] memory _fileIndex, address _taskerIndex) public{
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
    function acceptVf(uint256 _index,uint256[] memory _fileIndex, address _taskerIndex) public {
       //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
       LibProject.Tasker storage _taskerInfo = taskList[_index].vfInfo[_taskerIndex];
       if(_taskerInfo.taskIndex.length==0) {
           taskList[_index].verifiers.push(_taskerIndex);
        }
        LibProject.FileState _state;
        for(uint256 i=0;i<_fileIndex.length;i++) {
            _state =taskList[_index].tasks[_fileIndex[1]].state;
            //根据目前文件状态，修改文件状态
            if(_state== LibProject.FileState.Waiting) {
                taskList[_index].tasks[_fileIndex[i]].state = LibProject.FileState.WaitingForTrans;
                emit changeFileStateEv(_index,_fileIndex[i],LibProject.FileState.WaitingForTrans,msg.sender);
            }else if(_state == LibProject.FileState.WaitingForVf) {
                taskList[_index].tasks[_fileIndex[i]].state= LibProject.FileState.Translating;
                emit changeFileStateEv(_index,_fileIndex[i],LibProject.FileState.Translating,msg.sender);
            }else{
                revert FileException("Error file state",_state);
            }
             _taskerInfo.taskIndex.push(_fileIndex[i]);
        }
       //文件状态修改为翻译中
       taskList[_index].numberV++;
       if(isFull(_index,false)) {
          taskList[_index].isVerActive = false;
          emit changeVerActive(_index,false,msg.sender);
       }
    }
    function accept(uint256 _index,uint256  _fileIndex, address _taskerIndex, bool _isTrans) public  {
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
    function closeTask(uint256 _index) public {
        taskList[_index].state = LibProject.ProjectState.Closed;
        emit changeProjectStateEv(_index,LibProject.ProjectState.Closed,msg.sender);
    }
    function completedTask(uint256 _index) public {
        taskList[_index].state = LibProject.ProjectState.Completed;
         emit changeProjectStateEv(_index,LibProject.ProjectState.Completed,msg.sender);
    }
    function getProjectOne(uint256 _index) public view returns(LibProject.ReturnTask memory) {
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
            if(_info.state < LibProject.TaskerState.Submitted){
                _list[q] = _filesIndex[i];
                q++;
                money+= taskList[_index].tasks[_filesIndex[i]].bounty;
            }
        }   
        return (_list,money);
    }
    function receivePass(uint256 _index, address _taskerIndex,uint256 _fileIndex) public {
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