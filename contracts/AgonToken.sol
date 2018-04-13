pragma solidity ^0.4.18;

import "./math/SafeMath.sol";
import "./token/PausableToken.sol";

/**
 * @title Agon Token
 */
contract AgonToken is PausableToken {
    string public constant NAME = "AgonToken";
    string public constant SYMBOL = "AGN";

    uint public fundingStartTime;
    uint public fundingEndTime;

    address public tokenSaleContract;

    /**
     * @dev Contructor that gives msg.sender all of existing tokens.
     */
    function AgonToken(uint256 initialSupply, uint startTime, uint endTime, address admin) public {

        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
        emit Transfer(0x0, msg.sender, initialSupply);

        fundingStartTime = startTime;
        fundingEndTime = endTime;

        tokenSaleContract = msg.sender;
        transferOwnership(admin);
    }
}