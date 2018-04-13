pragma solidity ^0.4.18;

import "./AgonToken.sol";
import "./crowdsale/CappedCrowdsale.sol";
import "./crowdsale/IndividuallyFixedCappedCrowdsale.sol";
import "./ownership/Ownable.sol";

/**
 * @title IndividuallyFixedCappedCrowdsale
 * @dev Crowdsale with a fixed per-user caps. IndividuallyFixedCappedCrowdsale is developed based on
 * OpenZeppelin's IndividuallyCappedCrowdsale and Request Network's RequestTokenSale
 */
contract AgonTokenCrowdSale is Ownable, CappedCrowdsale, IndividuallyFixedCappedCrowdsale {

    using SafeMath for uint256;

    // Initial Agon Token supply
    uint public constant DECIMALS = 18;
    uint256 public constant INITIAL_AGON_TOKEN_SUPPLY = 200000000*(10**DECIMALS); // 200 million x 18 decimals to represent in wei

    // Agon team wallet and initial token amount distributed to founder team (15%, to be vested)
    address public constant AGON_TEAM_VESTING_WALLET = 0x123;
    uint256 public constant AGON_TEAM_VESTING_AMOUNT = 30000000e18;

    // Agon reserve early investor wallet and initial token amount for sale for early investors (10%)
    address public constant AGON_EARLY_INVESTOR_WALLET = 0x456;
    uint256 public constant AGON_EARLY_INVESTOR_AMOUNT = 20000000e18;

    // Agon bounty wallet and initial token amount distributed to bounty hunters! (5%)
    address public constant AGON_BOUNTY_WALLET = 0x789;
    uint256 public constant AGON_BOUNTY_AMOUNT = 10000000e18;

    // Agon beneficiary MultiSig wallet to collect fund, same as team vesting wallet
    address public constant AGON_BENEFICIARY_WALLET = AGON_TEAM_VESTING_WALLET;

    // Hard cap of the token sale in ether
    uint256 private constant HARD_CAP_IN_WEI = 7000 ether;

    // Fixed cap wei limit for individual contribution
    uint256 public constant AGON_INDIVIDUAL_CAP = 5000000e18;

    // Token sale rate from ETH to AGN
    uint256 private constant RATE_ETH_AGN = 20000;

    function AgonTokenCrowdSale(uint256 _startTime, uint256 _endTime)
        IndividuallyFixedCappedCrowdsale(AGON_INDIVIDUAL_CAP)
        CappedCrowdsale(HARD_CAP_IN_WEI)
        StandardTokenCrowdsale(_startTime, _endTime, RATE_ETH_AGN, AGON_BENEFICIARY_WALLET) public
    {
        token.transfer(AGON_TEAM_VESTING_WALLET, AGON_TEAM_VESTING_AMOUNT);

        token.transfer(AGON_EARLY_INVESTOR_WALLET, AGON_EARLY_INVESTOR_AMOUNT);

        token.transfer(AGON_BOUNTY_WALLET, AGON_BOUNTY_AMOUNT);
    }

    /**
     * @dev Create Agon token contract (override createTokenContract of StandardTokenCrowdsale)
     * @return the StandardToken created
     */
    function createTokenContract() internal returns(StandardToken) {
        return new AgonToken(INITIAL_AGON_TOKEN_SUPPLY, startTime, endTime, AGON_TEAM_VESTING_WALLET);
    }

    /**
     * @dev Burn all the unsold tokens
     */
    function burnRemainingTokens() public onlyOwner {
        require(hasEnded());
        uint256 tokensToBurn = token.balanceOf(this);
        token.burn(tokensToBurn);
    }
}