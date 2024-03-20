// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "../interfaces/IERC20.sol";
import {LibAppStorage} from "../libraries/LibAppStorage.sol";

error ZERO_AMOUNT();
error INSUFFICIENT_TOKEN();
error INSUFFICIENT_STAKED_TOKEN();
error NO_REWARD();

contract StakingFacet {
    function calculateReward(address user) public view returns (uint256) {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();
        LibAppStorage.StakeData storage _stake = layout.stakes[user];

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

    function stake(uint amount) external {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        if (amount < 1) {
            revert ZERO_AMOUNT();
        }

        if (layout.stakeToken.balanceOf(msg.sender) < amount) {
            revert INSUFFICIENT_TOKEN();
        }

        layout.stakeToken.transferFrom(msg.sender, address(this), amount);

        // Update staker's data
        LibAppStorage.StakeData storage _stake = layout.stakes[msg.sender];

        _stake.totalStaked = _stake.totalStaked + amount;

        _stake.lastStakedTimestamp = block.timestamp;
    }

    function unstake() external {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        LibAppStorage.StakeData storage _stake = layout.stakes[msg.sender];

        // Update staker's data
        uint reward = (calculateReward(msg.sender));

        layout.stakeToken.transfer(msg.sender, _stake.totalStaked);
        layout.rewardToken.transfer(msg.sender, reward);
        _stake.lastStakedTimestamp = block.timestamp;
        _stake.totalStaked = 0;
    }

    function claimReward() external {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        LibAppStorage.StakeData storage _stake = layout.stakes[msg.sender];

        uint reward = (calculateReward(msg.sender));

        if (reward < 1) {
            revert NO_REWARD();
        }

        _stake.lastStakedTimestamp = block.timestamp;

        layout.rewardToken.transfer(msg.sender, reward);
    }

    function getStakeInfo(
        address _user
    ) external view returns (LibAppStorage.StakeData memory data) {
        LibAppStorage.Layout storage layout = LibAppStorage.appStorage();

        data = layout.stakes[_user];
    }
}
