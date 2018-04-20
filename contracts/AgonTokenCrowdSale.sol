pragma solidity ^0.4.18;

import "./AgonToken.sol";
import "./crowdsale/CappedCrowdsale.sol";
import "./crowdsale/IndividuallyFixedCappedCrowdsale.sol";
import "./crowdsale/RefundableCrowdsale.sol";
import "./crowdsale/StandardTokenCrowdsale.sol";
import "./crowdsale/WhitelistedCrowdsale.sol";
import "./ownership/Ownable.sol";

/**
 * @title IndividuallyFixedCappedCrowdsale
 * @dev Crowdsale with a fixed per-user caps. IndividuallyFixedCappedCrowdsale is developed based on
 * OpenZeppelin's IndividuallyCappedCrowdsale and Request Network's RequestTokenSale
 */
contract AgonTokenCrowdSale is Ownable, StandardTokenCrowdsale, WhitelistedCrowdsale, RefundableCrowdsale, IndividuallyFixedCappedCrowdsale, CappedCrowdsale {

    using SafeMath for uint256;

    // Initial Agon Token supply
    uint public constant DECIMALS = 18;
    uint256 public constant INITIAL_AGON_TOKEN_SUPPLY = 240000000*(10**DECIMALS); // 240 million x 18 decimals to represent in wei

    // Agon team wallet and initial token amount distributed to founder team (17.5%, to be vested)
    address public constant AGON_TEAM_VESTING_WALLET = 0x123;
    uint256 public constant AGON_TEAM_VESTING_AMOUNT = 42000000e18;

    // Agon reserve early investor wallet and initial token amount for sale for early investors (10%)
    address public constant AGON_EARLY_INVESTOR_WALLET = 0x456;
    uint256 public constant AGON_EARLY_INVESTOR_AMOUNT = 24000000e18;

    // Agon reserve token for airdrop later (4%)
    address public constant AGON_AIRDROP_WALLET = 0x789;
    uint256 public constant AGON_AIRDROP_AMOUNT = 9600000e18;

    // Agon bounty wallet and initial token amount distributed to bounty hunters! (5%)
    address public constant AGON_BOUNTY_WALLET = 0x789;
    uint256 public constant AGON_BOUNTY_AMOUNT = 12000000e18;

    uint256 public AGON_CROWDSALE_TOKEN_AMOUNT = 0;

    // Agon beneficiary MultiSig wallet to collect fund, same as team vesting wallet
    address public constant AGON_BENEFICIARY_WALLET = AGON_TEAM_VESTING_WALLET;

    // Soft cap of the token sale in ether. If token sale fails to hit soft cap, contributed ether will be refunded.
    uint256 private constant SOFT_CAP_IN_WEI = 1000 ether;

    // Hard cap of the token sale in ether
    uint256 private constant HARD_CAP_IN_WEI = 7000 ether;

    // Fixed cap wei limit for individual contribution
    uint256 public constant AGON_INDIVIDUAL_CAP = 6000000e18;

    // Start timestamp of each phase in token sale. Phase 0 is pre-sale. Public sale starts at Phase 1.
    uint256 public phase0StartTime;

    uint256 public phase1StartTime;

    uint256 public phase2StartTime;

    uint256 public phase3StartTime;

    // Token sale rate from ETH to AGN
    uint256 private constant RATE_ETH_AGN = 20000;

    // Rate of bonus token from ETH to AGN
    // Phase 0 - Presale - 40% bonus
    uint256 public constant RATE_ETH_AGN_PHASE_0_BONUS = 8000;

    // Phase 1 - 25% bonus
    uint256 public constant RATE_ETH_AGN_PHASE_1_BONUS = 5000;

    // Phase 2 - 15% bonus
    uint256 public constant RATE_ETH_AGN_PHASE_2_BONUS = 3000;

    // Phase 3 - 0% bonus
    uint256 public constant RATE_ETH_AGN_PHASE_3_BONUS = 0;

    function AgonTokenCrowdSale(uint256 _startTime, uint256 _endTime)
        CappedCrowdsale(HARD_CAP_IN_WEI)
        IndividuallyFixedCappedCrowdsale(AGON_INDIVIDUAL_CAP)
        RefundableCrowdsale(SOFT_CAP_IN_WEI)
        StandardTokenCrowdsale(_startTime, _endTime, RATE_ETH_AGN, AGON_BENEFICIARY_WALLET) public
    {
        // Set phase start time
        // Pre-sale date (Day 1, only 1 day)
        phase0StartTime = _startTime;

        // Phase 1 (Day 2 to Day 4 inclusive. Total of 3 days)
        phase1StartTime = phase0StartTime + 1 days;

        // Phase 2 (Day 5 to Day 19 inclusive. Total of 15 days)
        phase2StartTime = phase1StartTime + 3 days;

        // Phase 3 (Day 20 to Day 35 inclusive, which is the end date. Total of 16 days)
        phase3StartTime = phase2StartTime + 15 weeks;

        require(_endTime > phase3StartTime);

        token.transfer(AGON_TEAM_VESTING_WALLET, AGON_TEAM_VESTING_AMOUNT);

        token.transfer(AGON_EARLY_INVESTOR_WALLET, AGON_EARLY_INVESTOR_AMOUNT);

        token.transfer(AGON_AIRDROP_WALLET, AGON_AIRDROP_AMOUNT);

        token.transfer(AGON_BOUNTY_WALLET, AGON_BOUNTY_AMOUNT);

        AGON_CROWDSALE_TOKEN_AMOUNT = INITIAL_AGON_TOKEN_SUPPLY.sub(AGON_TEAM_VESTING_AMOUNT);
        AGON_CROWDSALE_TOKEN_AMOUNT = AGON_CROWDSALE_TOKEN_AMOUNT.sub(AGON_EARLY_INVESTOR_AMOUNT);
        AGON_CROWDSALE_TOKEN_AMOUNT = AGON_CROWDSALE_TOKEN_AMOUNT.sub(AGON_BOUNTY_AMOUNT);
        AGON_CROWDSALE_TOKEN_AMOUNT = AGON_CROWDSALE_TOKEN_AMOUNT.sub(AGON_AIRDROP_AMOUNT);

        // Transfer the rest of tokens available for public crowd sale to crowd sale address
        token.transfer(this, AGON_CROWDSALE_TOKEN_AMOUNT);
    }

    /**
     * @dev Create Agon token contract (override createTokenContract of StandardTokenCrowdsale)
     * @return the StandardToken created
     */
    function createTokenContract() internal returns(PausableToken) {
        return new AgonToken(INITIAL_AGON_TOKEN_SUPPLY, startTime, endTime, AGON_TEAM_VESTING_WALLET);
    }

    /**
     * @dev Get current bonus rate
     * @return the bonus rate in AGN per ETH unit
     */
    function GetCurrentBonusRate() public constant returns(uint256 bonusRate) {
        // solium-disable-next-line security/no-block-members
        if (now >= phase0StartTime && now <= phase1StartTime) {
            bonusRate = RATE_ETH_AGN_PHASE_0_BONUS;

            // solium-disable-next-line security/no-block-members
        } else if (now >= phase1StartTime && now <= phase2StartTime) {
            bonusRate = RATE_ETH_AGN_PHASE_1_BONUS;

            // solium-disable-next-line security/no-block-members
        } else if (now >= phase2StartTime && now <= phase3StartTime) {
            bonusRate = RATE_ETH_AGN_PHASE_2_BONUS;

            // solium-disable-next-line security/no-block-members
        } else if (now >= phase3StartTime && now <= endTime) {
            bonusRate = RATE_ETH_AGN_PHASE_3_BONUS;
        }
    }

    /**
     * @dev Extend parent behavior requiring beneficiary to be in whitelist during pre-sale phase
     * @param _beneficiary Token purchaser
     * @param _weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        // solium-disable-next-line security/no-block-members
        if (now >= phase0StartTime && now <= phase1StartTime) {
            require(isWhitelisted(_beneficiary));
        }
    }


    /**
     * @dev Get current bonus rate. Override the base function from StandardTokenCrowdsale
     * @param _weiAmount Value in wei to be converted into bonus tokens
     * @return Number of bonus tokens that will be awarded for a purchase of _weiAmount
     */
    function _getBonusTokenAmount(uint256 _weiAmount) internal view returns (uint256)
    {
        uint256 bonusRate = GetCurrentBonusRate();
        uint256 bonusTokens = _weiAmount.mul(bonusRate);

        return bonusTokens;
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