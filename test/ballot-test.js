const { expect } = require("chai");
const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletree.js");
const keccak256 = require("keccak256");
const { arrayify } = require("ethers/lib/utils");



describe("Election". function () {


    let addrs
    let contractBlocknumber
    const blockNumberCutOff = 11
    before(async function () {
        //create an array that shuffles the numbers 0 through 19
        //The elements of the array will represent the development account number 
        //and the index will represent the order in which that account will use Register to create account
        this




        //Get all signers
        addrs = await ethers.getSigners();

        //Deploy the register contract
        const RegisterFactory = await ethers.getContractFactory("Register", addrs(0));
        this.register = await RegisterFactory.deploy();
        const receipt = await this.register.deployTransaction.wait()
        contractBlocknumber = receipt.blockNumber


    //Every development account create accounts on the register contract in a random order       



    //Query all accountCreated events between contract block number cut off on the Register contract
    //to find out all the accounts that have interacted with it
    const filter = this.register.filters.AccountCreated()
    const results = await this.register.queryfilter(filter, contractBlocknumber, blockNumberCutoff)
    expect(results.length).to.eq(blockNumberCutOff = contractBlocknumber)

    //Get eligible addresses from events and then hash them to get leaf nodes
    this.leafNodes = results.map(i => keccak256(i.args.account.toString()))
    // Generate merkleTree from leafNodes
    this.merkleTree = new MerkleTree(this.leafNodes, keccak256, { sortPairs: true});
    //Get the root hash from merkle tree
    const rootHash = this.merkleTree.getRoot()

    //Deploy the Election contract 
    const ElectionFactory = await ethers.getContractFactory("Election", addrs[0]);
    this.election = await ElectionFactory.deploy(rootHash, Voter);


    });

    it("Only eligible accounts should able be to vote", aync function () {
        //Every eligible account can vote
        for (let i = 0; i < 20; i++) {
            const proof = this.merkleTree.getHexProof(keccak256(addrs[i].address))
            if(proof.length !== 0) {
                await this.election.connect(addrs[i]).vote(proof)
                expect(await this.election.balanceOf(addrs[i].address)).to.eq(voteIndex)
                //Fails when user tries to vote again.
                await expect(this.election.connect(addrs[i]).vote(proof)).to.be.revertedWith("Already voted, can't vote twice")
            } else {
                await expect(this.election.connect(addrs[i]).vote(proof)).to.be.revertedWith("Incorrect merkle proof")
                expect(await this.election.voters(addrs[i].address)).to.eq(0)
            }
        }
    })
})