// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
library LibProject {
//项目状态：已发布、进行中、超时、无人选择、已关闭,已完成
 enum ProjectState {Waiting ,Published,Processing,Overtime, NoOnePick, Closed,Completed }
 // 校验者||翻译者状态 
 enum TaskerState { Waiting, Processing, Submitted,Return,Completed,Overtime }
 //文件状态
 enum FileState { Waiting, Translating, Validating, WaitTransModify, BuyerReview, WaitVfModify,Accepted,NoOnePick}
 //文件
 struct FileInfo {
     string  name; 
     uint256 size;
     uint256 videoLength;
     uint256 Page;
     uint256 words;
     uint256 fileType; //文件类型
     string  path;     //文件链接
 }
 //子任务详情
 struct TaskInfo {
     FileInfo file;    //文件
     uint256 bounty;  //赏金
     string info;     //任务说明
     FileState state; //任务状态
     uint256 lastUpload; //最后更新时间
 }
 //任务者
  struct Tasker {
     address taskerAddress; //任务者地址
     uint256[] taskIndex;   //任务（文件）索引
     TaskerState[] states;  //任务状态
     string[] files;        //上传的文件
     uint256[] bounty;        //赏金
 }
 struct SubtaskInfo {
     uint256 taskIndex;
     uint256 TaskerState;
     string file;
 }

 //项目
 struct TranslationPro {
        address buyer;        //发布者
        uint256 releaseTime;  //发布时间
        string introduce;     //项目介绍
        string need;          //项目需求说明
        uint256 deadline;     //截至日期
        string sourceLanguage;//源语言
        string goalLanguage;  //目标语言
        string[] preferList;  //偏好
        uint256 translationType;//类型
        uint256 workLoad;       //工作量
        bool isNonDisclosure; //是否保密
        bool isCustomize;     //是否为自定义支付
        uint256 bounty;        //赏金
        TaskInfo[] tasks;     //子任务
        Tasker[] translators; //翻译者
        Tasker[] verifiers;   //校验者
        uint256 maxT;        //翻译者最大人数
        uint256 maxV;        //校验者最大人数
        bool isTransActive;  //翻译者状态: true.开启 false：关闭 
        bool isVerActive;    //校验者状态: true:开启 false:关闭
        ProjectState state;        //项目状态
        bool payState;             //支付状态
 }
 //项目
 struct ProParm {
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
        // uint256 maxT;        //翻译者最大人数
        // uint256 maxV;        //校验者最大人数
 }
}