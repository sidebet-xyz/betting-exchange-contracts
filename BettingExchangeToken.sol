// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title BettingExchangeToken
 * @dev This contract represents a betting exchange token, allowing users
 * to place, accept, and settle bets.
 */
contract BettingExchangeToken is ERC20 {
    using Counters for Counters.Counter;

    // Counter for unique bet IDs
    Counters.Counter public betIds;

    // Default oracle responsible for refereeing and settling bets
    address public refereeOracle;

    // Oracle with emergency privileges to override and update oracles for bets
    address public emergencyOracle;

    // Owner of the contract, typically the deployer
    address public owner = msg.sender;

    // Struct representing a single bet
    struct Bet {
        address alice; // Creator of the bet
        address bob; // Acceptor of the bet
        uint256 amount; // Amount of tokens staked in the bet
        bool isActive; // True if the bet is currently active and accepted
        bool isListed; // True if the bet is currently listed and active
        bool isCanceled; // True if the bet was canceled by its creator
        address oracle; // Oracle responsible for settling the bet
    }

    // Mapping from bet ID to the Bet struct
    mapping(uint256 => Bet) private idToBet;

    // Mapping of settled bet IDs to Bet struct
    mapping(uint256 => Bet) private settledBets;

    // Mapping of canceled bet IDs to Bet struct
    mapping(uint256 => Bet) private canceledBets;

    // Events
    event BetCreated(
        uint256 indexed betId,
        address indexed alice,
        uint256 amount,
        address indexed oracle
    );
    event BetAccepted(uint256 indexed betId, address indexed bob);
    event BetSettled(
        uint256 indexed betId,
        address indexed winner,
        address indexed oracle
    );
    event BetOracleUpdated(
        uint256 indexed betId,
        address indexed oldOracle,
        address indexed newOracle
    );
    event BetCanceled(uint256 indexed betId, address indexed alice);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    /**
     * @dev Constructor for initializing the betting token.
     * @param _refereeOracle Address of the default referee oracle.
     * @param _emergencyOracle Address of the emergency oracle.
     */
    constructor(address _refereeOracle, address _emergencyOracle)
        ERC20("Betting Exchange Token", "BET")
    {
        _mint(msg.sender, 22000000 * 10**decimals());
        refereeOracle = _refereeOracle;
        emergencyOracle = _emergencyOracle;
    }

    /**
     * @dev Allows the owner to set or update the default oracle.
     * @param _newOracle Address of the new default oracle.
     */
    function setRefereeOracle(address _newOracle) public onlyOwner {
        refereeOracle = _newOracle;
    }

    /**
     * @dev Allows users to create a new bet.
     * @param _amount Amount of tokens to be staked for the bet.
     * @param _oracle Address of the oracle to be used. If not provided, the default oracle is used.
     */
    function createBet(uint256 _amount, address _oracle) public {
        require(
            balanceOf(msg.sender) >= _amount,
            "Insufficient funds to create bet."
        );
        _transfer(msg.sender, address(this), _amount);

        address oracleToUse = (_oracle == address(0)) ? refereeOracle : _oracle;

        betIds.increment();
        idToBet[betIds.current()] = Bet(
            msg.sender,
            address(0),
            _amount,
            false,
            true,
            false,
            oracleToUse
        );

        emit BetCreated(betIds.current(), msg.sender, _amount, oracleToUse);
    }

    /**
     * @dev Reads details about a specific bet.
     * @param _betId ID of the bet to be read.
     */
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

    /**
     * @dev Allows certain users to update the oracle of a specific bet.
     * @param _betId ID of the bet.
     * @param _newOracle Address of the new oracle.
     */
    function updateBetOracle(uint256 _betId, address _newOracle) public {
        require(
            _newOracle != address(0),
            "New oracle address cannot be the zero address."
        );

        Bet storage bet = idToBet[_betId];
        require(bet.alice != address(0), "Bet does not exist.");
        require(
            msg.sender == emergencyOracle ||
                (msg.sender == bet.alice && bet.bob == address(0)),
            "Unauthorized to change the oracle."
        );

        address oldOracle = bet.oracle;
        bet.oracle = _newOracle;

        emit BetOracleUpdated(_betId, oldOracle, _newOracle);
    }

    /**
     * @dev Allows users to accept an existing bet.
     * @param _betId ID of the bet to be accepted.
     */
    function acceptBet(uint256 _betId) public {
        require(
            balanceOf(msg.sender) >= idToBet[_betId].amount,
            "Insufficient funds to accept bet."
        );

        Bet storage bet = idToBet[_betId];
        require(bet.alice != address(0), "Bet does not exist.");
        require(!bet.isActive, "Bet is already active.");
        require(bet.alice != msg.sender, "Cannot accept own bet.");
        require(!bet.isCanceled, "Bet has been canceled.");

        _transfer(msg.sender, address(this), bet.amount);

        bet.bob = msg.sender;
        bet.isActive = true;
        bet.isListed = false;

        emit BetAccepted(_betId, msg.sender);
    }

    /**
     * @dev Allows the oracle to settle a bet, choosing a winner.
     * @param _betId ID of the bet to be settled.
     * @param _winner Address of the winner.
     */
    function settleBet(uint256 _betId, address _winner) public {
        Bet storage bet = idToBet[_betId];
        require(bet.isActive, "Bet is not active.");
        require(
            bet.alice == _winner || bet.bob == _winner,
            "Winner must be either Alice or Bob of the bet."
        );
        require(
            msg.sender == bet.oracle,
            "Only the designated oracle can settle the bet."
        );

        _transfer(address(this), _winner, bet.amount * 2);

        settledBets[_betId] = bet;
        delete idToBet[_betId];

        emit BetSettled(_betId, _winner, bet.oracle);
    }

    /**
     * @dev Allows the creator of a bet to cancel it if it has not been accepted.
     * @param _betId ID of the bet to be canceled.
     */
    function cancelBet(uint256 _betId) public {
        Bet storage bet = idToBet[_betId];
        require(bet.alice != address(0), "Bet does not exist.");
        require(!bet.isActive, "Cannot cancel an active bet.");
        require(
            msg.sender == bet.alice,
            "Only the creator can cancel the bet."
        );

        _transfer(address(this), bet.alice, bet.amount);

        canceledBets[_betId] = bet;
        delete idToBet[_betId];

        emit BetCanceled(_betId, bet.alice);
    }
}
