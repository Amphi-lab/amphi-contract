// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./TransService.sol";
import "./utils/calculateUtils.sol";
import "./contracts/access/Ownable.sol";
import "./TransferService.sol";
error OperationException(string,uint256);
error ParameterException(string);
contract TransImpl is Ownable,TransferService{
    event postProjectEv(address,uint256,LibProject.ProParm);
//    event updateProjectEv(uint256,LibProject.ProParm);
    // event updateProSateEv(uint256,LibProject.ProjectState);
    event uploadAcceptStateEv(address,uint256,string,bool);
    event acceptTaskEv(uint256,uint256[],uint256,address,string);
    event acceptTaskEv(uint256,uint256,address,bool);
    // event updateFileStateAndTimeEv(uint256,uint256,address,LibProject.FileState);
    // event updateTaskerStateEv(uint256,uint256,uint256,address,LibProject.TaskerState,bool);
    // event updateFileInfoEv(uint256,uint256,uint256,address,string,bool);
    // event deductBountyEv(uint256,uint256,uint256,address);

    modifier isCanAcceptTrans(uint256 _index) {
        if(!service.getTaskStateTrans(_index)){
            revert OperationException("OperationException: Can't receive task",_index);
        }
        _;
    }
    modifier isCanAcceptVf(uint256 _index) {
        if(!service.getTaskStateVf(_index)){
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
    
    function postProject(LibProject.ProParm memory _t) public payable  returns(uint256 _index) {
       _index =  _postProject(_t);
         if (_t.isCustomize){
             if(msg.value != _t.bounty *1e18) {
                  revert ParameterException("error : Incorrect value");
             }
          transderToContract();
       }
    }
    function updateProject(uint256 _index,LibProject.ProParm memory _t) public payable isExist(_index){
        _updateProject(_index, _t);
        if (_t.isCustomize){
            if(msg.value != _t.bounty *1e18) {
                  revert ParameterException("error : Incorrect value");
             }
          transderToContract();
       }
    }
    function endTransAccept(uint256 _index) public isExist(_index) {
        _endTransAccept( _index);
    }
     function endTransVf(uint256 _index) public isExist(_index) {
        _endTransVf( _index);
    }
    function acceptForTranslator(uint256 _index,uint256[] memory _fileIndex) public isExist(_index) isCanAcceptTrans(_index){
        service.acceptTrans(_index,_fileIndex,msg.sender);
    }
    function acceptForVerifer(uint256 _index,uint256[] memory _fileIndex) public isExist(_index) isCanAcceptVf(_index){
        service.acceptVf(_index,_fileIndex,msg.sender);
    }
    function validate(uint256 _index,address _transIndex,uint256 _fileIndex, bool _isPass,string memory _file) public isExist(_index){
      uint256 bounty =  _validate(_index,_transIndex,_fileIndex,_isPass,_file);
       //发赏金
      if(bounty>0) {
         bounty = CalculateUtils.getTaskTrans(bounty);
          toTaskerBounty(_transIndex,bounty);
      }
    }
    function sumbitTaskTrans(uint256 _index, uint256 _fileIndex,string memory _file) public isExist(_index){
        _sumbitTaskTrans(_index,_fileIndex,_file);
    }
    function overTimeTrans(uint256 _index, address _taskerIndex)public isExist(_index) returns(uint256) {
      return  _overTimeTrans(_index,_taskerIndex);
    }
     function overTimeVf(uint256 _index, address _taskerIndex)public isExist(_index) returns(uint256) {
        return _overTimeVf(_index,_taskerIndex);
     }
     function deductBounty(uint256 _index, address _taskerIndex,uint256 _fileIndex,uint256 _deductNumer, bool _isTrans) public isExist(_index) {
        _deduct( _index,_taskerIndex,_fileIndex,_deductNumer,_isTrans);
        
     }
     function receiveProject(uint256 _index,address _taskerIndex,uint256 _fileIndex, bool _isPass) public isExist(_index) {
         _receiveProject(_index,_taskerIndex,_fileIndex,_isPass);
         uint256 _payBounty;
         //若用户为自定义支付，则完成后支付校验者赏金，若为非自定义支付，则支付翻译者与校验者赏金
          if(service.isCustomizeState(_index)) {
                _payBounty= service.getSubTaskBounty(_index,_taskerIndex,_fileIndex,false);
                toTaskerBounty(_taskerIndex,_payBounty);
          }
     }
    //发布任务
     function _postProject(LibProject.ProParm memory _t) internal returns(uint256) {
     uint256 _index = service.addProject( _t);
     emit postProjectEv(msg.sender,_index,_t);
       return _index;
    }
    function getTaskInfo(uint256 _index) public view isExist(_index) returns(LibProject.ReturnTask memory) {
        return service.getProjectOne(_index);
    }
    //支付赏金-发布
    //function postPay(uint256 _index) 
    //修改任务
    function _updateProject(uint256 _index,LibProject.ProParm memory _t) internal {
         service.updateProject(_index,_t);
       emit postProjectEv(msg.sender,_index,_t);
    }  //到截至日期后，调用该方法，若到截至日期已经完成接单，则返回true,//若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
    //若有部分人接收，进入任务强分配
    function _endTransAccept( uint256 _index) internal returns(bool){
        uint256 _transNumber = service.getTransNumber(_index);
        LibProject.TaskInfo[] memory _tasks = service.getTasks(_index);
      if(service.isFull(_index,true)){
          return true;
          //若到翻译截至日期，仍无人接单，则关闭翻译接单状态
      }else if(_transNumber == 0) {
          //service.updateState(_index,LibProject.ProjectState.NoOnePick);
          service.closeTransAccept(_index);
           emit uploadAcceptStateEv(msg.sender, _index,"ts",false);
          return false;
      }else {
          uint256 _count = _tasks.length;
          uint256 _acceptedNum = _transNumber;
          uint256 avgNum = _count/_acceptedNum;
          address[] memory _list = service.getTranslatorsList(_index);
          for(uint256 i =0;i<_tasks.length;i++) {
              //任务为待接收状态
              if(_tasks[i].state == LibProject.FileState.Waiting){
                  //为未分配任务分配任务者
                  for(uint256 q=0;q<_transNumber;q++){
                      //超出分配线，不予分配
                   if(service.getAcceptTransNumber(_index,_list[q])>avgNum){
                      continue;
                  }
                  //将当前任务分配给翻译者
                 service.accept(_index,i,_list[q],true);
                emit acceptTaskEv(_index,i,_list[q],true);
                  break;
              }
            }      
          }
          service.closeTransAccept(_index);
          return false;
      }
    }
    //
   function _endTransVf( uint256 _index) internal onlyOwner returns(bool) {
       uint256 vfNumber = service.getVfNumber(_index);
       uint256 _transNumber = service.getTransNumber(_index); 
       LibProject.TaskInfo[] memory _tasks = service.getTasks(_index);
      if(service.isFull(_index,false)){
          return true;
      }else if(vfNumber==0 && _transNumber!=0) {
          service.closeVfAccept(_index);
          return false;
      }
      else if(vfNumber == 0 && _transNumber ==0) {
           //若无人接收任务，则修改任务状态为无人接收状态，关闭翻译接收
          service.onNoOnePink(_index);
          address _buyer =service.getBuyer(_index);
          uint256 _bounty = service.getTaskBounty(_index);
          //退还金额给需求方
          toTaskerBounty(_buyer,_bounty);
          return false;
      }else {
          //若有部分人接收
          uint256 _count = _tasks.length;
          uint256 _acceptedNum = vfNumber;
          uint256 avgNum = _count/_acceptedNum;
          address[] memory _list = service.getVfList(_index);
          for(uint256 i =0;i<_tasks.length;i++) {
              //任务为待接收状态
              if(_tasks[i].state == LibProject.FileState.Waiting){
                  //为未分配任务分配任务者
                  for(uint256 q=0;q<vfNumber;q++){
                      //超出分配线，不予分配
                  if(service.getAcceptVfNumber(_index,_list[q])>avgNum){
                      continue;
                  }
                  //将当前任务分配给翻译者
                   service.accept(_index,i,_list[q],false);
                   emit acceptTaskEv(_index,i,_list[q],false);
                  break;
              }
            }      
          }
          service.closeVfAccept(_index);
          return false;
      }
    }
    //提交任务-翻译者
    function _sumbitTaskTrans(uint256 _index, uint256 _fileIndex,string memory _file) internal {
       service.sumbitTransTask(_index,msg.sender,_fileIndex,_file);
    }

    //超时未提交-翻译者
    function _overTimeTrans(uint256 _index, address _taskerIndex)internal returns(uint256) {
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
    function _overTimeVf(uint256 _index, address _taskerIndex)internal returns(uint256) {
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
     function _validate(uint256 _index,address _transIndex,uint256 _fileIndex, bool _isPass,string memory _file) internal returns(uint256 _payBounty) {
         //若校验通过，将任务者的状态修改为已完成
         if(_isPass) {
             //若用户为自定义支付，则完成后支付任务者赏金
             service.sumbitVfTask(_index,_transIndex,msg.sender,_fileIndex,_file);
             bool _Customize=service.isCustomizeState(_index);
             if(_Customize) {
                _payBounty = service.getSubTaskBounty(_index,_transIndex,_fileIndex,true);
             }
         }else{
             //任务不通过，将任务者的状态修改为被打回状态 
             service.returnTasker(_index,_transIndex,_fileIndex,true);   
             _payBounty = 0; 
         }
         
     }
    //  扣除赏金
     function _deduct(uint256 _index, address _taskerIndex,uint256 _fileIndex,uint256 _deductNumeber, bool _isTrans) internal  {
         uint256 _bounty = service.getTaskBounty(_index,_fileIndex);
         uint256 _deductMoney ;
         if(_isTrans) {
           _deductMoney =  CalculateUtils.getDeductMoney( _bounty,_deductNumeber);
         }else {
           _deductMoney =  CalculateUtils.getDeductMoney( _bounty,_deductNumeber); 
         }
         service.deductBounty(_index,_taskerIndex,_fileIndex,_deductMoney,_isTrans);
     }
    //发布者验收
    function _receiveProject(uint256 _index,address _taskerIndex,uint256 _fileIndex, bool _isPass) internal{
         //若校验通过，将任务者的状态修改为已完成
         if(_isPass) {
             service.receivePass(_index,_taskerIndex,_fileIndex);
         }else{
             //任务不通过，将任务者的状态修改为被打回状态
             service.returnTasker(_index,_taskerIndex,_fileIndex,false);   
         }
     }
     function withdraw() public onlyOwner {
         _withdraw();
     }
}