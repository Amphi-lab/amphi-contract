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
  const Erc20T = await ethers.getContractFactory("Erc20T");
  const erc20T = await Erc20T.deploy();
  console.log("erc20T contract address:", erc20T.address);

  console.log("一键部署成功");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});