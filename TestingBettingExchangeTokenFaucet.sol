// Pragma statement
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

// Import statements
import "./TestingBettingExchangeToken.sol";

// Contracts

/**
 * @title TestingBettingExchangeTokenFaucet
 * @notice This contract allows users to request a specific amount of BettingExchangeToken for free, given certain conditions.
 * @dev This is typically used for testing or initial distribution purposes. Users can request tokens only once, and only if they have a balance of zero.
 */
contract TestingBettingExchangeTokenFaucet {
    // Type declarations (Enums and Structs) - [none in this contract]

    // State variables

    // Instance of the BettingExchangeToken contract
    TestingBettingExchangeToken public token;

    // Maximum amount of tokens that a user can request at once
    uint256 public maxTokensPerRequest;

    // Mapping to keep track of which addresses have already requested tokens
    mapping(address => bool) public hasRequested;

    // Owner's address, typically the deployer of this contract
    address public owner = msg.sender;

    // Mapping to blacklist certain addresses from requesting tokens
    mapping(address => bool) public isBlacklisted;

    // Events

    // Event emitted when the ownership of the contract is transferred
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // Event emitted when an address is blacklisted
    event Blacklisted(address indexed user);

    // Modifiers

    // Ensures that only the owner can execute certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Ensures that blacklisted addresses cannot execute certain functions
    modifier notBlacklisted() {
        require(
            !isBlacklisted[msg.sender],
            "You are blacklisted from requesting tokens"
        );
        _;
    }

    // Constructor

    /**
     * @notice Creates an instance of the BettingExchangeTokenFaucet contract.
     * @param _tokenAddress The address of the BettingExchangeToken contract.
     * @param _maxTokensPerRequest The maximum amount of tokens that a user can request.
     * @param _decimals The number of decimals used in the token, for precision.
     */
    constructor(
        address _tokenAddress,
        uint256 _maxTokensPerRequest,
        uint8 _decimals
    ) {
        token = TestingBettingExchangeToken(_tokenAddress);
        maxTokensPerRequest = _maxTokensPerRequest * (10**_decimals);
    }

    // Public functions

    /**
     * @notice Allows eligible users to request tokens from the faucet.
     * @dev Users must meet the criteria defined by having a zero balance and not having requested before.
     */
    function requestTokens() public notBlacklisted {
        require(
            token.balanceOf(msg.sender) == 0,
            "You must have 0 balance to request tokens."
        );
        require(
            !hasRequested[msg.sender],
            "You have already requested tokens."
        );

        hasRequested[msg.sender] = true;
        require(
            token.transfer(msg.sender, maxTokensPerRequest),
            "Token transfer failed."
        );
    }

    /**
     * @notice Fetches the balance of tokens currently held by the faucet.
     * @return uint256 The balance of tokens in the faucet.
     */
    function getFaucetBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // External functions

    /**
     * @notice Enables the owner to transfer the ownership of the faucet to a new address.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address.");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @notice Adds an address to the blacklist, preventing them from requesting tokens.
     * @param user The address to be blacklisted.
     */
    function blacklistUser(address user) external onlyOwner {
        require(!isBlacklisted[user], "User is already blacklisted.");
        isBlacklisted[user] = true;
        emit Blacklisted(user);
    }

    // Internal functions
    // [none in this contract]

    // Private functions
    // [none in this contract]
}
