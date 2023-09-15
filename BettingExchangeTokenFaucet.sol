// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "./BettingExchangeToken.sol";

/**
 * @title BettingExchangeTokenFaucet
 * @dev A faucet contract for distributing the BettingExchangeToken for free to users.
 *      Users can request tokens once, and only if they have a balance of zero.
 */
contract BettingExchangeTokenFaucet {
    // Reference to the BettingExchangeToken contract
    BettingExchangeToken public token;

    // Maximum tokens a user can request per call
    uint256 public maxTokensPerRequest;

    // Tracks which addresses have already requested tokens
    mapping(address => bool) public hasRequested;

    // The address of the owner of the faucet, typically the deployer
    address public owner = msg.sender;

    /**
     * @dev Constructor to set the token contract address, maximum tokens per request and decimals for the token.
     * @param _tokenAddress Address of the BettingExchangeToken.
     * @param _maxTokensPerRequest Maximum tokens users can request.
     * @param _decimals Number of decimals the token uses.
     */
    constructor(address _tokenAddress, uint256 _maxTokensPerRequest, uint8 _decimals) {
        token = BettingExchangeToken(_tokenAddress);
        maxTokensPerRequest = _maxTokensPerRequest * (10 ** _decimals);
    }

    /**
     * @dev Allows users to request tokens from the faucet.
     */
    function requestTokens() public {
        require(token.balanceOf(msg.sender) == 0, "You must have 0 balance to request tokens.");
        require(!hasRequested[msg.sender], "You have already requested tokens.");

        hasRequested[msg.sender] = true;

        // Ensure that the transfer is successful
        require(token.transfer(msg.sender, maxTokensPerRequest), "Token transfer failed.");
    }

    /**
     * @dev Gets the balance of the faucet.
     * @return uint256 The balance of the faucet.
     */
    function getFaucetBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @dev Allows the owner to replenish the faucet.
     * @param _amount Amount of tokens to add to the faucet.
     */
    function replenishFaucet(uint256 _amount) external onlyOwner {
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed.");
    }

    // Modifier to ensure only the owner can call certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}
