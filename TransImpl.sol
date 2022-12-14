// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./TransService.sol";
import "./utils/calculateUtils.sol";
import "./contracts/access/Ownable.sol";
import "./TransferService.sol";
contract TransImpl is Ownable{
    event postProjectEv(address,uint256,LibProject.ProParm);
   // event updateProjectEv(uint256,LibProject.ProParm);
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
        // if(_index>service.getCount()){
        //     revert ParameterException("Wrong index value!");
        // }
        _;
    }
    TransService service;
    address immutable i_transfer;
   // TransferService transferService;
    constructor(address _serAddress,address _transferAddress) {
       service = TransService(_serAddress);
       i_transfer = _transferAddress;
       //transferService = TransferService(_transferService);
    }
    
    function postProject(LibProject.ProParm memory _t) public payable returns(uint256 _index) {
       _index =  _postProject(_t);
         if (_t.isCustomize){
           //如果用户为自定义付款，用户需先将赏金存入到合约中,
          TransferService(i_transfer).transderToContract{value:msg.value}();
       }
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
      uint256 bounty =  _validate(_index,_transIndex,_vfIndex,_fileIndex,_isPass,_file);
       //发赏金
      if(bounty>0) {
         bounty = CalculateUtils.getTaskTrans(bounty);
         address _taskerAddress = service.getProjectOne(_index).translators[_transIndex].taskerAddress;
          TransferService(i_transfer).toTaskerBounty(_taskerAddress,bounty);
      }
    }
    function sumbitTaskTrans(uint256 _index,uint256 _taskerIndex, uint256 _fileIndex,string memory _file) public {
        _sumbitTaskTrans(_index,_taskerIndex,_fileIndex,_file);
    }
    function overTimeTrans(uint256 _index, uint256 _taskerIndex)public returns(uint256){
      return  _overTimeTrans(_index,_taskerIndex);
    }
     function overTimeVf(uint256 _index, uint256 _taskerIndex)public returns(uint256) {
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
     uint256 _index = service.addProject( _t);
       
       emit postProjectEv(msg.sender,_index,_t);
       return _index;
    }
    //支付赏金-发布
    //function postPay(uint256 _index) 
    //修改任务
    function _updateProject(uint256 _index,LibProject.ProParm memory _t) internal {
         service.updateProject(_index,_t);
          if (_t.isCustomize){
           //如果用户为自定义付款，用户需先将赏金存入到合约中
          TransferService(i_transfer).transderToContract{value:msg.value}();
       }
       emit postProjectEv(msg.sender,_index,_t);
    }
    //到截至日期后，调用该方法，若到截至日期已经完成接单，则返回true,//若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
    //若有部分人接收，进入任务强分配
    function _endTransAccept( uint256 _index) internal returns(bool){
      LibProject.TranslationPro memory _pro = service.getProjectOne(_index);
      LibProject.Tasker[] memory _transList =  _pro.translators;
       LibProject.TaskInfo[] memory _tasks = _pro.tasks;
      if(service.isFull(_index,true)){
          return true;
          //若到翻译截至日期，仍无人接单，则关闭翻译接单状态
      }else if(_transList.length == 0) {
          //service.updateState(_index,LibProject.ProjectState.NoOnePick);
          service.closeTransAccept(_index);
           emit uploadAcceptStateEv(msg.sender, _index,"ts",false);
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
                 service.accept(_index,i,q,true);
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
      LibProject.TranslationPro memory _pro = service.getProjectOne(_index);
      LibProject.Tasker[] memory _vfList =  _pro.verifiers;
       LibProject.TaskInfo[] memory _tasks = _pro.tasks;
      if(service.isFull(_index,false)){
          return true;
      }else if(_vfList.length == 0 && _pro.translators.length ==0) {
           //若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
          service.onNoOnePink(_index);
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
                   service.accept(_index,i,q,false);
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
       service.sumbitTransTask(_index,_taskerIndex,_fileIndex,_file);
    }

    //超时未提交-翻译者
    function _overTimeTrans(uint256 _index, uint256 _taskerIndex)internal returns(uint256) {
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted,_money) = service.overTimeTasker(_index,_taskerIndex,true);
        if(_unCompleted.length ==0) {
            return 0;
        }
        //修改任务状态
        service.updateTaskerState(_index,_taskerIndex,_unCompleted,LibProject.TaskerState.Overtime,true);
        uint256 _allBounty;
        if(service.isCustomizeState(_index)){
            for(uint256 i=0;i<_unCompleted.length;i++) {
                _allBounty+=service.getProjectOne(_index).tasks[_unCompleted[i]].bounty;
            }
        }else{
            _allBounty =service.getProjectOne(_index).bounty;
        }
        //计算罚金 
    //   uint256 _rate=  CalculateUtils.punishRatio(service.getTranslators(_index,_taskerIndex).bounty);
       uint256 _rate=  CalculateUtils.punishRatio(CalculateUtils.getTaskTrans(_allBounty));  
      uint256 _punish = CalculateUtils.getPunish(_money,_rate);
        //返回罚金
        return _punish;
    }
      //超时未提交-校验者
    function _overTimeVf(uint256 _index, uint256 _taskerIndex)internal returns(uint256) {
        //查询超时任务数
        uint256[] memory _unCompleted;
        uint256 _money;
        (_unCompleted,_money) = service.overTimeTasker(_index,_taskerIndex,false);
        if(_unCompleted.length ==0) {
            return 0;
        }
        //修改任务状态
         service.updateTaskerState(_index,_taskerIndex,_unCompleted,LibProject.TaskerState.Overtime,false);   
        //计算罚金
        uint256 _allBounty;
        if(service.isCustomizeState(_index)){
            for(uint256 i=0;i<_unCompleted.length;i++) {
                _allBounty+=service.getProjectOne(_index).tasks[_unCompleted[i]].bounty;
            }
        }else{
            _allBounty =service.getProjectOne(_index).bounty;
        }
        //1.根据赏金获得处罚比率
        uint256 _rate=  CalculateUtils.punishRatio(CalculateUtils.getTaskVf(_allBounty));
        uint256 _punish = CalculateUtils.getPunish(_money,_rate);
        return _punish;
    }
    //校验者验收
     function _validate(uint256 _index,uint256 _transIndex,uint256 _vfIndex,uint256 _fileIndex, bool _isPass,string memory _file) internal returns(uint256) {
         //若校验通过，将任务者的状态修改为已完成
         if(_isPass) {
             //若用户为自定义支付，则完成后支付任务者赏金
             service.sumbitVfTask(_index,_transIndex,_vfIndex,_fileIndex,_file);
             bool _Customize=service.isCustomizeState(_index);
             if(_Customize) {
                return service.getTaskBounty(_index,_transIndex);
             }
         }else{
             //任务不通过，将任务者的状态修改为被打回状态 
             service.returnTasker(_index,_transIndex,_fileIndex,true);   
             return 0; 
         }
         
     }
      //扣除赏金
     function _deduct(uint256 _index, uint256 _taskerIndex,uint256 _fileIndex,uint256 _deductNumeber, bool _isTrans) internal  {
         uint256 _bounty = service.getProjectOne(_index).tasks[_fileIndex].bounty;
         uint256 _deductMoney ;
         if(_isTrans) {
           _deductMoney =  CalculateUtils.getDeductMoney( _bounty,_deductNumeber);
         }else {
           _deductMoney =  CalculateUtils.getDeductMoney( _bounty,_deductNumeber); 
         }
         service.deductBounty(_index,_taskerIndex,_fileIndex,_deductMoney,_isTrans);
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
             service.returnTasker(_index,_taskerIndex,_fileIndex,false);   
         }
         
     }
}