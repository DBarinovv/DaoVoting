const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");

describe("AnonymousGovernor", function () {
  let AnonymousGovernor;
  let anonymousGovernor;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    AnonymousGovernor = await ethers.getContractFactory("AnonymousGovernor");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    // Deploy the token contract and mint some tokens for testing
    const ERC20 = await ethers.getContractFactory("ERC20");
    const token = await ERC20.deploy("Test Token", "TST", 18);
    await token.deployed();
    await token.mint(owner.address, ethers.utils.parseEther("1000"));
    await token.mint(addr1.address, ethers.utils.parseEther("1000"));
    await token.mint(addr2.address, ethers.utils.parseEther("1000"));

    // Deploy the AnonymousGovernor contract
    anonymousGovernor = await AnonymousGovernor.deploy(
      token.address,
      "Test Governor",
      1,
      10
    );
    await anonymousGovernor.deployed();
  });

  describe("Deployment", function () {
    it("Should set the correct token and parameters", async function () {
      expect(await anonymousGovernor.token()).to.equal(token.address);
      expect(await anonymousGovernor.name()).to.equal("Test Governor");
      expect(await anonymousGovernor.votingDelay()).to.equal(1);
      expect(await anonymousGovernor.votingPeriod()).to.equal(10);
    });
  });

  describe("Voting", function () {
    it("Should create a proposal and vote for it", async function () {
      // Create a proposal
      await anonymousGovernor
        .connect(addr1)
        .createProposal("Test Proposal", [], [], []);
      expect(await anonymousGovernor.proposalCount()).to.equal(1);

      // Vote for the proposal
      // Note: In a real scenario, you would use a blind signature here.
      await anonymousGovernor
        .connect(addr1)
        .vote(
          1,
          true,
          ethers.utils.id("test message"),
          27,
          "0x0000000000000000000000000000000000000000000000000000000000000000",
          "0x0000000000000000000000000000000000000000000000000000000000000000"
        );

      // Verify the vote count
      let votes = await anonymousGovernor.getVotes(1);
      expect(votes.forVotes).to.equal(
        BigNumber.from(ethers.utils.parseEther("1000"))
      );
    });
  });
});
