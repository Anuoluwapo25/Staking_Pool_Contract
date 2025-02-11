# Staking Pool Smart Contract

## Overview
This repository contains a Solidity-based staking platform that allows users to stake ERC20 tokens and earn rewards. The system consists of two main contracts:
- `StakingToken.sol`: An ERC20 token that can be used for staking and rewards
- `StakingPool.sol`: The main staking contract that handles deposits, rewards, and withdrawals

## Features
- 90-day lock period for staked tokens
- 15% Annual Percentage Rate (APR) for rewards
- Owner-only emergency withdrawal function
- Comprehensive staking information tracking

## Contract Details

### StakingToken Contract
```solidity
contract StakingToken is ERC20, Ownable
```
- Standard ERC20 token with minting capability
- Only owner can mint new tokens
- Inherits from OpenZeppelin's ERC20 and Ownable contracts

### StakingPool Contract
```solidity
contract StakingPool is Ownable
```
- Manages staking operations and reward distribution
- Uses two ERC20 tokens: one for staking and one for rewards
- Tracks individual stakes and total staked amount

## Key Functions

### Staking Functions
1. `stake(uint256 _amount)`
   - Allows users to stake tokens
   - Requires approval for token transfer
   - One stake per address at a time

2. `unstake()`
   - Withdraws staked tokens after lock period
   - Automatically claims any earned rewards
   - Deletes stake information after withdrawal

3. `calculateRewards(address _staker)`
   - Calculates current rewards for a staker
   - Based on stake amount, time staked, and APR
   - Returns 0 if lock period not met

### View Functions
1. `getStakeInfo(address _staker)`
   - Returns complete staking information
   - Includes amount, timestamp, rewards, and existence

### Admin Functions
1. `withdrawRewardTokens(uint256 _amount)`
   - Owner-only emergency function
   - Allows withdrawal of reward tokens

## Installation

1. Install dependencies:
```bash
npm install @openzeppelin/contracts
```

2. Compile contracts:
```bash
npx hardhat compile
```

## Deployment

1. Deploy StakingToken for both staking and rewards:
```javascript
const StakingToken = await ethers.getContractFactory("StakingToken");
const stakingToken = await StakingToken.deploy("Staking Token", "STK", initialSupply);
const rewardToken = await StakingToken.deploy("Reward Token", "RWD", initialSupply);
```

2. Deploy StakingPool:
```javascript
const StakingPool = await ethers.getContractFactory("StakingPool");
const stakingPool = await StakingPool.deploy(stakingToken.address, rewardToken.address);
```

## Usage

1. Approve token spending:
```javascript
await stakingToken.approve(stakingPool.address, amount);
```

2. Stake tokens:
```javascript
await stakingPool.stake(amount);
```

3. Check rewards:
```javascript
const rewards = await stakingPool.calculateRewards(userAddress);
```

4. Unstake tokens (after lock period):
```javascript
await stakingPool.unstake();
```

## Security Considerations
- Implements reentrancy guard using isProcessing flag
- State changes before external calls
- Requires explicit approval for token transfers
- Owner-only functions for emergency situations
- Lock period to prevent quick withdrawals

## Testing
1. Run tests:
```bash
npx hardhat test
```

## License
This project is licensed under the MIT License.

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## Support
For support and questions, please open an issue in the repository.# Staking Pool Smart Contract

## Overview
This repository contains a Solidity-based staking platform that allows users to stake ERC20 tokens and earn rewards. The system consists of two main contracts:
- `StakingToken.sol`: An ERC20 token that can be used for staking and rewards
- `StakingPool.sol`: The main staking contract that handles deposits, rewards, and withdrawals

## Features
- 90-day lock period for staked tokens
- 15% Annual Percentage Rate (APR) for rewards
- Protection against reentrancy attacks
- Owner-only emergency withdrawal function
- Comprehensive staking information tracking

## Contract Details

### StakingToken Contract
```solidity
contract StakingToken is ERC20, Ownable
```
- Standard ERC20 token with minting capability
- Only owner can mint new tokens
- Inherits from OpenZeppelin's ERC20 and Ownable contracts

### StakingPool Contract
```solidity
contract StakingPool is Ownable
```
- Manages staking operations and reward distribution
- Uses two ERC20 tokens: one for staking and one for rewards
- Tracks individual stakes and total staked amount

## Key Functions

### Staking Functions
1. `stake(uint256 _amount)`
   - Allows users to stake tokens
   - Requires approval for token transfer
   - One stake per address at a time

2. `unstake()`
   - Withdraws staked tokens after lock period
   - Automatically claims any earned rewards
   - Deletes stake information after withdrawal

3. `calculateRewards(address _staker)`
   - Calculates current rewards for a staker
   - Based on stake amount, time staked, and APR
   - Returns 0 if lock period not met

### View Functions
1. `getStakeInfo(address _staker)`
   - Returns complete staking information
   - Includes amount, timestamp, rewards, and existence

### Admin Functions
1. `withdrawRewardTokens(uint256 _amount)`
   - Owner-only emergency function
   - Allows withdrawal of reward tokens

## Installation

1. Install dependencies:
```bash
npm install @openzeppelin/contracts
```

2. Compile contracts:
```bash
npx hardhat compile
```

## Deployment

1. Deploy StakingToken for both staking and rewards:
```javascript
const StakingToken = await ethers.getContractFactory("StakingToken");
const stakingToken = await StakingToken.deploy("Staking Token", "STK", initialSupply);
const rewardToken = await StakingToken.deploy("Reward Token", "RWD", initialSupply);
```

2. Deploy StakingPool:
```javascript
const StakingPool = await ethers.getContractFactory("StakingPool");
const stakingPool = await StakingPool.deploy(stakingToken.address, rewardToken.address);
```

## Usage

1. Approve token spending:
```javascript
await stakingToken.approve(stakingPool.address, amount);
```

2. Stake tokens:
```javascript
await stakingPool.stake(amount);
```

3. Check rewards:
```javascript
const rewards = await stakingPool.calculateRewards(userAddress);
```

4. Unstake tokens (after lock period):
```javascript
await stakingPool.unstake();
```

## Security Considerations
- Implements reentrancy guard using isProcessing flag
- State changes before external calls
- Requires explicit approval for token transfers
- Owner-only functions for emergency situations
- Lock period to prevent quick withdrawals

## Testing
1. Run tests:
```bash
npx hardhat test
```

## License
This project is licensed under the MIT License.

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## Support
For support and questions, please open an issue in the repository.


