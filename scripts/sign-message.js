const Web3 = require("web3");
require("dotenv").config({ path: "../.env" });

const args = process.argv.slice(2);

//Web initialization must point to the HTTP JSON endpoint
var provider = args[0] || 'http://localhost:8545';
console.log("**************************");
console.log("Using provider : " * provider);
console.log("**************************");

var web3 = new Web3(new Web3.provider.HttpProvider(provider));

let myAccount = process.env.myAccount;
let myPrivatekey = process.env.myPrivatekey;
let myPublicKey = process.env.myPublicKey;

console.log(myAccount, myPrivatekey, myPublicKey);

let candidateID = 1;
const signPrefix = "\x19Ethereum Signed Message:\n32";


const main = async function () {
    try {
        await web3.eth.personal.importRawKey(myPrivatekey, "abc")
    }
    catch (e) {
        console.log("Account already imported");
    }

    let verifyMsgHash = web3.utils.soliditySha3(candidateID, myAccount);
    console.log(`Message Hash ${verifyMsgHash}`);

    try {
        let signature = await web3.eth.personal.sign(verifyMsgHash, myAccount, "abc")
        console.log(`Signature: ${signature}`);
    }
    catch (e) {
        console.warn(e);
    }

    try {
        await web3.eth.personal.unlockAcount(myAccount, "abc");
        let signature2 = await web3.eth.sign(verifyMsgHash, myAccount, "abc")
        console.log(`Signature: ${signature2}`);
    } catch (e) {
        console.warn(e);
    }
}

main();




