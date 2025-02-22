// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingPool is Ownable {
    IERC20 public stakingToken;
    uint public poolId;

    mapping(address => Stake) public stakes;
    mapping(uint => Pool) public pools;

    struct Pool {
        uint lockPeriod;    
        uint percentage;    
        bool exists;       
    }

    struct Stake {
        uint poolId;       
        uint amount;       
        uint timestamp;     
        bool exists;       
    }

    event PoolCreated(uint indexed poolId, uint lockPeriod, uint percentage);
    event Staked(address indexed user, uint indexed poolId, uint amount);
    event Withdrawn(address indexed user, uint amount, uint reward);

    constructor(address _stakingToken) Ownable(msg.sender) {  
        stakingToken = IERC20(_stakingToken);
    }

    function createPool(uint _lockPeriod, uint _percentage) external onlyOwner {
        require(_lockPeriod > 0, "Lock period must be greater than zero");
        require(_percentage > 0 && _percentage <= 100, "Percentage must be between 1 and 100");

        pools[poolId] = Pool({
            lockPeriod: _lockPeriod,
            percentage: _percentage,
            exists: true
        });

        emit PoolCreated(poolId, _lockPeriod, _percentage);
        poolId++;
    }

    function stake(uint _amount, uint _poolId) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(pools[_poolId].exists, "Pool must exist");
        require(!stakes[msg.sender].exists, "User already has an active stake");

        require(stakingToken.transferFrom(msg.sender, address(this), _amount), 
            "Token transfer failed");

        stakes[msg.sender] = Stake({
            poolId: _poolId,
            amount: _amount,
            timestamp: block.timestamp,
            exists: true
        });

        emit Staked(msg.sender, _poolId, _amount);
    }

    function calculateRewards(address _staker) public view returns (uint) {
        require(stakes[_staker].exists, "Staker does not exist");
        
        Stake memory userStake = stakes[_staker];
        Pool memory userPool = pools[userStake.poolId];
        
        uint reward = (userStake.amount * userPool.percentage) / 100;
        return reward;
    }

    function withdrawStake() external {  
        require(stakes[msg.sender].exists, "No active stake found");
        
        Stake memory userStake = stakes[msg.sender];
        Pool memory userPool = pools[userStake.poolId];
        
        uint timeStaked = block.timestamp - userStake.timestamp;
        require(timeStaked >= userPool.lockPeriod, "Staking period not completed");

        uint reward = calculateRewards(msg.sender);
        uint amount = userStake.amount;

        require(stakingToken.transfer(msg.sender, amount), "Stake transfer failed");
        require(stakingToken.transfer(msg.sender, reward), "Reward transfer failed");

        delete stakes[msg.sender];

        emit Withdrawn(msg.sender, amount, reward);
    }

    function getStakeInfo(address _staker) external view returns (Stake memory) {
        return stakes[_staker];
    }
}