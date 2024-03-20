pragma solidity ^0.8.0;

import {LibAppStorage} from "../libraries/LibAppStorage.sol";

contract ERC20Facet {
    // LibAppStorage.Layout layout;
    // function init() external {
    //     layout.token.name = "PYDE";
    //     layout.token.symbol = "PYD";
    //     layout.token.totalSupply = 100000 * 10 ** 18;
    //     layout.token.balanceOf[msg.sender] = layout.token.totalSupply;
    // }
    // function transfer(address recipient, uint256 amount) external {
    //     require(
    //         layout.token.balanceOf[msg.sender] >= amount,
    //         "INSUFFICIENT_BALANCE"
    //     );
    //     layout.token.balanceOf[msg.sender] -= amount;
    //     layout.token.balanceOf[recipient] += amount;
    // }
    // function allowance(
    //     address owner,
    //     address spender
    // ) external view returns (uint256) {
    //     return layout.token.allowance[owner][spender];
    // }
    // function approve(address spender, uint256 amount) external {
    //     layout.token.allowance[msg.sender][spender] = amount;
    // }
    // function transferFrom(
    //     address sender,
    //     address recipient,
    //     uint256 amount
    // ) external {
    //     require(
    //         layout.token.balanceOf[sender] >= amount,
    //         "INSUFFICIENT_BALANCE"
    //     );
    //     require(
    //         layout.token.allowance[sender][recipient] >= amount,
    //         "INSUFFICIENT_ALLOWANCE"
    //     );
    //     layout.token.balanceOf[sender] -= amount;
    //     layout.token.balanceOf[recipient] += amount;
    //     layout.token.allowance[sender][recipient] -= amount;
    // }
    // function balanceOf(address account) external view returns (uint256) {
    //     return layout.token.balanceOf[account];
    // }
    // function totalSupply() external view returns (uint256) {
    //     return layout.token.totalSupply;
    // }
    // function ChangeNameAndNo(uint256 _newNo, string memory _newName) external {
    //     layout.currentNo = _newNo;
    //     layout.name = _newName;
    // }
    // function getLayout() public view returns (LibAppStorage.Layout memory l) {
    //     l.currentNo = layout.currentNo;
    //     l.name = layout.name;
    // }
}
