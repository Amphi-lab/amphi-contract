// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./TransService.sol";
contract TransImpl is TransService{
   // TransService service;
    constructor(address _serAddress) {
     //   service = TransService(_serAddress);
    }
    function postProject(LibProject.TranslationPro memory _t) public returns(uint256){
        return _postProject(_t);
    }
    // function acceptForTranslator(uint256 _id,uint256 _index) public {
    //     _acceptForTranslator(_id,_index);
    // }
    // function acceptForVerifer(uint256 _id, uint256 _index) public {
    //     _acceptForVerifer(_id, _index);
    // }
    // function modifyProject(LibProject.TranslationPro memory _t, uint256 _id) public {
    //     _modifyProject(_t, _id);
    // }
    // function splitTasksForVerifer(uint256 _id,SplitParam[] memory _parm) public {
    //     _splitTasksForVerifer(_id, _parm);
    // }
    // function splitTasksForTranslator(uint256 _id,SplitParam[] memory _parm) public {
    //     _splitTasksForTranslator( _id,_parm);
    // }
    //发布任务
     function _postProject(LibProject.TranslationPro memory _t) internal returns(uint256) {
         uint256 _index;
         //string memory LibProject.TranslationPro _pro;
         //若用户为非自定义，则默认一人接单
        //  if(!(_t.isCustomize)) {
        //      _t.maxT =1;
        //      _t.maxV =1;
        //  }else{
        //      _t.maxT = _t.tasks.length;
             
        //     // _t.maxV=service.getMatNumber(_t.maxT );
        //  }
        LibProject.TranslationPro storage _pro= taskList[msg.sender][_index];
       // LibProject.TranslationPro storage pro = _tranList[msg.sender];
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
        _pro.tasks = _t.tasks;
       
       // return _id;
    }

    // function _modifyProject(LibProject.TranslationPro memory _t, uint256 _id) onlyBuyer(_id) internal{
    //    // tranList[_id] = _t;
    // }
    
    // //翻译者接收任务,若接收任务人数已达到上限，则无法接收该任务-任务首次被接收
    //  function _acceptForTranslator(uint256 _id,uint256 _index) internal isExist(_id){
    //     LibProject.TranslationPro storage _pro = _tranList[_id];
    //     uint256 len = _pro.translators.length;
    //     if(len ==0 &&_index>0 || _index<0){
    //         revert ParameterException("The parameter input is wrong, please re-enter");
    //     }else if (len>_pro.maxT|| _index+1 > len){
    //         revert AcceptUpperLimit("The number of people has reached the upper limit");
    //     } 
    //     //翻译者接收子任务
    //     if(_index>0&&len>0){
    //         _pro.translators[_index].adTasker= msg.sender;
    //         _pro.translators[_index].state=LibProject.TaskerState.Registered;
    //     }else{
    //      LibProject.Taskers memory trans;
    //      trans.adTasker= msg.sender;
    //      trans.state=LibProject.TaskerState.Registered;
    //      _pro.translators.push(trans);
    //      }
    //  }
    //  //翻译者拆分任务
    //  function _splitTasksForTranslator(uint256 _id,SplitParam[] memory _parm) internal isExist(_id) {
    //      LibProject.TranslationPro storage _pro = _tranList[_id];
    //      if (_pro.translators[0].adTasker != msg.sender||_pro.translators.length==0){
    //          revert OperationException("Illegal operation!");
    //      }
    //      uint256 _len = _parm.length;
    //      _pro.maxT = _len;
    //      _pro.translators[0].money = _parm[0].bounsDes;
    //       _pro.translators[0].task = _parm[0].taskDes;
    //       LibProject.Taskers memory trans;
    //      for(uint256 i=1; i<_parm.length;i++) {
    //          trans.money = _parm[i].bounsDes;
    //          trans.task = _parm[i].taskDes;
    //          _pro.translators.push(trans);
    //      }
         
    //  }
    // //校验者接收任务
    //  function _acceptForVerifer(uint256 _id, uint256 _index) internal isExist(_id) {
    //     LibProject.TranslationPro storage _pro = _tranList[_id];
    //     uint256 len = _pro.vf.length;
    //     if(len ==0 &&_index>0 || _index<0){
    //         revert ParameterException("The parameter input is wrong, please re-enter");
    //     }else if (len>_pro.maxV|| _index+1 > len){
    //         revert AcceptUpperLimit("The number of people has reached the upper limit");
    //     } 
    //     //校验者接收子任务
    //     if(_index>0&&len>0){
    //         _pro.vf[_index].adTasker= msg.sender;
    //         _pro.vf[_index].state=LibProject.TaskerState.Registered;
    //     }else{
    //      LibProject.Taskers memory trans;
    //      trans.adTasker= msg.sender;
    //      trans.state=LibProject.TaskerState.Registered;
    //      _pro.vf.push(trans);
    //      }
    //  }
    //  //校验者拆分任务
    //  function _splitTasksForVerifer(uint256 _id,SplitParam[] memory _parm) internal isExist(_id) {
    //     LibProject.TranslationPro storage _pro = _tranList[_id];
    //      if (_pro.vf[0].adTasker != msg.sender||_pro.vf.length==0){
    //          revert OperationException("Illegal operation!");
    //      }
    //      uint256 _len = _parm.length;
    //      _pro.maxV = _len;
    //      _pro.vf[0].money = _parm[0].bounsDes;
    //       _pro.vf[0].task = _parm[0].taskDes;
    //       LibProject.Taskers memory trans;
    //      for(uint256 i=1; i<_parm.length;i++) {
    //          trans.money = _parm[i].bounsDes;
    //          trans.task = _parm[i].taskDes;
    //          _pro.vf.push(trans);
    //      }
    //  }
    //  //function timeOutForTranslator(uint256 _id, address _translator)
    //  function timeOutForTranslator(uint256 _id, uint256 _transId) internal {
    //     //   LibProject.TranslationPro memory _pro = tranList[_id];
    //     //   _pro.translators[_transId].state = LibProject.TaskerState.TimeOut;
    //  }
    //  //翻译者提交作品-修改翻译者状态，记录上传的文件
    //  function finishProject(uint256 _id, uint256 _tranId,string[] memory _files) internal isExist(_id) isLegalTransId(_id, _tranId){
    //       LibProject.Taskers storage _trans = _tranList[_id].translators[_tranId];
    //       if(msg.sender != _trans.adTasker){
    //         revert OperationException("Illegal operation!");
    //       }
    //       _trans.state = LibProject.TaskerState.Submitted;
    //       _trans.file = _files;
    //  }
    //   //校验者验证
    //   function validate(uint256 _id,uint256 _tranId,uint256 _vfId, bool _isPass, uint256 _deduct) internal isExist(_id) isLegalTransId(_id, _tranId) isLegalVf(_id,_vfId){
    //      LibProject.Taskers storage _trans = _tranList[_id].translators[_tranId];
    //      LibProject.Taskers storage _vf = _tranList[_id].vf[_vfId];
    //      if(msg.sender != _tranList[_id].vf[_vfId].adTasker){
    //          revert OperationException("Illegal operation!");
    //      }
    //      if(_isPass) {
    //          _trans.state = LibProject.TaskerState.Pass; 
    //      }else {
    //          _trans.state = LibProject.TaskerState.Fail;
    //          //**待优化
    //          _trans.money = _trans.money / _deduct;
    //      }
    //      _vf.state = LibProject.TaskerState.Completed;
    //  }
    //  //项目方验收
    // function receiveProject(uint256 _id,bool _isPass, uint256 _deduct) isExist(_id) onlyBuyer(_id) internal {
    //           LibProject.TranslationPro storage _pro = _tranList[0];
    //          // _pro.state
    //       }
    // function closeProject(uint256 _id) internal isExist(_id) onlyBuyer(_id){
    //     _tranList[_id].state= LibProject.ProjectState.Closed;
    // }
}