// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
import "./utils/calculateUtils.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
contract TransService is CalculateUtils{
    event postProject(address,uint256,LibProject.TranslationPro);
    event updateProSate(address,uint256,LibProject.ProjectState);
    event uploadAcceptState(address,uint256,string,bool);
    mapping(address =>    LibProject.TranslationPro[])  taskList;
    //增加项目
    function posProject(address _buyer, LibProject.TranslationPro memory _t)  public returns(uint256) {
         uint256 _len =taskList[_buyer].length;
        LibProject.TranslationPro storage _pro= taskList[_buyer][_len];
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
        _pro.isTransActive = _t.isTransActive;
        _pro.isVerActive = _t.isVerActive;
        _pro.state = _t.state;
        for(uint256 i=0;i< _t.tasks.length;i++) {
            _pro.tasks.push(_t.tasks[i]);
        }
        emit postProject(_buyer,_len,_t);
        return _len;
    }
    function updateState(address _buyer, uint256 _index, LibProject.ProjectState _state) public {
        taskList[_buyer][_index].state = _state;
        emit updateProSate(_buyer,_index,_state);
    }
    function closeTransAccept(address _buyer, uint256 _index) public {
        taskList[_buyer][_index].isTransActive = false;
        emit uploadAcceptState(_buyer, _index,"ts",false);
    }
    function closeVfAccept(address _buyer, uint256 _index) public {
        taskList[_buyer][_index].isVerActive = false;
         emit uploadAcceptState(_buyer, _index,"vf",false);
    }
    function openTransAccept(address _buyer, uint256 _index) public {
        taskList[_buyer][_index].isTransActive = true;
         emit uploadAcceptState(_buyer, _index,"ts",true);
    }
    function openVfAccept(address _buyer, uint256 _index) public {
        taskList[_buyer][_index].isVerActive = true;
         emit uploadAcceptState(_buyer, _index,"ts",true);
    }
    //查询指定项目翻译者名单
    // function getTranslators(address _buyer,uint256 _index) public returns(LibProject.Tasker[] memory) {
    //     return taskList[_buyer][_index].translators;
    // }
    // //查询指定项目校验者名单
    // function getVerifiers(address _buyer,uint256 _index) public returns(LibProject.Tasker[] memory) {
    //     return taskList[_buyer][_index].translators;
    // }
    //查询指定项目信息
    function getProject(address _buyer, uint256 _index) public returns (LibProject.TranslationPro memory) {
        return taskList[_buyer][_index];
    }
}