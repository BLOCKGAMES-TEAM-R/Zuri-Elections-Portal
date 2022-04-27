const { ethers } = require("ethers");

const showAccount = document.querySelector('.showAccount');

async function connect() {
    if (typeof window.ethereum !== "undefined") {
      try {
        await ethereum.request({ method: "eth_requestAccounts" });
      } catch (error) {
        alert(error);
      }
      const accounts = await ethereum.request({ method: "eth_accounts" });
      const account = accounts[0];
      showAccount.innerHTML = account;
      document.getElementById("connectButton").innerText = "Connected";
    } else {
      document.getElementById("connectButton").innerHTML =
        "Please install MetaMask";
    }
  }

async function execute() {
    // address
    // Contract ABI
    // function
    // node conection
    const contractAddress = "0x72Bf3aD82718c182F2Afb2E2aC96d2c85d3Cc3B4";
    const abi = [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"candidatesCount","type":"uint256"},{"indexed":false,"internalType":"string","name":"_name","type":"string"}],"name":"CandidateAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256[]","name":"_winnerIDs","type":"uint256[]"},{"indexed":true,"internalType":"uint256","name":"_winnerVoteCount","type":"uint256"}],"name":"ElectionEnded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"_candidateID","type":"uint256"}],"name":"Voted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"_candidateID","type":"uint256"},{"indexed":true,"internalType":"uint256","name":"candidateVoteCount","type":"uint256"}],"name":"VotedFor","type":"event"},{"inputs":[],"name":"adminCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"admins","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"candidates","outputs":[{"internalType":"string","name":"candidateName","type":"string"},{"internalType":"uint256","name":"candidateID","type":"uint256"},{"internalType":"uint256","name":"voteCount","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"candidatesCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"chairman","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"description","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"electionTimeline","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"endElection","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"isActive","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"isEnded","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"startElection","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"timeLeft","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"_candidateID","type":"uint256"}],"name":"vote","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_candidateID","type":"uint256"},{"internalType":"bytes","name":"signature","type":"bytes"},{"internalType":"address","name":"_voter","type":"address"}],"name":"voteWithSig","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"voters","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"votersID","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"winnerIDs","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"winnerVoteCount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}];

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner(); // this is going to get the connected account
    const contract = new ethers.Contract(contractAddress, abi, signer);

    await contract.function();
}

module.exports = {
    connect,
    execute,
}