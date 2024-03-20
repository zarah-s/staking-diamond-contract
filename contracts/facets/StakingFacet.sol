// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "../interfaces/IERC20.sol";
import {LibAppStorage} from "../libraries/LibAppStorage.sol";

error ZERO_AMOUNT();
error INSUFFICIENT_TOKEN();
error INSUFFICIENT_STAKED_TOKEN();
error NO_REWARD();

contract StakingFacet {
    function initStakeToken() external {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        layout.stakeToken.name = "PYDE";
        layout.stakeToken.symbol = "PYD";
        layout.stakeToken.totalSupply = 100000 * 10 ** 18;
        layout.stakeToken.balanceOf[msg.sender] = layout.stakeToken.totalSupply;
    }

    function initRewardToken() external {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        layout.stakeToken.name = "PYDEReward";
        layout.stakeToken.symbol = "PYDR";
        layout.stakeToken.totalSupply = 100000 * 10 ** 18;
        // layout.stakeToken.balanceOf[msg.sender] = layout.stakeToken.totalSupply;
    }

    function transfer(
        address recipient,
        uint256 amount,
        LibAppStorage.TokenType tokenType
    ) public {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        if (tokenType == LibAppStorage.TokenType.StakeToken) {
            require(
                layout.stakeToken.balanceOf[msg.sender] >= amount,
                "INSUFFICIENT_BALANCE"
            );
            layout.stakeToken.balanceOf[msg.sender] -= amount;
            layout.stakeToken.balanceOf[recipient] += amount;
        } else {
            require(
                layout.stakeToken.balanceOf[msg.sender] >= amount,
                "INSUFFICIENT_BALANCE"
            );
            layout.stakeToken.balanceOf[msg.sender] -= amount;
            layout.rewardToken.balanceOf[recipient] += amount;
        }
    }

    function getAllowance(
        address owner,
        address spender,
        LibAppStorage.TokenType tokenType
    ) public view returns (uint256) {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        if (tokenType == LibAppStorage.TokenType.StakeToken) {
            return layout.stakeToken.allowance[owner][spender];
        } else {
            return layout.stakeToken.allowance[owner][spender];
        }
    }

    function approve(
        address spender,
        uint256 amount,
        LibAppStorage.TokenType tokenType
    ) public {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        if (tokenType == LibAppStorage.TokenType.StakeToken) {
            layout.stakeToken.allowance[msg.sender][spender] = amount;
        } else {
            layout.rewardToken.allowance[msg.sender][spender] = amount;
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount,
        LibAppStorage.TokenType tokenType
    ) public {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        if (tokenType == LibAppStorage.TokenType.StakeToken) {
            require(
                layout.stakeToken.balanceOf[sender] >= amount,
                "INSUFFICIENT_BALANCE"
            );
            require(
                layout.stakeToken.allowance[sender][recipient] >= amount,
                "INSUFFICIENT_ALLOWANCE"
            );
            layout.stakeToken.balanceOf[sender] -= amount;
            layout.stakeToken.balanceOf[recipient] += amount;
            layout.stakeToken.allowance[sender][recipient] -= amount;
        } else {
            require(
                layout.rewardToken.balanceOf[sender] >= amount,
                "INSUFFICIENT_BALANCE"
            );
            require(
                layout.rewardToken.allowance[sender][recipient] >= amount,
                "INSUFFICIENT_ALLOWANCE"
            );
            layout.rewardToken.balanceOf[sender] -= amount;
            layout.rewardToken.balanceOf[recipient] += amount;
            layout.rewardToken.allowance[sender][recipient] -= amount;
        }
    }

    function balanceOf(
        address account,
        LibAppStorage.TokenType tokenType
    ) public view returns (uint256) {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        if (tokenType == LibAppStorage.TokenType.StakeToken) {
            return layout.stakeToken.balanceOf[account];
        } else {
            return layout.rewardToken.balanceOf[account];
        }
    }

    function getTotalSupply(
        LibAppStorage.TokenType tokenType
    ) public view returns (uint256) {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        if (tokenType == LibAppStorage.TokenType.StakeToken) {
            return layout.stakeToken.totalSupply;
        } else {
            return layout.rewardToken.totalSupply;
        }
    }

    function calculateReward(address user) public view returns (uint256) {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();
        LibAppStorage.StakeData storage _stake = layout.stake.stakes[user];

        uint256 stakedTimeInSeconds = block.timestamp -
            _stake.lastStakedTimestamp;
        uint256 stakedAmount = _stake.totalStaked;
        uint256 reward = (stakedAmount *
            LibAppStorage.APY *
            stakedTimeInSeconds) /
            LibAppStorage.SECONDS_IN_A_YEAR /
            100;
        return reward;
    }

    // function getToken() external view returns (address) {
    //     LibAppStorage.Layout storage layout = LibAppStorage.appStorage();
    //     return address(layout.stakeToken);
    // }

    function stake(uint amount) external {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        if (amount < 1) {
            revert ZERO_AMOUNT();
        }

        if (
            balanceOf(msg.sender, LibAppStorage.TokenType.StakeToken) < amount
        ) {
            revert INSUFFICIENT_TOKEN();
        }

        transferFrom(
            msg.sender,
            address(this),
            amount,
            LibAppStorage.TokenType.StakeToken
        );

        // Update staker's data
        LibAppStorage.StakeData storage _stake = layout.stake.stakes[
            msg.sender
        ];

        _stake.totalStaked = _stake.totalStaked + amount;

        _stake.lastStakedTimestamp = block.timestamp;
    }

    function unstake() external {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        LibAppStorage.StakeData storage _stake = layout.stake.stakes[
            msg.sender
        ];

        // Update staker's data
        uint reward = (calculateReward(msg.sender));

        transfer(
            msg.sender,
            _stake.totalStaked,
            LibAppStorage.TokenType.StakeToken
        );
        transfer(msg.sender, reward, LibAppStorage.TokenType.RewardToken);
        _stake.lastStakedTimestamp = block.timestamp;
        _stake.totalStaked = 0;
    }

    function claimReward() external {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        LibAppStorage.StakeData storage _stake = layout.stake.stakes[
            msg.sender
        ];

        uint reward = (calculateReward(msg.sender));

        if (reward < 1) {
            revert NO_REWARD();
        }

        _stake.lastStakedTimestamp = block.timestamp;

        transfer(msg.sender, reward, LibAppStorage.TokenType.RewardToken);
    }

    function getStakeInfo(
        address _user
    ) external view returns (LibAppStorage.StakeData memory data) {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        data = layout.stake.stakes[_user];
    }
}
