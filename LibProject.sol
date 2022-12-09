// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
library LibProject {
//项目状态：已发布、进行中、超时、无人选择、已关闭,已完成
 enum ProjectState { Published,Processing,Overtime, NoOnePick, Closed,Completed }
 // 校验者||翻译者状态 
 enum TaskerState { Waiting, Processing, Submitted,Pass,Fail, Return, Completed, TimeOut }
 //文件状态
 enum FileProcessing { Waiting, Translating, Validating, WaitModify, BuyerReview, Accepted }
 //文件
 struct FileInfo {
     string  name;
     uint256 size;
     uint256 videoLength;
     uint256 Page;
     uint256 words;
     uint256 fileType;
     string  path;
 }
 //子任务详情
 struct TaskInfo {
     FileInfo file; 
     uint256 bounty; 
     FileProcessing state;
     //uint256 tasker;
     uint256 lastUpload;
 }
 struct Tasker {
     address taskerAddress;
     uint256[] taskIndex;
 }
 //项目
 struct TranslationPro {
        uint256 releaseTime;  //发布时间
        string introduce;     //项目介绍
        string need;          //项目需求说明
        uint256 deadline;     //截至日期
        string sourceLanguage;//源语言
        string goalLanguage;  //目标语言
        string[] preferList;  //偏好
        uint256 translationType;//类型
        uint256 workLoad;
        bool isNonDisclosure; //是否保密
        bool isCustomize;     //是否为自定义支付
        uint256 bounty;        //赏金
        TaskInfo[] tasks;     //子任务
        Tasker[] translator; //翻译者
        Tasker[] verifier;   //校验者
        uint256 maxT;        //翻译者最大人数
        uint256 maxV;        //校验者最大人数
        bool isTransActive;  //翻译者状态: true.开启 false：关闭 
        bool isVerActive;    //校验者状态: true:开启 false:关闭
        ProjectState state;        //项目状态
 }

 //发布项目请求参数
 struct PostProjectParam {
     uint256 releaseTime;
     string introduce;
     string need;
     uint256 deadline; 
     string sourceLanguage;
     string goalLanguage;
     string[] preferList;
     uint256 translationType;
     uint256 workLoad;
     bool isNonDisclosure;
     bool isCustomize;
     uint256 bounty;
     FileInfo[] files;
 }
}