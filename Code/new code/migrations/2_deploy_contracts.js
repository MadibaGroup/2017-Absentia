var ec = artifacts.require("./ec.sol");
var PET = artifacts.require("./PET.sol");
var mixmatch = artifacts.require("./mixmatch.sol");

module.exports = async (deployer) => {
    await deployer.deploy(ec);
    ecInstance = await ec.deployed();
    console.log("ec: I was deployed!!!!!");
    console.log(ecInstance.address);
    // console.log(`Deploy ec gas: ${ecInstance.receipt}`);
   
    accounts = await web3.eth.getAccounts();
    await deployer.link(ec,mixmatch);
    await deployer.deploy(mixmatch,accounts[1],accounts[2],accounts[3],accounts[4]);
  
    matchInstance = await mixmatch.deployed();
    console.log("Mix: I was deployed!!!!!");
    console.log(matchInstance.address);

    //needed for gas costs for deployment
    // await deployer.link(ec,PET);
    // await deployer.deploy(PET);
  

};



