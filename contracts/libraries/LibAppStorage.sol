pragma solidity ^0.8.0;
import "../interfaces/IERC20.sol";

library LibAppStorage {
    bytes32 constant APP_STORAGE_POSITION =
        keccak256("diamond.standard.app.storage");
    uint256 public constant APY = 120; // 120% Annual Percentage Yield
    uint256 public constant SECONDS_IN_A_YEAR = 31536000; // 60 * 60 * 24 * 365
    // Struct to store user's staking data
    struct StakeData {
        uint totalStaked;
        uint lastStakedTimestamp;
    }
    struct Layout {
        IERC20 stakeToken;
        IERC20 rewardToken;
        uint rewardRate;
        mapping(address => StakeData) stakes;
    }

    function appStorage() internal pure returns (Layout storage ds) {
        bytes32 position = APP_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
