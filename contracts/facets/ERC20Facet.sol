pragma solidity ^0.8.0;

import {LibAppStorage} from "../libraries/LibAppStorage.sol";

contract ERC20Facet {
    LibAppStorage.Layout layout;

    function initStakeToken() external {
        layout.stakeToken.name = "PYDE";
        layout.stakeToken.symbol = "PYD";
        layout.stakeToken.totalSupply = 100000 * 10 ** 18;
        layout.stakeToken.balanceOf[msg.sender] = layout.stakeToken.totalSupply;
    }

    function transfer(address recipient, uint256 amount) external {
        require(
            layout.stakeToken.balanceOf[msg.sender] >= amount,
            "INSUFFICIENT_BALANCE"
        );
        layout.stakeToken.balanceOf[msg.sender] -= amount;
        layout.stakeToken.balanceOf[recipient] += amount;
    }

    function getAllowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return layout.stakeToken.allowance[owner][spender];
    }

    function approve(address spender, uint256 amount) external {
        layout.stakeToken.allowance[msg.sender][spender] = amount;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external {
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
    }

    function balanceOf(address account) external view returns (uint256) {
        return layout.stakeToken.balanceOf[account];
    }

    function getTotalSupply() external view returns (uint256) {
        return layout.stakeToken.totalSupply;
    }
}
