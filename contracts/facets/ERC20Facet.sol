pragma solidity ^0.8.0;

// import {LibAppStorage} from "../libraries/LibAppStorage.sol";

contract ERC20Facet {
    // LibAppStorage.Layout layout;

    string name;
    string symbol;
    uint totalSupply;
    mapping(address => uint) balance;
    mapping(address => mapping(address => uint)) allowance;

    // constructor() {
    //     init();
    // }

    function init() external {
        name = "PYDE";
        symbol = "PYD";
        totalSupply = 100000 * 10 ** 18;
        balance[msg.sender] = totalSupply;
    }

    function transfer(address recipient, uint256 amount) external {
        require(balance[msg.sender] >= amount, "INSUFFICIENT_BALANCE");
        balance[msg.sender] -= amount;
        balance[recipient] += amount;
    }

    function getAllowance(
        address owner,
        address spender
    ) external view returns (uint256) {
        return allowance[owner][spender];
    }

    function approve(address spender, uint256 amount) external {
        allowance[msg.sender][spender] = amount;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external {
        require(balance[sender] >= amount, "INSUFFICIENT_BALANCE");
        require(
            allowance[sender][recipient] >= amount,
            "INSUFFICIENT_ALLOWANCE"
        );
        balance[sender] -= amount;
        balance[recipient] += amount;
        allowance[sender][recipient] -= amount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balance[account];
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }
    // function ChangeNameAndNo(uint256 _newNo, string memory _newName) external {
    //     = _newNo;
    //     = _newName;
    // }
    // function getLayout() public view returns (LibAppStorage.Layout memory l) {
    //     l.currentNo =
    //     l.name =
    // }
}
