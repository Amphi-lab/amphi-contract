// const { ethers } = require("hardhat");
const ethers = require('ethers'); // Load Ethers library

const providerURL = 'https://rpc.api.moonbase.moonbeam.network';
// Define provider
const gprovider = new ethers.JsonRpcProvider(providerURL, {
    chainId: 1287,
    name: 'moonbase-alphanet'
});

function GetEffWorkloadSBTContract(provider) {
    let abijson = require('../artifacts/contracts/app/SBT/EffWorkloadSBT.sol/EffWorkloadSBT.json');
    
    return new ethers.Contract(
        "0x2d6DF3EA202D2eB59ceB700647d1109456b5b4a8",
        abijson.abi,
        provider
    );
}

async function Connect() {
    const priKey = "0x32c653bcb4593d0d286fc8778a4908ccdeec7487424ddaec1fb9ec858831a1f3";

    let wallet = new ethers.Wallet(priKey, gprovider);
    console.log("wallet: ", wallet);

    const signer = provider.getSigner()
    console.log("signer: ", signer);

    this._sbtContract = GetEffWorkloadSBTContract(provider);
    this._sbtSigner = await this._sbtContract.connect(signer);
    // console.log("signer: ", this._sbtSigner);

    let balance = await this._sbtSigner.balanceOf("0x4d29360c2F7Cc54b8d8A28CB4f29343df867748b", 1);
    console.log("balance: ", balance);
}



Connect();