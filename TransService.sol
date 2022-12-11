// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./utils/calculateUtils.sol";
error OperationException(string,uint256);
error ParameterException(string);
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
contract TransService {
    event addProjectEv(address,uint256,LibProject.ProParm);
    event updateProjectEv(uint256,LibProject.ProParm);
    event updateProSateEv(uint256,LibProject.ProjectState);
    event uploadAcceptStateEv(address,uint256,string,bool);
    event acceptTaskEv(uint256,uint256[],uint256,address,string);
    event acceptTaskEv(uint256,uint256,uint256,address,string);
    event updateFileStateAndTimeEv(uint256,uint256,address,LibProject.FileState);
    event updateTaskerStateEv(uint256,uint256,uint256,address,LibProject.TaskerState,bool);
    event updateFileInfoEv(uint256,uint256,uint256,address,string,bool);

    mapping (uint256 => LibProject.TranslationPro) private taskList;
    modifier isCanAcceptTrans(uint256 _index) {
        if(taskList[_index].isTransActive == false || isFull(_index,true)== true){
            revert OperationException("OperationException: Can't receive task",_index);
        }
        _;
    }
    modifier isCanAcceptVf(uint256 _index) {
        if(taskList[_index].isVerActive == true || isFull(_index,false)== false){
            revert OperationException("OperationException: Can't receive task",_index);
        }
        _;
    }
    modifier onlyBuyer(uint256 _index) {
        require(getProjectOne(_index).buyer == msg.sender,"Only buyer can call this.");
        _;
    }
     modifier isExist(uint256 _index){
        if(_index>getCount()){
            revert ParameterException("Wrong index value!");
        }
        _;
    }
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
        _pro.maxT = _t.maxT;
        _pro.maxV = _t.maxV;
        _pro.isTransActive = true;
        _pro.isVerActive = true;
        _pro.state = LibProject.ProjectState.Published;
        for(uint256 i=0;i< _t.tasks.length;i++) {
            _pro.tasks.push(_t.tasks[i]);
        }
        emit addProjectEv(msg.sender,count,_t);
        return count;
    }
        function updateProject(uint256 _index,LibProject.ProParm memory _t)  public onlyBuyer(_index){
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
        _pro.maxT = _t.maxT;
        _pro.maxV = _t.maxV;
        _pro.isTransActive = true;
        _pro.state = LibProject.ProjectState.Published;
        for(uint256 i=0;i< _t.tasks.length;i++) {
            _pro.tasks.push(_t.tasks[i]);
        }
        emit updateProjectEv(_index,_t);
    }
    //修改项目状态
    function updateState(uint256 _index, LibProject.ProjectState _state) public {
        taskList[_index].state = _state;
        emit updateProSateEv(_index,_state);
    }
    //修改文件状态
    function updateFileStateAndTime(uint256 _index,uint256 _fileIndex,LibProject.FileState _state) public {
        LibProject.TaskInfo storage _task= taskList[_index].tasks[_fileIndex];
        _task.state = _state;
        _task.lastUpload = block.timestamp;
        emit updateFileStateAndTimeEv(_index,_fileIndex,msg.sender,_state);
    }
    //修改任务者状态
    function updateTaskerState(uint256 _index,uint256 _taskerIndex,uint256 _stateIndex,LibProject.TaskerState _state, bool _isTrans) public {
        if(_isTrans){
            taskList[_index].translators[_taskerIndex].states[_stateIndex] = _state;
        }else{
           taskList[_index].verifiers[_taskerIndex].states[_stateIndex] = _state;
        }

       emit updateTaskerStateEv(_index,_taskerIndex,_stateIndex,msg.sender,_state,_isTrans);
    }
    //修改/上传任务文件
    function updateFileInfo(uint256 _index,uint256 _taskerIndex,uint256 _fileIndex,string memory _fileInfo,bool _isTrans) public {
        if(_isTrans){
           taskList[_index].translators[_taskerIndex].files[_fileIndex] = _fileInfo;
        }else{
            taskList[_index].verifiers[_taskerIndex].files[_fileIndex] = _fileInfo;
        }
        emit updateFileInfoEv(_index,_taskerIndex,_fileIndex,msg.sender,_fileInfo,_isTrans);
    }
    function closeTransAccept(uint256 _index) public {
        taskList[_index].isTransActive = false;
        emit uploadAcceptStateEv(msg.sender, _index,"ts",false);
    }
    function closeVfAccept( uint256 _index) public {
        taskList[_index].isVerActive = false;
         emit uploadAcceptStateEv(msg.sender, _index,"vf",false);
    }
    function openTransAccept( uint256 _index) public {
        taskList[_index].isTransActive = true;
         emit uploadAcceptStateEv(msg.sender, _index,"ts",true);
    }
    function openVfAccept( uint256 _index) public {
        taskList[_index].isVerActive = true;
         emit uploadAcceptStateEv(msg.sender, _index,"ts",true);
    }
    //查询指定项目翻译者名单
    // function getTranslators(address _buyer,uint256 _index) public returns(LibProject.Tasker[] memory) {
    //     return taskList[_buyer][_index].translators;
    // }
    // //查询指定项目校验者名单
    // function getVerifiers(address _buyer,uint256 _index) public returns(LibProject.Tasker[] memory) {
    //     return taskList[_buyer][_index].translators;
    // }
    //翻译者接收任务
    function acceptTrans(uint256 _index,uint256[] memory _fileIndex, uint256 _taskerIndex,address _tasker) public isCanAcceptTrans(_index) {
       //计算赏金
       uint256 _bounty;
       //若_taskerIndex为0，说明该任务者是首次接收该任务
       if(_taskerIndex==0) {
            LibProject.Tasker[] storage _taskerList= taskList[_index].translators;
           LibProject.Tasker memory _taskerInfo; 
           _taskerInfo.taskerAddress = _tasker;
           _taskerInfo.taskIndex = _fileIndex;
           _taskerList.push(_taskerInfo);
           emit acceptTaskEv(_index,_fileIndex,_taskerList.length-1,_tasker,"translator");
       }else{
           LibProject.Tasker storage _taskerInfo = taskList[_index].translators[_taskerIndex];
           for(uint256 i=0;i<_fileIndex.length;i++) {
               _taskerInfo.taskIndex.push(_fileIndex[i]);
           }
           emit acceptTaskEv(_index,_fileIndex,_taskerIndex,_tasker,"translators");
       }
       if(isFull(_index,true)) {
           closeTransAccept(_index);
       }
    }
    function acceptTrans(uint256 _index,uint256  _fileIndex, uint256 _taskerIndex,address _tasker) public  isCanAcceptTrans(_index){
           LibProject.Tasker storage _taskerInfo = taskList[_index].translators[_taskerIndex];
               _taskerInfo.taskIndex.push(_fileIndex);
           emit acceptTaskEv(_index,_fileIndex,_taskerIndex,_tasker,"translators");
    }
     //校验者接收任务
    function acceptVf(uint256 _index,uint256[] memory _fileIndex, uint256 _taskerIndex,address _tasker) public isCanAcceptVf(_index) {
       if(_taskerIndex==0) {
            LibProject.Tasker[] storage _taskerList= taskList[_index].verifiers;
           LibProject.Tasker memory _taskerInfo; 
           _taskerInfo.taskerAddress = _tasker;
           _taskerInfo.taskIndex = _fileIndex;
           _taskerList.push(_taskerInfo);
           emit acceptTaskEv(_index,_fileIndex,_taskerList.length-1,_tasker,"verifiers");
       }else{
           LibProject.Tasker storage _taskerInfo = taskList[_index].verifiers[_taskerIndex];
           for(uint256 i=0;i<_fileIndex.length;i++) {
               _taskerInfo.taskIndex.push(_fileIndex[i]);
           }
           emit acceptTaskEv(_index,_fileIndex,_taskerIndex,_tasker,"verifiers");
       }
       if(isFull(_index,false)) {
           closeTransAccept(_index);
       }
    }
    function acceptVf(uint256 _index,uint256  _fileIndex, uint256 _taskerIndex,address _tasker) public  isCanAcceptVf(_index) {
           LibProject.Tasker storage _taskerInfo = taskList[_index].verifiers[_taskerIndex];
               _taskerInfo.taskIndex.push(_fileIndex);
           emit acceptTaskEv(_index,_fileIndex,_taskerIndex,_tasker,"verifiers");
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
    //查询任务者超时未完成任务数
    function overTimeTasker(uint256 _index, uint256 _taskerIndex, bool _isTrans) public view returns(uint256) {
        LibProject.TaskerState[] memory _states;
        if(_isTrans) {
            _states  = getProject(_index).translators[_taskerIndex].states; 
        }else {
            _states  = getProject(_index).verifiers[_taskerIndex].states; 
        }
        uint256 _count;
        for(uint256 i=0;i<_states.length;i++) {
            if(_states[i]<LibProject.TaskerState.Submitted) {
                _count++;
            }
        }
        return _count;
    }
    
}