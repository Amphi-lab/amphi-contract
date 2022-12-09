// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./TransService.sol";
contract TransImpl{
    TransService service;
    constructor(address _serAddress) {
       service = TransService(_serAddress);
    }
    function postProject(LibProject.TranslationPro memory _t) public returns(uint256){
        return _postProject(_t);
    }
     
    //发布任务
     function _postProject(LibProject.TranslationPro memory _t) internal returns(uint256) {
         uint256 _index;
        // 若用户为非自定义，则默认一人接单
         if(!(_t.isCustomize)) {
             _t.maxT =1;
             _t.maxV =1;
         }else{
             _t.maxT = _t.tasks.length; 
             _t.maxV=service.getMatNumber(_t.maxT );
         }
       _index = service.posProject(msg.sender,_t);
       return _index;
    }
    //
    function endTransAccept(address _buyer, uint256 _index) public {
        _endTransAccept(_buyer, _index);
    }
    //待修改
    function _endTransAccept(address _buyer, uint256 _index) internal {
      LibProject.TranslationPro memory _pro = service.getProject(_buyer,_index);
      LibProject.Tasker[] memory _transList =  service.getProject(_buyer,_index).translators;
      if(_transList.length == 0) {
          service.updateState(_buyer,_index,LibProject.ProjectState.NoOnePick);
          service.closeTransAccept(_buyer,_index);
      }else {
          uint256 _count = _pro.tasks.length;
          uint256 _acceptedNum = _transList.length;
          uint256 avgNum = _count/_acceptedNum;
          for(uint256 i =0;i<_pro.tasks.length;i++) {
              for(uint256 q=0;q<_transList.length;q++){
                  if(_transList[q].taskIndex.length>=avgNum){
                      continue;
                  }
                  if(_pro.tasks[i].state == LibProject.FileState.Waiting) {
                    //  _transList[q].taskIndex.push();
                  }
              }
              
          }
          //强分配1.获取待分配任务单 2. 获得报名名单
          //总任务数/任务名单=平均每个人要分配的人数
      }
    }
     
   
}