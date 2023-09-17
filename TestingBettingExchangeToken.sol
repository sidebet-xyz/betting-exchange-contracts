// Pragma statement
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

// Import statements
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Contracts

/**
 * @title TestingBettingExchangeToken
 * @notice This contract allows users to engage in betting activities, including placing, accepting, and settling bets.
 * @dev This token facilitates the operations of a betting exchange. Ensure adequate precautions are taken for secure bet settlement and management.
 */
contract TestingBettingExchangeToken is ERC20 {
    // Enables the usage of methods from the Counters library for the Counters.Counter data type.
    using Counters for Counters.Counter;

    // Type declarations (Enums and Structs)

    enum State {
        Listed,
        Active,
        Canceled,
        Settled
    }

    struct Bet {
        address alice; // Creator of the bet
        address bob; // Acceptor of the bet
        uint256 amount; // Amount of tokens staked in the bet
        State state; // State of the bet (e.g., Active, Canceled, etc.)
        address oracle; // Oracle responsible for settling the bet
    }

    // State variables

    // Owner of the contract, typically the deployer
    address public owner = msg.sender;

    // Counter for unique bet IDs
    Counters.Counter public betIds;

    // Default oracle responsible for refereeing and settling bets
    address public refereeOracle;

    // Oracle with emergency privileges to override and update oracles for bets
    address public emergencyOracle;

    // Mapping from bet ID to the Bet struct
    mapping(uint256 => Bet) private bets;

    // Mapping for user's active bets
    mapping(address => uint256[]) private userActiveBets;

    // Events

    // Event emitted when a new bet is created
    event BetCreated(
        uint256 indexed betId,
        address indexed alice,
        uint256 amount,
        address indexed oracle
    );

    // Event emitted when a bet is accepted by another user
    event BetAccepted(uint256 indexed betId, address indexed bob);

    // Event emitted when a bet is settled and we have a winner
    event BetSettled(
        uint256 indexed betId,
        address indexed winner,
        address indexed oracle
    );

    // Event emitted when the oracle for a bet is updated
    event BetOracleUpdated(
        uint256 indexed betId,
        address indexed oldOracle,
        address indexed newOracle
    );

    // Event emitted when a bet is canceled by the creator
    event BetCanceled(uint256 indexed betId, address indexed alice);

    // Modifiers

    // Ensures that only the owner can execute certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    // Constructor

    /**
     * @notice Creates an instance of the betting token with specified oracles.
     * @param _refereeOracle The address of the default referee oracle.
     * @param _emergencyOracle The address of the emergency oracle.
     */
    constructor(
        address _refereeOracle,
        address _emergencyOracle
    ) ERC20("Testing Betting Exchange Token", "TBET") {
        _mint(msg.sender, 22000000 * 10 ** decimals());
        refereeOracle = _refereeOracle;
        emergencyOracle = _emergencyOracle;
    }

    // External functions
    // [none in this contract]

    // Public functions

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
        bets[betIds.current()] = Bet(
            msg.sender,
            address(0),
            _amount,
            State.Listed,
            oracleToUse
        );

        emit BetCreated(betIds.current(), msg.sender, _amount, oracleToUse);
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

        Bet storage bet = bets[_betId];
        require(
            bet.state == State.Listed,
            "Bet is not in a state where the oracle can be changed."
        );
        require(
            msg.sender == emergencyOracle || msg.sender == bet.alice,
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
        Bet storage bet = bets[_betId];
        require(bet.state == State.Listed, "Bet is not listed.");
        require(bet.alice != msg.sender, "Cannot accept own bet.");

        _transfer(msg.sender, address(this), bet.amount);

        bet.bob = msg.sender;
        bet.state = State.Active;

        userActiveBets[bet.bob].push(_betId); // Add bet ID to the bob's active bets

        emit BetAccepted(_betId, msg.sender);
    }

    /**
     * @dev Allows the oracle to settle a bet, choosing a winner.
     * @param _betId ID of the bet to be settled.
     * @param _winner Address of the winner of the bet.
     */
    function settleBet(uint256 _betId, address _winner) public {
        Bet storage bet = bets[_betId];
        require(bet.state == State.Active, "Bet is not active.");
        require(
            bet.oracle == msg.sender,
            "Only the oracle can settle this bet."
        );

        require(
            _winner == bet.alice || _winner == bet.bob,
            "Winner must be either Alice or Bob."
        );

        uint256 totalAmount = bet.amount * 2;
        _transfer(address(this), _winner, totalAmount);
        bet.state = State.Settled;

        emit BetSettled(_betId, _winner, bet.oracle);
    }

    /**
     * @dev Allows the bet creator to cancel a bet.
     * @param _betId ID of the bet to be canceled.
     */
    function cancelBet(uint256 _betId) public {
        Bet storage bet = bets[_betId];
        require(bet.state == State.Listed, "Bet is not listed.");
        require(
            bet.alice == msg.sender,
            "Only the bet creator can cancel the bet."
        );

        _transfer(address(this), bet.alice, bet.amount);
        bet.state = State.Canceled;

        emit BetCanceled(_betId, bet.alice);
    }

    // Public view functions

    /**
     * @dev Reads details about a specific bet.
     * @param _betId ID of the bet to be read.
     */
    function readBet(
        uint256 _betId
    )
        public
        view
        returns (
            address alice,
            address bob,
            uint256 amount,
            State state,
            address oracle
        )
    {
        Bet memory bet = bets[_betId];
        return (bet.alice, bet.bob, bet.amount, bet.state, bet.oracle);
    }

    /**
     * @dev Allows users to get a list of all available bets.
     */
    function getAvailableBets() public view returns (uint256[] memory) {
        uint256 count = 0;

        // First, count the number of available bets
        for (uint256 i = 1; i <= betIds.current(); i++) {
            if (bets[i].state == State.Listed) {
                count++;
            }
        }

        uint256[] memory availableBets = new uint256[](count);
        uint256 index = 0;

        // Populate the array of available bet IDs
        for (uint256 i = 1; i <= betIds.current() && index < count; i++) {
            if (bets[i].state == State.Listed) {
                availableBets[index] = i;
                index++;
            }
        }

        return availableBets;
    }

    /**
     * @dev Allows users to get a list of their active bets.
     * @param user Address of the user.
     */
    function getActiveBetsForUser(
        address user
    ) public view returns (uint256[] memory) {
        return userActiveBets[user];
    }

    // Internal functions
    // [none in this contract]

    // Private functions
    // [none in this contract]
}
