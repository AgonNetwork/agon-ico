pragma solidity ^0.4.21;

import "./StandardTokenCrowdsale.sol";
import "../math/SafeMath.sol";

/**
 * @title IndividuallyFixedCappedCrowdsale
 * @dev Crowdsale with a fixed per-user caps. IndividuallyFixedCappedCrowdsale is developed based on
 * OpenZeppelin's IndividuallyCappedCrowdsale.
 */
contract IndividuallyFixedCappedCrowdsale is StandardTokenCrowdsale {
    using SafeMath for uint256;

    mapping(address => uint256) public contributions;
    uint256 public individuallyFixedCap;

    /**
     * @dev Constructor, sets a fixed cap for per-user maximum contribution.
     * @param _individuallyFixedCap Wei limit for individual contribution
     */
    function IndividuallyFixedCappedCrowdsale(uint256 _individuallyFixedCap) public {
        require(_individuallyFixedCap > 0);
        individuallyFixedCap = _individuallyFixedCap;
    }

    /**
     * @dev Returns the amount contributed so far by a sepecific user.
     * @param _beneficiary Address of contributor
     * @return User contribution so far
     */
    function getUserContribution(address _beneficiary) public view returns (uint256) {
        return contributions[_beneficiary];
    }

    /**
     * @dev Extend parent behavior requiring purchase to respect the user's funding cap.
     * @param _beneficiary Token purchaser
     * @param _weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        require(contributions[_beneficiary].add(_weiAmount) <= individuallyFixedCap);
    }

    /**
     * @dev Extend parent behavior to update user contributions
     * @param _beneficiary Token purchaser
     * @param _weiAmount Amount of wei contributed
     */
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
        super._updatePurchasingState(_beneficiary, _weiAmount);
        contributions[_beneficiary] = contributions[_beneficiary].add(_weiAmount);
    }

}