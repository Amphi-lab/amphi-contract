// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./../contracts/utils/math/SafeMath.sol";
import "./../contracts/access/Ownable.sol";
contract CalculateUtils is Ownable{
    uint256 private rate;
    uint256 private vfN;
    //获得罚金比率
    function punishRatio(uint256 _bounts) internal view returns(uint256) {
        uint256 ratio;
        if (_bounts <rate) {
            ratio = 1;
        }else if(_bounts>=rate&&_bounts<rate*1e1) {
            ratio = 1e1;
        }else if(_bounts >=rate*1e1 && _bounts <rate*1e2){
            ratio = 1e2;
        }else if(_bounts >=rate*1e2 && _bounts < rate*1e3) {
            ratio = 1e3;
        }else if(_bounts>=rate*1e3 && _bounts <=rate*1e4) {
            ratio = 1e4;
        }else if(_bounts>=rate*1e4 && _bounts <=rate*1e5) {
            ratio = 1e5;
        }else{
            //revert ParameterException("Unable to calculate,Please submit a request");
        }
        return ratio;
    }
    //修改汇率
    function setRate(uint256 _rate) internal onlyOwner{
        rate = _rate;
    }
    //校对工作量（人） 校对人数= 翻译人数/校对工作量
    function setvfN(uint256 _vfN) internal onlyOwner {
        vfN =_vfN;
    }
    function getMatNumber(uint256 _transNumber)external view returns(uint256 ){
        uint256 _maxV;
        if(_transNumber<=vfN){
                 _maxV = 1;
        }else{
                  _maxV = SafeMath.div(_transNumber, vfN);
        }
        return _maxV;
    }
    //计算任务赏金
    /**计算任务所需翻译人数：
    1.求出阈值day
    2.判断文件类型：1.文档类  
    */
}