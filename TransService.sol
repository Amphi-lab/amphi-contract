// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./utils/calculateUtils.sol";


contract TransService {
    mapping (uint256 => LibProject.TranslationPro) private taskList;
    uint256 private count;
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
    }
    //批量修改任务状态
    function updateTaskerState(uint256 _index,address  _taskerAddress,uint256[] memory _fileIndex,LibProject.TaskerState _state, bool _isTrans) public {
        if(_isTrans){
            //  _tasker=taskList[_index].transInfo[_taskerAddress];
        for(uint256 i=0;i<_fileIndex.length;i++) {
            taskList[_index].transInfo[_taskerAddress].info[_fileIndex[i]].state = _state;
         
        }
        }else{
        for(uint256 i=0;i<_fileIndex.length;i++) {
            taskList[_index].vfInfo[_taskerAddress].info[_fileIndex[i]].state = _state;
        }
        }
    }
    function returnTasker(uint256 _index,address _taskerIndex,uint256 _fileIndex,bool _isTrans)public {
        //修改任务者状态&修改文件状态
        if(_isTrans) {
            taskList[_index].transInfo[_taskerIndex].info[_fileIndex].state=LibProject.TaskerState.Return;
            taskList[_index].tasks[_fileIndex].state = LibProject.FileState.WaitTransModify;
        }else {
            taskList[_index].vfInfo[_taskerIndex].info[_fileIndex].state=LibProject.TaskerState.Return;
            taskList[_index].tasks[_fileIndex].state = LibProject.FileState.WaitVfModify;
        }
    }
    function onNoOnePink(uint256 _index) public {
        taskList[_index].state = LibProject.ProjectState.NoOnePick;
         taskList[_index].isVerActive = false;
    }
    function closeTransAccept(uint256 _index) public {
        taskList[_index].isTransActive = false;
    }
    function getTaskBounty(uint256 _index,uint256 _fileIndex) public view returns(uint256) {
        return taskList[_index].tasks[_fileIndex].bounty;
    }
    function getTaskBounty(uint256 _index) public view returns(uint256) {
        return taskList[_index].bounty;
    }
    function closeVfAccept( uint256 _index) public {
        taskList[_index].isVerActive = false;
        // emit uploadAcceptStateEv(msg.sender, _index,"vf",false);
    }
    //翻译者提交任务
    function sumbitTransTask(uint256 _index,address _taskerIndex, uint256 _fileIndex,string memory _file) public {
         LibProject.TranslationPro storage _pro= taskList[_index];
         _pro.tasks[_fileIndex].state = LibProject.FileState.Validating;
        _pro.tasks[_fileIndex].lastUpload = block.timestamp;
        _pro.transInfo[_taskerIndex].info[_fileIndex].file = _file;
        _pro.transInfo[_taskerIndex].info[_fileIndex].state= LibProject.TaskerState.Submitted;
    }
    //校验者验收&提交任务
    function sumbitVfTask(uint256 _index,address _transIndex,address _vfIndex, uint256 _fileIndex,string memory _file) public {
        
         LibProject.TranslationPro storage _pro= taskList[_index];
         _pro.transInfo[_transIndex].info[_fileIndex].state =LibProject.TaskerState.Completed;
         //校验者提交任务
         _pro.tasks[_fileIndex].state = LibProject.FileState.BuyerReview;
        _pro.tasks[_fileIndex].lastUpload = block.timestamp;
        _pro.vfInfo[_vfIndex].info[_fileIndex].file = _file;
        _pro.vfInfo[_vfIndex].info[_fileIndex].state = LibProject.TaskerState.Submitted;
    }
    //翻译者接收任务
    function acceptTrans(uint256 _index,uint256[] memory _fileIndex, address _taskerIndex) public{
       //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
       LibProject.Tasker storage _taskerInfo = taskList[_index].transInfo[_taskerIndex];
       if(_taskerInfo.taskIndex.length==0) {
           taskList[_index].translators.push(_taskerIndex);
        }
        //若任务为自定义支付，则计算任务赏金并记录
           if(isCustomizeState(_index)) {
               uint256 _taskBountyInitial;
               for(uint256 q=0;q<_fileIndex.length;q++) {
               taskList[_index].tasks[_fileIndex[q]].state= LibProject.FileState.Translating;
               _taskBountyInitial = taskList[_index].tasks[_fileIndex[q]].bounty;
               _taskerInfo.info[_fileIndex[q]].bounty = CalculateUtils.getTaskTrans(_taskBountyInitial);
               _taskerInfo.taskIndex.push(_fileIndex[q]);
           }
           }else {
               for(uint256 i=0;i<_fileIndex.length;i++) {
               _taskerInfo.taskIndex.push(_fileIndex[i]);
               taskList[_index].tasks[_fileIndex[i]].state= LibProject.FileState.Translating;

           }
           }
        //    //文件状态修改为翻译中
       taskList[_index].numberT++;
       if(isFull(_index,true)) {
          taskList[_index].isTransActive = false;
       }
    }
     //校验者接收任务
    function acceptVf(uint256 _index,uint256[] memory _fileIndex, address _taskerIndex) public {
       //若长度为0，说明该任务者是首次接收该任务,将翻译者存入到翻译者名单中
       LibProject.Tasker storage _taskerInfo = taskList[_index].vfInfo[_taskerIndex];
       if(_taskerInfo.taskIndex.length==0) {
           taskList[_index].verifiers.push(_taskerIndex);
        }
        //若任务为自定义支付，则计算任务赏金并记录
           if(isCustomizeState(_index)) {
               uint256 _taskBountyInitial;
               for(uint256 q=0;q<_fileIndex.length;q++) {
               taskList[_index].tasks[_fileIndex[q]].state= LibProject.FileState.Translating;
               _taskBountyInitial = taskList[_index].tasks[_fileIndex[q]].bounty;
               _taskerInfo.info[_fileIndex[q]].bounty = CalculateUtils.getTaskTrans(_taskBountyInitial);
               _taskerInfo.taskIndex.push(_fileIndex[q]);
           }
           }else {
               for(uint256 i=0;i<_fileIndex.length;i++) {
               _taskerInfo.taskIndex.push(_fileIndex[i]);
               taskList[_index].tasks[_fileIndex[i]].state= LibProject.FileState.Translating;

           }
           }
        //    //文件状态修改为翻译中
       taskList[_index].numberV++;
       if(isFull(_index,false)) {
          taskList[_index].isVerActive = false;
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
        if(isCustomizeState(_index)) {
            uint256 _taskBountyInitial = taskList[_index].tasks[_fileIndex].bounty;
            _taskerInfo.bounty = CalculateUtils.getTaskTrans(_taskBountyInitial);
        }
    }
    //扣除罚金
    function deductBounty(uint256 _index,address _taskerIndex,uint256 _fileIndex,uint256 _money,bool _isTrans) public  {
        if(_isTrans){
            taskList[_index].transInfo[_taskerIndex].info[_fileIndex].bounty-= _money;
        }else{
            taskList[_index].vfInfo[_taskerIndex].info[_fileIndex].bounty-= _money;
        }
        // emit deductBountyEv(_index,_taskerIndex,_money,msg.sender);
    }
    //判断任务是否已满
    function isFull(uint256 _index, bool _isTrans) public view returns(bool) {
       if(_isTrans){
          return taskList[_index].maxT <= taskList[_index].numberT;
       }else{
          return taskList[_index].maxV <= taskList[_index].numberV;
       }
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
                _fileInfo.bounty = taskList[_index].transInfo[_taskerAddress].info[_fileInfo.taskIndex].bounty;
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
                _fileInfo.bounty = taskList[_index].vfInfo[_taskerAddress].info[_fileInfo.taskIndex].bounty;
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
        taskList[_index].tasks[_fileIndex].state= LibProject.FileState.Accepted;
    }
    function getSubTaskBounty(uint256 _index,address _tasker,uint256 _fileIndex,bool _isTrans) public view returns(uint256){
        if(_isTrans) {
           return taskList[_index].transInfo[_tasker].info[_fileIndex].bounty;
        }else {
            return taskList[_index].vfInfo[_tasker].info[_fileIndex].bounty;
        }
    }
    function getBuyer(uint256 _index) public view returns(address) {
        return taskList[_index].buyer;
    }
    function getTaskState(uint256 _index) public view returns(LibProject.ProjectState) {
        return taskList[_index].state;
    }
    function getTaskStateVf(uint256 _index) public view returns(bool) {
        return taskList[_index].isVerActive;
    }
    function getTaskStateTrans(uint256 _index) public view returns(bool) {
        return taskList[_index].isTransActive;
    }
}