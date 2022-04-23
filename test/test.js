const { expect } = require("chai");
const { ethers } = require("hardhat");
const { isTopic } = require("web3-utils");
// const {ethers} = require()

describe("ZuriVote", function () {

    let chairman, teachers, bod, students, ZuriVote, zurivote;

    before(async function () {
        ZuriVote = await ethers.getContractFactory("ZuriVote");
        [chairman, teachers, students, bod] = await ethers.getSigners();
        zurivote = await ZuriVote.deploy(["foo", "bar"], ["bar", "foobar"]);
    });

    it("chairman should start election", async function () {

        expect(await zurivote.startElection()); //.to.be(owner.address);
    })

    describe("Vote", function () {
        // it("should add candidate", async function(){
        it("should be able to vote", async function () {

            expect(await zurivote.vote(1)); //.to.be(owner.address);
        })
    })
})

