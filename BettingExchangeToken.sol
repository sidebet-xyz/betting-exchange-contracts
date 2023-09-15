// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// This contract represents a betting exchange token, where users can place, accept, and settle bets.
contract BettingExchangeToken is ERC20 {
    using Counters for Counters.Counter;

    // Counter for unique bet IDs
    Counters.Counter public betsIds;

    // Default oracle who can referee and settle bets
    address public refereeOracle;

    // Address of the emergency oracle, which has the power to change the oracle address of any bet at any time,
    // irrespective of its current state. This can be useful in situations where the designated oracle might
    // be compromised, unresponsive, or there's any other unexpected event requiring immediate intervention.
    address public emergencyOracle;

    // Owner of the contract, typically the deployer
    address public owner = msg.sender;

    // Struct representing a single bet
    struct Bet {
        address alice; // Address of the person who created the bet
        address bob; // Address of the person who accepted the bet
        uint256 amount; // Amount of tokens staked in the bet
        bool isActive; // Flag indicating if the bet has been accepted
        bool isListed; // Flag indicating if the bet is currently listed and active
        bool isCanceled; // Flag indicating if the bet was canceled by its creator
        address oracle; // Oracle's address responsible for settling the bet
    }

    // Mapping of bet ID to Bet struct
    mapping(uint256 => Bet) private idToBet;

    // Mapping of settled bet IDs to Bet struct
    mapping(uint256 => Bet) private settledBets;

    // Mapping of canceled bet IDs to Bet struct
    mapping(uint256 => Bet) private canceledBets;

    // Event emitted when a new bet is created
    event BetCreated(
        uint256 indexed betId,
        address indexed alice,
        uint256 amount,
        address indexed oracle
    );

    // Event emitted when a bet is accepted by another user
    event BetAccepted(uint256 indexed betId, address indexed bob);

    // Event emitted when a bet is settled by the oracle
    event BetSettled(
        uint256 indexed betId,
        address indexed winner,
        address indexed oracle
    );

    // Event emitted when a bet's oracle is updated
    event BetOracleUpdated(
        uint256 indexed betId,
        address indexed oldOracle,
        address indexed newOracle
    );

    // Event emitted when a bet is canceled by its creator
    event BetCanceled(uint256 indexed betId, address indexed alice);

    // Modifier to ensure only the owner can call certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Constructor for initializing the betting token with a default oracle
    constructor(address _refereeOracle, address _emergencyOracle)
        ERC20("Betting Exchange Token", "BET")
    {
        _mint(msg.sender, 147000000 * 10**decimals());
        refereeOracle = _refereeOracle;
        emergencyOracle = _emergencyOracle;
    }

    // Function to set or update the default oracle
    function setRefereeOracle(address _newOracle) public onlyOwner {
        refereeOracle = _newOracle;
    }

    /// Function to create a new bet
    function createBet(uint256 _amount, address _oracle) public {
        require(
            balanceOf(msg.sender) >= _amount,
            "Insufficient funds to create bet."
        );
        _transfer(msg.sender, address(this), _amount);

        // Decide the oracle for the bet. Use default if none provided.
        address oracleToUse = (_oracle == address(0)) ? refereeOracle : _oracle;

        // Increment the counter to get a new unique bet ID
        betsIds.increment();
        idToBet[betsIds.current()] = Bet(
            msg.sender,
            address(0),
            _amount,
            false,
            true,
            false,
            oracleToUse
        );

        emit BetCreated(betsIds.current(), msg.sender, _amount, oracleToUse);
    }

    // Function to read details about a specific bet
    function readBet(uint256 _betId)
        public
        view
        returns (
            address alice,
            address bob,
            uint256 amount,
            bool isActive,
            bool isListed,
            bool isCanceled,
            address oracle
        )
    {
        Bet memory bet = idToBet[_betId];
        return (
            bet.alice,
            bet.bob,
            bet.amount,
            bet.isActive,
            bet.isListed,
            bet.isCanceled,
            bet.oracle
        );
    }

    // Function to update the oracle of a specific bet
    function updateBetOracle(uint256 _betId, address _newOracle) public {
        require(
            _newOracle != address(0),
            "New oracle address cannot be the zero address."
        );

        Bet storage bet = idToBet[_betId];
        require(bet.alice != address(0), "Bet does not exist."); // Check if the bet exists

        // The emergency oracle can change the oracle address at any time.
        // Alice can change it only if the bet hasn't been accepted yet.
        require(
            msg.sender == emergencyOracle ||
                (msg.sender == bet.alice && bet.bob == address(0)),
            "Unauthorized to change the oracle."
        );

        address oldOracle = bet.oracle;
        bet.oracle = _newOracle;

        emit BetOracleUpdated(_betId, oldOracle, _newOracle);
    }

    // Function for another user to accept an existing bet
    function acceptBet(uint256 _betId) public {
        Bet storage bet = idToBet[_betId];

        require(bet.isListed, "Bet is not listed or does not exist.");
        require(bet.bob == address(0), "Bet already accepted.");
        require(
            balanceOf(msg.sender) >= bet.amount,
            "Insufficient funds to accept bet."
        );
        require(msg.sender != bet.alice, "Alice cannot accept her own bet.");

        // Transfer the bet amount from Bob to the contract
        _transfer(msg.sender, address(this), bet.amount);

        // Update the bet details indicating that Bob has accepted the bet
        bet.bob = msg.sender;
        bet.isActive = true;

        emit BetAccepted(_betId, msg.sender);
    }

    // Function for the oracle to settle a bet, determining a winner
    function settleBet(uint256 _betId, address _winner) public {
        Bet storage bet = idToBet[_betId];
        uint256 totalAmount = bet.amount * 2;

        require(
            bet.isListed && bet.isActive,
            "Bet is not listed, not active or does not exist."
        );
        require(
            msg.sender == bet.oracle,
            "Only the designated oracle can settle this bet."
        );
        require(
            _winner == bet.alice || _winner == bet.bob,
            "Winner must be either Alice or Bob."
        );

        _transfer(address(this), _winner, totalAmount);
        bet.isListed = false;
        bet.isActive = false;

        // Move the bet to settledBets mapping
        settledBets[_betId] = bet;

        // Delete the bet from idToBet mapping
        delete idToBet[_betId];

        emit BetSettled(_betId, _winner, bet.oracle);
    }

    // Function for the creator of the bet to cancel it
    function cancelBet(uint256 _betId) public {
        Bet storage bet = idToBet[_betId];

        // Various checks to ensure the legitimacy of the cancellation request
        require(bet.alice != address(0), "Bet does not exist.");
        require(
            msg.sender == bet.alice,
            "Only the creator can cancel the bet."
        );
        require(!bet.isActive, "Bet is already active.");
        require(bet.isListed, "Bet is not listed.");

        // Refund the bet amount to Alice
        _transfer(address(this), bet.alice, bet.amount);

        // Update bet status
        bet.isListed = false;
        bet.isCanceled = true;

        // Archive the bet in the canceledBets mapping
        canceledBets[_betId] = bet;

        // Remove the bet from active bets mapping
        delete idToBet[_betId];

        emit BetCanceled(_betId, bet.alice);
    }
}
