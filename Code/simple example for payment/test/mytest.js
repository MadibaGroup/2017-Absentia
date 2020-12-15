
var A = artifacts.require("A");

        
contract('A', function(accounts) {
  

    it('payable', async() => {
      
        accounts = await web3.eth.getAccounts();
        const AInstance = await A.deployed();
        console.log("Balances after deploy: ");
        let output = await AInstance.checkBalances();
        event1 = output.receipt.logs[0].args[0];
        console.log("alice:    ", event1.toString());
        event1 = output.receipt.logs[0].args[1];
        console.log("bob:      ", event1.toString());
        event1 = output.receipt.logs[0].args[2];
        console.log("trustee1: ", event1.toString());
        event1 = output.receipt.logs[0].args[3];
        console.log("trustee2: ", event1.toString());
        console.log();
        output = await AInstance.loadFund({from:accounts[1], value: web3.utils.toWei("0.00000000000000005", "ether")});
        output = await AInstance.loadFund({from:accounts[2], value: web3.utils.toWei("0.00000000000000005", "ether")});

        console.log("Balances after Alice and Bob deposit funds: ");
        output = await AInstance.checkBalances();
        event1 = output.receipt.logs[0].args[0];
        console.log("alice:    ", event1.toString());
        event1 = output.receipt.logs[0].args[1];
        console.log("bob:      ", event1.toString());
        event1 = output.receipt.logs[0].args[2];
        console.log("trustee1: ", event1.toString());
        event1 = output.receipt.logs[0].args[3];
        console.log("trustee2: ", event1.toString());
        output = await AInstance.doSomething();
        output = await AInstance.doSomething();
        console.log();

        console.log("Balances after calling doSomething twice: ");
        output = await AInstance.checkBalances();
        event1 = output.receipt.logs[0].args[0];
        console.log("alice:    ", event1.toString());
        event1 = output.receipt.logs[0].args[1];
        console.log("bob:      ", event1.toString());
        event1 = output.receipt.logs[0].args[2];
        console.log("trustee1: ", event1.toString());
        event1 = output.receipt.logs[0].args[3];
        console.log("trustee2: ", event1.toString());
        console.log();

        console.log("Balances after Alice sends excess funds back: ");
        output = await AInstance.sendexcessfunds(5,{from:accounts[1]});
        output = await AInstance.checkBalances();
        event1 = output.receipt.logs[0].args[0];
        let balance = await web3.eth.getBalance(accounts[1]);
        console.log("alice:    ", event1.toString(), " ", balance);
        event1 = output.receipt.logs[0].args[1];
        console.log("bob:      ", event1.toString());
        event1 = output.receipt.logs[0].args[2];
        console.log("trustee1: ", event1.toString());
        event1 = output.receipt.logs[0].args[3];
        balance = await web3.eth.getBalance(accounts[4]);
        console.log("trustee2: ", event1.toString(), " ", balance);
        console.log();
        
        console.log("Balances after Alice withdraws 10: ");
        output = await AInstance.withdraw( 10,{from:accounts[1]});
        output = await AInstance.checkBalances();
        event1 = output.receipt.logs[0].args[0];
        balance = await web3.eth.getBalance(accounts[1]);
        console.log("alice:    ", event1.toString(), " ", balance);
        event1 = output.receipt.logs[0].args[1];
        console.log("bob:      ", event1.toString());
        event1 = output.receipt.logs[0].args[2];
        console.log("trustee1: ", event1.toString());
        event1 = output.receipt.logs[0].args[3];
        balance = await web3.eth.getBalance(accounts[4]);
        console.log("trustee2: ", event1.toString(), " ", balance);
        console.log();

        console.log("Balances after Alice sends excess funds back: ");
        output = await AInstance.sendexcessfunds(15,{from:accounts[1]});
        output = await AInstance.checkBalances();
        event1 = output.receipt.logs[0].args[0];
        balance = await web3.eth.getBalance(accounts[1]);
        console.log("alice:    ", event1.toString(), " ", balance);
        event1 = output.receipt.logs[0].args[1];
        console.log("bob:      ", event1.toString());
        event1 = output.receipt.logs[0].args[2];
        console.log("trustee1: ", event1.toString());
        event1 = output.receipt.logs[0].args[3];
        balance = await web3.eth.getBalance(accounts[4]);
        console.log("trustee2: ", event1.toString(), " ", balance);

       

       
        // let output = await AInstance.deposit({from:accounts[1], value: web3.utils.toWei("0.00000000000000001", "ether")});
        // event1 = output.receipt.logs[0].args[0];
        // console.log("MONEY: ", event1.toString());
        // event1 = output.receipt.logs[0].args[1];
        // console.log("Alice: ", event1);
        // console.log();

        // output = await AInstance.deposit({from:accounts[2], value: web3.utils.toWei("0.00000000000000001", "ether")});
        // event1 = output.receipt.logs[0].args[0];
        // console.log("MONEY: ", event1.toString());
        // event1 = output.receipt.logs[0].args[1];
        // console.log("Bob: ", event1);
        // console.log();

        // output = await AInstance.doSomething({from:accounts[1]});
        // output = await AInstance.doSomething();
        // output = await AInstance.sendFund(accounts[1],accounts[2]);
      

        
    });
});


