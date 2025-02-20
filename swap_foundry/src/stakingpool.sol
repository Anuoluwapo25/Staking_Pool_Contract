// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingPool is Ownable {
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    
    uint256 public constant LOCK_PERIOD = 90 days;
    uint256 public constant REWARD_RATE = 15;
    
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 rewards;
        bool exists;
    }
    
    mapping(address => Stake) public stakes;
    uint256 public totalStaked;
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event TokensSwapped(address indexed user, uint256 amountIn, uint256 amountOut);
    
    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }
    
    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(!stakes[msg.sender].exists, "Already staking");
        
        stakes[msg.sender] = Stake({
            amount: _amount,
            timestamp: block.timestamp,
            rewards: 0,
            exists: true
        });
        
        totalStaked = totalStaked + _amount;
        
        IERC20(stakingToken).transferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }
    
    function calculateRewards(address _staker) public view returns (uint256) {
        if (!stakes[_staker].exists) return 0;
        
        Stake memory userStake = stakes[_staker]; 
        uint256 timeStaked = block.timestamp - userStake.timestamp;
        
        if (timeStaked < LOCK_PERIOD) return 0;
        
        uint256 rewardAmount = userStake.amount *
            REWARD_RATE *
            timeStaked /
            (365 days) /
            100;
            
        return rewardAmount;
    }
    
    function unstake() external {
        require(stakes[msg.sender].exists, "No active stake");
        require(block.timestamp >= stakes[msg.sender].timestamp + LOCK_PERIOD,
                "Lock period not over");
        
        Stake memory userStake = stakes[msg.sender];  
        uint256 rewardAmount = calculateRewards(msg.sender);
        uint256 stakeAmount = userStake.amount;
        
        totalStaked = totalStaked - stakeAmount;
        delete stakes[msg.sender];
        
        require(stakingToken.transfer(msg.sender, stakeAmount),
                "Stake transfer failed");
                
        if (rewardAmount > 0) {
            require(rewardToken.transfer(msg.sender, rewardAmount),
                    "Reward transfer failed");
            emit RewardsClaimed(msg.sender, rewardAmount);
        }
        
        emit Unstaked(msg.sender, stakeAmount);
    }
    
    function getStakeInfo(address _staker) external view returns (
        uint256 amount,
        uint256 timestamp,
        uint256 rewards,
        bool exists
    ) {
        Stake memory userStake = stakes[_staker];  
        return (
            userStake.amount,
            userStake.timestamp,
            calculateRewards(_staker),
            userStake.exists
        );
    }
    
    function swapTokens(uint256 _amountIn, address _toToken) external {
        require(_amountIn > 0, "Cannot swap 0 tokens");
        
        // Ensure the user has enough tokens for the swap
        if (_toToken == address(stakingToken)) {
            require(rewardToken.transferFrom(msg.sender, address(this), _amountIn), "Transfer failed");
            require(stakingToken.transfer(msg.sender, _amountIn), "Swap failed");
        } else if (_toToken == address(rewardToken)) {
            require(stakingToken.transferFrom(msg.sender, address(this), _amountIn), "Transfer failed");
            require(rewardToken.transfer(msg.sender, _amountIn), "Swap failed");
        } else {
            revert("Invalid token address");
        }

        emit TokensSwapped(msg.sender, _amountIn, _amountIn);  // This assumes a 1:1 swap rate for simplicity
    }
    
    function withdrawRewardTokens(uint256 _amount) external onlyOwner {
        require(rewardToken.transfer(owner(), _amount), "Transfer failed");
    }

    // Owner function to remove tokens from the pool (emergency or balance maintenance)
    function removeTokensFromPool(uint256 _amount) external onlyOwner {
        require(_amount <= stakingToken.balanceOf(address(this)), "Insufficient funds in pool");
        require(stakingToken.transfer(owner(), _amount), "Transfer failed");
    }
}
