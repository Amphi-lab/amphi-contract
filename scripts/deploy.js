// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // 这一部分都是hardhat部署Lock合约的示例代码
  /*
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;

  const lockedAmount = hre.ethers.parseEther("0.001");

  const lock = await hre.ethers.deployContract("Lock", [unlockTime], {
    value: lockedAmount,
  });

  await lock.waitForDeployment();

  console.log(
    `Lock with ${ethers.formatEther(
      lockedAmount
    )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`
  );
  */
  
  // 我们的部署脚本从这里开始
  const [deployer] = await hre.ethers.getSigners();

  console.log(
    "当前部署合约的账号为：",
    deployer.address
  );

  // 首先部署 Erc20T 合约试试
  const Erc20T = await hre.ethers.getContractFactory("Erc20T");
  const erc20T = await Erc20T.deploy();
  console.log("Erc20T合约部署成功，合约地址为:", erc20T.address);

  // 部署AmphiTrans合约
  const AmphiTrans = await hre.ethers.getContractFactory("AmphiTrans");
  const amphiTrans = await AmphiTrans.deploy();
  console.log("AmphiTrans合约部署成功，合约地址为:", amphiTrans.address);

  // 部署AmphiPass合约
  // const AmphiPass = await hre.ethers.getContractFactory("AmphiPass");
  // const amphiPass = await AmphiPass.deploy("baseUri"); // TODO: baseUri的参数是什么含义？这里amphiPass合约部署的时候，需要有这个初始化参数
  // console.log("AmphiPass合约部署成功，合约地址为:", amphiPass.address);

  
  console.log("一键部署完成");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});