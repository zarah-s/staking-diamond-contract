// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "forge-std/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/libraries/LibAppStorage.sol";
import "../contracts/facets/StakingFacet.sol";
import "../contracts/facets/ERC20Facet.sol";

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    StakingFacet stakingFacet;
    ERC20Facet erc20Token;

    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        erc20Token = new ERC20Facet();
        stakingFacet = new StakingFacet();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(stakingFacet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("StakingFacet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function testLayoutfacet() public {
        StakingFacet _stake = StakingFacet(address(diamond));
        address owner = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
        _stake.initStakeToken();
        uint amount = 2 * 10 ** 18;
        _stake.approve(
            address(_stake),
            amount,
            LibAppStorage.TokenType.StakeToken
        );
        _stake.stake(amount);
        vm.warp(1641070800);
        _stake.balanceOf(owner, LibAppStorage.TokenType.RewardToken);
        _stake.claimReward();
        _stake.balanceOf(owner, LibAppStorage.TokenType.RewardToken);

        // erc20Token.init();
        // erc20Token.balanceOf(owner);
        // // erc20Token.transfer(owner, amount);
        // _stake.init(address(erc20Token), address(erc20Token));
        // erc20Token.approve(address(_stake), amount);
        // erc20Token.balanceOf(address(_stake));
        // // _stake.calculateReward(msg.sender);
        // _stake.stake(1);
        // _stake.stake()
        // erc20.init();
        // // erc20.init(msg.sender, 10 * 10 ** 18);
        // address otherAccount = 0x42AcD393442A1021f01C796A23901F3852e89Ff3;
        // erc20.transfer(otherAccount, amount);
        // uint256 recipientBalance = erc20.balanceOf(otherAccount);
        // assertEq(recipientBalance, amount);
        // erc20.approve(otherAccount, amount);
        // uint allowance = erc20.allowance(owner, otherAccount);
        // assertEq(allowance, amount);
    }

    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
