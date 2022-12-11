// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./TransService.sol";
contract TransImpl{
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
    function sumbitTask(uint256 _index,uint256 _taskIndex, uint256 _fileIndex) public {

    }
    //发布任务
     function _postProject(LibProject.ProParm memory _t) internal returns(uint256) {
         uint256 _index;
        // 若用户为非自定义，则默认一人接单
         if(!(_t.isCustomize)) {
             _t.maxT =1;
             _t.maxV =1;
         }else{
             _t.maxT = _t.tasks.length; 
             _t.maxV=service.getMatNumber(_t.maxT );
         }
        // _t.buyer = msg.sender;
       _index = service.addProject( _t);
       return _index;
    }
    //修改任务
    function _updateProject(uint256 _index,LibProject.ProParm memory _t) internal {
        if(!(_t.isCustomize)) {
             _t.maxT =1;
             _t.maxV =1;
         }else{
             _t.maxT = _t.tasks.length; 
             _t.maxV=service.getMatNumber(_t.maxT );
         }
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
          service.updateState(_index,LibProject.ProjectState.NoOnePick);
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
                  service.acceptTrans(_index,i,q,_transList[q].taskerAddress);
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
                  service.acceptTrans(_index,i,q,_vfList[q].taskerAddress);
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
        service.updateFileStateAndTime(_index,_taskerIndex,LibProject.FileState.WaitModify);
        //上传文件
        service.updateFileInfo(_index,_taskerIndex,_fileIndex,_file,false);
        //修改任务者状态
        service.updateTaskerState(_index,_taskerIndex,_fileIndex,LibProject.TaskerState.Submitted,false);
    }
    //超时未提交-翻译者
    function _overTimeTrans(uint256 _index, uint256 _taskerIndex)internal returns(bool) {
        //查询超时任务数
        uint256 _unCompleted = service.overTimeTasker(_index,_taskerIndex,true);
        if(_unCompleted ==0) {
            return false;
        }
        //计算罚金
        /**
        1.根据赏金获得处罚比率
        */
        //将罚金转给发布者
    }
    //超时未提交-校验者
    //打回
    //扣除赏金
    //发布者验收
    
}