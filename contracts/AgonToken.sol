pragma solidity ^0.4.18;

import "./math/SafeMath.sol";
import "./token/PausableToken.sol";

/**
* @title Agon Token
*/
contract AgonToken is PausableToken {
    string public constant NAME = "AgonToken";
    string public constant SYMBOL = "AGN";
    uint public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 200000000*(10**DECIMALS); // 200 million x 18 decimals to represent in wei

    uint public fundingStartTime;
    uint public fundingEndTime;

    address public tokenSaleContractAddr;

    /**
     * @dev Contructor that gives msg.sender all of existing tokens.
     */
    function AgonToken(uint startTime, uint endTime, address admin) public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);

        fundingStartTime = startTime;
        fundingEndTime = endTime;

        tokenSaleContractAddr = msg.sender;
        transferOwnership(admin);
    }
}