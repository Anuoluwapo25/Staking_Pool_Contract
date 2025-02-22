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
      
        token = new StakingToken();
        stakingPool = new StakingPool(address(token));
        
        token.mint(INITIAL_SUPPLY);
        token.mint(INITIAL_SUPPLY);
    }

    function test_CreatePool() public {
        vm.expectEmit(true, true, true, true);
        emit PoolCreated(0, 30 days, 20);
        stakingPool.createPool(30 days, 20);

        (uint lockPeriod, uint percentage, bool exists) = stakingPool.pools(0);
        assertEq(lockPeriod, 30 days);
        assertEq(percentage, 20);
        assertTrue(exists);
    }

    function test_CreatePoolRevert() public {
        vm.expectRevert("Lock period must be greater than zero");
        stakingPool.createPool(0, 20);

        vm.expectRevert("Percentage must be between 1 and 100");
        stakingPool.createPool(30 days, 0);

        vm.expectRevert("Percentage must be between 1 and 100");
        stakingPool.createPool(30 days, 101);
    }

}

