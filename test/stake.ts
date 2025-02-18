import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import  hre  from "hardhat";

describe("StakingToken", function() {
    async function deployToken() {
        const [owner, account1, account2] = await hre.ethers.getSigners();
        const StakingToken = await hre.ethers.getContractFactory("StakingToken");
        const stakeToken = await StakingToken.deploy();

        return { stakeToken };

    }

    async function deployStake() {

        const [owner, account1, account2] = await hre.ethers.getSigners();

        const { stakeToken } = await deployToken();

        const Stakingpool = await hre.ethers.getContractFactory("Stakinpool");
        const stakingpool = await Stakingpool.deploy()

        return {stakeToken, stakingpool, owner, account1, account2}
    }
    describe("StakeToken", function() {
    it("should check if tokenstake is staked" ), async function() {
        const { stakeToken, stakingpool, owner, account1, account2 } = await loadFixture(deployStake);

        const stakeAmount = hre.ethers.parseEther("10");
        
        // await stakeToken.connect(account1).approve(stakingpool, stakeAmount);
        const allowance = await stakeToken.allowance(owner, stakingpool);
        
        console.log("The allowance of the contract before", allowance);
        const spendAmount = hre.ethers.parseUnits("15", 18);

        await stakeToken.approve(stakingpool, spendAmount);

        const allowanceAfter = await stakeToken.allowance(owner, stakingpool);

        console.log("The allowance of the contract after", allowanceAfter);
        
        } 
    });
})