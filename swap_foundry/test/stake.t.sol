// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StakingPool.sol";

import "../src/staketoken.sol";

contract StakingPoolTest is Test {
    StakingPool public stakingPool;
    StakingToken public token;
    
    address public owner;
    address public alice;
    address public bob;
    
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; 
    uint256 public constant STAKE_AMOUNT = 1000 * 10**18;      
    
    event PoolCreated(uint indexed poolId, uint lockPeriod, uint percentage);
    event Staked(address indexed user, uint indexed poolId, uint amount);
    event Withdrawn(address indexed user, uint amount, uint reward);

    function setUp() public {
    
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
      
        token = new MockERC20("Test Token", "TEST");
        stakingPool = new StakingPool(address(token));
        
   
        token.mint(alice, INITIAL_SUPPLY);
        token.mint(bob, INITIAL_SUPPLY);
    }

    function test_CreatePool() public {
        // Test creating a pool
        vm.expectEmit(true, true, true, true);
        emit PoolCreated(0, 30 days, 20);
        stakingPool.createPool(30 days, 20);

        // Verify pool exists
        (uint lockPeriod, uint percentage, bool exists) = stakingPool.pools(0);
        assertEq(lockPeriod, 30 days);
        assertEq(percentage, 20);
        assertTrue(exists);
    }

    function test_CreatePoolRevert() public {
        // Test creating pool with invalid parameters
        vm.expectRevert("Lock period must be greater than zero");
        stakingPool.createPool(0, 20);

        vm.expectRevert("Percentage must be between 1 and 100");
        stakingPool.createPool(30 days, 0);

        vm.expectRevert("Percentage must be between 1 and 100");
        stakingPool.createPool(30 days, 101);
    }

    function test_Stake() public {
        // Create pool
        stakingPool.createPool(30 days, 20);

        // Setup staking
        vm.startPrank(alice);
        token.approve(address(stakingPool), STAKE_AMOUNT);

        // Test staking
        vm.expectEmit(true, true, true, true);
        emit Staked(alice, 0, STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT, 0);

        // Verify stake
        (uint poolId, uint amount, uint timestamp, bool exists,) = stakingPool.getStakeInfo(alice);
        assertEq(poolId, 0);
        assertEq(amount, STAKE_AMOUNT);
        assertEq(timestamp, block.timestamp);
        assertTrue(exists);
        vm.stopPrank();
    }

    function test_StakeRevert() public {
        stakingPool.createPool(30 days, 20);
        
        vm.startPrank(alice);
        token.approve(address(stakingPool), STAKE_AMOUNT);

        // Test invalid amount
        vm.expectRevert("Amount must be greater than zero");
        stakingPool.stake(0, 0);

        // Test invalid pool
        vm.expectRevert("Pool must exist");
        stakingPool.stake(STAKE_AMOUNT, 99);

        // Test first stake
        stakingPool.stake(STAKE_AMOUNT, 0);

        // Test double stake
        vm.expectRevert("User already has an active stake");
        stakingPool.stake(STAKE_AMOUNT, 0);

        vm.stopPrank();
    }

    function test_CalculateRewards() public {
        // Create pool with 20% reward
        stakingPool.createPool(30 days, 20);

        // Stake tokens
        vm.startPrank(alice);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT, 0);

        // Calculate expected reward (20% of stake)
        uint expectedReward = (STAKE_AMOUNT * 20) / 100;
        
        // Verify reward calculation
        uint calculatedReward = stakingPool.calculateRewards(alice);
        assertEq(calculatedReward, expectedReward);
        vm.stopPrank();
    }

    function test_Withdraw() public {
        // Create pool with 20% reward
        stakingPool.createPool(30 days, 20);

        // Setup staking
        vm.startPrank(alice);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT, 0);

        // Calculate expected reward
        uint expectedReward = (STAKE_AMOUNT * 20) / 100;

        // Advance time past lock period
        vm.warp(block.timestamp + 31 days);

        // Record balances before withdrawal
        uint balanceBefore = token.balanceOf(alice);

        // Test withdrawal
        vm.expectEmit(true, true, true, true);
        emit Withdrawn(alice, STAKE_AMOUNT, expectedReward);
        stakingPool.withdraw();

        // Verify balances after withdrawal
        uint balanceAfter = token.balanceOf(alice);
        assertEq(balanceAfter, balanceBefore + STAKE_AMOUNT + expectedReward);

        // Verify stake is cleared
        (,,, bool exists,) = stakingPool.getStakeInfo(alice);
        assertFalse(exists);
        vm.stopPrank();
    }

    function test_WithdrawRevert() public {
        stakingPool.createPool(30 days, 20);

        // Test withdrawal without stake
        vm.expectRevert("No active stake found");
        stakingPool.withdraw();

        // Setup stake
        vm.startPrank(alice);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT, 0);

        // Test early withdrawal
        vm.expectRevert("Staking period not completed");
        stakingPool.withdraw();
        vm.stopPrank();
    }

    function test_MultiplePoolsAndUsers() public {
        // Create multiple pools
        stakingPool.createPool(30 days, 20);  
        stakingPool.createPool(60 days, 40);  
        stakingPool.createPool(90 days, 50);  // Pool 2: 50% reward

        // Alice stakes in pool 0
        vm.startPrank(alice);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT, 0);
        vm.stopPrank();

        // Bob stakes in pool 1
        vm.startPrank(bob);
        token.approve(address(stakingPool), STAKE_AMOUNT);
        stakingPool.stake(STAKE_AMOUNT, 1);
        vm.stopPrank();

        // Verify different rewards
        uint aliceReward = stakingPool.calculateRewards(alice);
        uint bobReward = stakingPool.calculateRewards(bob);
        
        assertEq(aliceReward, (STAKE_AMOUNT * 20) / 100);  // 20% reward
        assertEq(bobReward, (STAKE_AMOUNT * 40) / 100);    // 40% reward
    }

    // Fuzz test for creating pools with various parameters
    function testFuzz_CreatePool(uint256 lockPeriod, uint256 percentage) public {
        // Bound the inputs to reasonable values
        lockPeriod = bound(lockPeriod, 1 days, 365 days);
        percentage = bound(percentage, 1, 100);

        stakingPool.createPool(lockPeriod, percentage);
        
        (uint storedPeriod, uint storedPercentage, bool exists) = stakingPool.pools(0);
        assertEq(storedPeriod, lockPeriod);
        assertEq(storedPercentage, percentage);
        assertTrue(exists);
    }
}