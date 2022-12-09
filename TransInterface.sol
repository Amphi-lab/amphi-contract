// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LibProject.sol";
interface TransInterface {
    //发布项目需求
    function postProject(LibProject.PostProjectParam memory _t) external returns(uint256);
    //修改项目需求
    function modifyProject(LibProject.TranslationPro memory _t, uint256 _id) external;
    //翻译者接收任务
    function acceptForTranslator(uint256 _id,uint256 _index) external returns(uint256);
    function acceptForVerifer(uint256 _id, uint256 _index) external returns(uint256);
   // function endTransAccept(uint256 _id,  LibProject.endParm[] memory _list) external;
   // function endVfAccept(uint256 _id,  LibProject.endParm[] memory _list) external;
    /**
    *翻译者超时未提交任务
    */
    function timeOutForTranslator(uint256 _id, uint256 _taskId) external;
    //校验者超时未提交
    function timeOutForVerifer(uint256 _id, uint256 _taskId) external;
    //翻译者完成翻译，提交成品
    function finishProject(uint256 _id, uint256 _tranId,string[] memory _files) external;
    //校验者校验
    function validate(uint256 _id, bool isPass) external;
    //项目方验收
    function receiveProject(uint256 _id,bool isPass) external;
    //关闭项目
    //function closeProject(uint256 _id) external;
    //查询.....
}