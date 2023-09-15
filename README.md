# rsk-betting-exchange-contracts

## BettingExchangeToken.sol
This is a Solidity smart contract named `BettingExchangeToken` that represents a betting exchange token. The contract allows users to place, accept, and settle bets. Let's break down the contract:

1. **Prerequisites and Libraries**:
    - The contract uses Solidity version `^0.8.9`.
    - The contract imports OpenZeppelin's `ERC20` standard to represent the betting exchange token, ensuring standardized functionalities like transfer and balanceOf.
    - The contract also imports OpenZeppelin's `Counters` library for safely incrementing and decrementing values.

2. **State Variables**:
    - `betsIds`: A counter for unique bet IDs.
    - `refereeOracle`: The default oracle responsible for settling bets.
    - `emergencyOracle`: An oracle that can change the oracle address for any bet in emergency situations.
    - `owner`: The address of the owner, typically the deployer.
    - `idToBet`: Mapping from a bet ID to the corresponding `Bet` struct.
    - `settledBets`: Mapping to keep track of bets that have been settled.
    - `canceledBets`: Mapping to keep track of bets that have been canceled.

3. **Structs**:
    - `Bet`: Represents a single bet with details like creator (Alice), acceptor (Bob), bet amount, activity status, listing status, cancellation status, and the responsible oracle.

4. **Events**:
    - `BetCreated`: Emitted when a new bet is created.
    - `BetAccepted`: Emitted when a bet is accepted by Bob.
    - `BetSettled`: Emitted when a bet is settled by an oracle.
    - `BetOracleUpdated`: Emitted when the oracle of a bet is changed.
    - `BetCanceled`: Emitted when a bet is canceled by its creator.

5. **Modifiers**:
    - `onlyOwner`: Ensures that only the contract owner can execute a function.

6. **Constructor**:
    - The constructor initializes the betting token and sets the default and emergency oracles. It also mints an initial supply of tokens to the contract deployer.

7. **Functions**:
    - `setRefereeOracle`: Allows the owner to set or update the default oracle.
    - `createBet`: Users can create a new bet specifying the amount and the oracle. If no oracle is specified, the default oracle is used.
    - `readBet`: Returns the details of a specific bet.
    - `updateBetOracle`: Allows changing the oracle for a specific bet. This can be done by the bet's creator (before the bet is accepted) or the emergency oracle.
    - `acceptBet`: Allows a user to accept an existing bet.
    - `settleBet`: Allows the oracle to settle a bet, declaring either Alice or Bob as the winner.
    - `cancelBet`: Allows the creator of the bet to cancel it if it hasn't been accepted yet.

**Next Steps**:
1. **Access Control**:
    - Consider adding more roles (e.g., admins) or implementing role-based access control (RBAC). OpenZeppelin provides a handy `AccessControl` contract for this.

2. **Emergency Stop**:
    - Implement a "circuit breaker" pattern or "pause" functionality to halt the contract operations in emergencies.

3. **Further Functionality**:
    - Consider adding functionality for disputes, where, if either party is unhappy with the oracle's decision, there's a mechanism to challenge it.

4. **Gas Optimization**:
    - Constantly reviewing and refactoring the contract can lead to gas optimizations.

5. **Audit**:
    - Before deploying any contract to the mainnet, especially those handling user funds, ensure that it undergoes a thorough professional audit.

6. **Comments**:
    - The code is well-commented and organized, making it readable and understandable. It's always a good practice to keep the comments updated if there are future changes to the codebase.

Overall, this contract provides a robust foundation for a betting exchange platform using ERC20 tokens.