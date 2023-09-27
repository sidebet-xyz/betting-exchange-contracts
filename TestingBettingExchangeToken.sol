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

    // Enums
    /**
     * @dev Enumeration representing the possible states of a bet.
     * - Listed: The bet has been created and is awaiting acceptance.
     * - Active: The bet has been accepted and is currently ongoing.
     * - Canceled: The bet has been canceled by its creator.
     * - Settled: The bet has concluded and a winner has been declared by the oracle.
     */
    enum State {
        Listed,
        Active,
        Canceled,
        Settled
    }

    // Structs
    /**
     * @dev Structure representing a bet.
     * @param alice The address of the user who created the bet.
     * @param bob The address of the user who accepted the bet.
     * @param amount The amount of tokens each user has staked in the bet.
     * @param state The current state of the bet (Listed, Active, Canceled, Settled).
     * @param oracle The address of the oracle responsible for settling the bet.
     */
    struct Bet {
        address alice;
        address bob;
        uint256 amount;
        State state;
        address oracle;
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

    // Mappings

    /**
     * @dev Mapping to store the details of each bet, associated by a unique bet ID.
     * - key: unique bet ID.
     * - value: Bet struct containing the details of the bet.
     */
    mapping(uint256 => Bet) private bets;

    /**
     * @dev Mapping to store active bets for each user.
     * - key: address of the user.
     * - value: array of bet IDs representing the active bets of the user.
     */
    mapping(address => uint256[]) private userActiveBets;

    /**
     * @dev Mapping to store won bets for each user.
     * - key: address of the user.
     * - value: array of bet IDs representing the won bets of the user.
     */
    mapping(address => uint256[]) private userWonBets;

    /**
     * @dev Mapping to store lost bets for each user.
     * - key: address of the user.
     * - value: array of bet IDs representing the lost bets of the user.
     */
    mapping(address => uint256[]) private userLostBets;

    /**
     * @dev Mapping to store canceled bets for each user.
     * - key: address of the user.
     * - value: array of bet IDs representing the canceled bets of the user.
     */
    mapping(address => uint256[]) private userCanceledBets;

    /**
     * @dev Mapping to store open bets for each user.
     * - key: address of the user.
     * - value: array of bet IDs representing the open bets of the user.
     */
    mapping(address => uint256[]) private userOpenBets;

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
    constructor(address _refereeOracle, address _emergencyOracle)
        ERC20("Testing Betting Exchange Token", "TBET")
    {
        _mint(msg.sender, 22000000 * 10**decimals());
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
     * @dev Allows the owner to set or update the emergency oracle.
     * @param _newEmergencyOracle Address of the new emergency oracle.
     */
    function setEmergencyOracle(address _newEmergencyOracle) public onlyOwner {
        emergencyOracle = _newEmergencyOracle;
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

        userOpenBets[msg.sender].push(betIds.current()); // Add bet ID to user's open bets

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

        userActiveBets[bet.alice].push(_betId); // Add bet ID to Alice's active bets
        userActiveBets[bet.bob].push(_betId); // Add bet ID to Bob's active bets

        removeOpenBetForUser(bet.alice, _betId); // Remove from Alice's open bets

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

        removeActiveBetForUser(bet.alice, _betId); // Remove from Alice's active bets
        removeActiveBetForUser(bet.bob, _betId); // Remove from Bob's active bets

        if (_winner == bet.alice) {
            userWonBets[bet.alice].push(_betId); // Add to Alice's won bets
            userLostBets[bet.bob].push(_betId); // Add to Bob's lost bets
        } else {
            userWonBets[bet.bob].push(_betId); // Add to Bob's won bets
            userLostBets[bet.alice].push(_betId); // Add to Alice's lost bets
        }

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

        userCanceledBets[bet.alice].push(_betId); // Add to Alice's canceled bets

        emit BetCanceled(_betId, bet.alice);
    }

    // Public view functions

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
     * @param user Address of the user whose active bets need to be retrieved.
     * @return Returns an array of bet IDs that are currently active for the specified user.
     */
    function getActiveBetsForUser(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userActiveBets[user];
    }

    /**
     * @dev Allows users to get a list of their won bets.
     * @param user Address of the user whose won bets need to be retrieved.
     * @return Returns an array of bet IDs that have been won by the specified user.
     */
    function getWonBetsForUser(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userWonBets[user];
    }

    /**
     * @dev Allows users to get a list of their lost bets.
     * @param user Address of the user whose lost bets need to be retrieved.
     * @return Returns an array of bet IDs that have been lost by the specified user.
     */
    function getLostBetsForUser(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userLostBets[user];
    }

    /**
     * @dev Allows users to get a list of their canceled bets.
     * @param user Address of the user whose canceled bets need to be retrieved.
     * @return Returns an array of bet IDs that have been canceled by the specified user.
     */
    function getCanceledBetsForUser(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userCanceledBets[user];
    }

    /**
     * @dev Allows users to get a list of their open bets.
     * @param user Address of the user whose open bets need to be retrieved.
     * @return Returns an array of bet IDs that are currently open for the specified user.
     */
    function getOpenBetsForUser(address user)
        public
        view
        returns (uint256[] memory)
    {
        return userOpenBets[user];
    }

    // Internal functions

    /**
     * @dev Removes a bet from the user's active bets array.
     * @param user Address of the user.
     * @param _betId ID of the bet to be removed.
     */
    function removeActiveBetForUser(address user, uint256 _betId) internal {
        uint256[] storage activeBets = userActiveBets[user];
        for (uint256 i = 0; i < activeBets.length; i++) {
            if (activeBets[i] == _betId) {
                activeBets[i] = activeBets[activeBets.length - 1];
                activeBets.pop();
                break;
            }
        }
    }

    /**
     * @dev Removes a bet from the user's open bets array.
     * @param user Address of the user.
     * @param _betId ID of the bet to be removed.
     */
    function removeOpenBetForUser(address user, uint256 _betId) internal {
        uint256[] storage openBets = userOpenBets[user];
        for (uint256 i = 0; i < openBets.length; i++) {
            if (openBets[i] == _betId) {
                openBets[i] = openBets[openBets.length - 1];
                openBets.pop();
                break;
            }
        }
    }

    // Private functions
    // [none in this contract]
}
