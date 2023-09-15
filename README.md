# Side₿et: Decentralized Betting Exchange Contracts for RSK & EVM compatible chains

Welcome to the `Side₿et` repository! Here, we host the Solidity smart contracts designed for the decentralized betting exchange platform, primarily for the RSK (Rootstock) network, an EVM-compatible chain. Side₿et enables users to place, accept, and settle bets using the native Side₿et Token. Additionally, a dedicated faucet contract facilitates the distribution of tokens for testing or promotional campaigns.

## Table of Contents
1. [BettingExchangeToken.sol](#BettingExchangeToken.sol)
2. [BettingExchangeTokenFaucet.sol](#BettingExchangeTokenFaucet.sol)
3. [Getting Started](#Getting-Started)
4. [Contribution Guidelines](#Contribution-Guidelines)
5. [License](#License)

---

## BettingExchangeToken.sol

The `BettingExchangeToken` Solidity contract is the heart of the Side₿et platform on the RSK network. This contract allows users to seamlessly place, accept, and settle bets. Here's a comprehensive look:

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

All in all, this contract provides a sturdy backbone for a betting exchange platform on RSK and other EVM-compatible chains, leveraging the ERC20 token standard.

---

## BettingExchangeTokenFaucet.sol

In the Side₿et ecosystem on RSK, the `BettingExchangeTokenFaucet` assumes a crucial role. This Solidity contract aims to distribute the `BettingExchangeToken` either freely for testing purposes or as a part of initial promotions. Let's delve deeper:

### 1. **Prerequisites and Libraries**:

   - **Solidity Version**: The contract uses the Solidity version `^0.8.9`.
   
   - **Dependencies**: The contract imports the `BettingExchangeToken.sol` to interact with the token itself.

### 2. **State Variables**:

   - `token`: A reference to the associated `BettingExchangeToken` contract.
   
   - `maxTokensPerRequest`: Specifies the maximum number of tokens a user can request in one go.
   
   - `hasRequested`: A mapping to keep track of addresses that have already received tokens from the faucet.
   
   - `owner`: The address of the owner of this faucet, typically the one who deploys the contract.

### 3. **Constructor**:

   - The constructor is designed to set the address of the `BettingExchangeToken`, the maximum tokens that users can request per call, and the decimal precision of the tokens.

### 4. **Functions**:

   - `requestTokens`: Allows users to request a specific number of tokens from the faucet. Users can only request tokens once and only if they haven't received tokens before and have a balance of zero in the associated token.
   
   - `getFaucetBalance`: Returns the current balance of tokens held by the faucet.
   
   - `replenishFaucet`: Allows the owner to add more tokens to the faucet. This is done by transferring tokens from the owner's address to the faucet.

### 5. **Modifiers**:
   
   - `onlyOwner`: Ensures that only the contract owner can execute specific functions, such as replenishing the faucet.

### 6. **Recommendations and Next Steps**:

   - **Rate-Limiting**: To prevent abuse, consider adding functionality to rate-limit the number of requests an address can make in a specific time frame.
   
   - **Emergency Shutdown**: Implement a "pause" functionality to halt the faucet's operations in emergencies.
   
   - **Whitelisting**: Consider adding a whitelist mechanism where only whitelisted addresses can request tokens. This can be helpful in private testnets or specific promotional campaigns.
   
   - **Audit**: As always, before deploying on the mainnet, especially if it holds a significant number of tokens, it's crucial to get the contract professionally audited.

   - **Comments and Documentation**: The current codebase is well-documented, ensuring clarity in understanding functionalities. It's good practice to maintain this level of documentation as the code evolves.

### 7. **Conclusion**:
The `BettingExchangeTokenFaucet` is a utility contract designed to distribute tokens to users in a controlled manner. Its simple structure ensures easy deployment and interaction, making it a great tool for promotional and testing purposes.

In essence, the `BettingExchangeTokenFaucet` is a pivotal utility contract in the Side₿et architecture, ensuring controlled token distribution for both promotional initiatives and rigorous testing on RSK.

---

## Getting Started

1. **Installation**: Clone the Side₿et repository to your local environment and install necessary dependencies.
`git clone git@github.com:sidebet-xyz/rsk-betting-exchange-contracts.git` 
   
2. **Testing**: Before any deployment, it's imperative to run thorough tests to ensure the contracts function impeccably, especially on the RSK network. We use the Truffle suite for deployment and testing.
   
3. **Deployment**: If you're gearing up to deploy the contracts, either on an RSK local or public testnet, please configure the `truffle-config.js` accordingly.

## Contribution Guidelines

Collaboration is the lifeblood of the Side₿et community! If you're passionate about improving our contracts:

1. Fork this repository.
2. Create a dedicated branch for your feature or fix.
3. Submit a pull request; our team will review and respond promptly.

For a detailed set of guidelines, please refer to our [CONTRIBUTING.md](./CONTRIBUTING.md) file.

## License

Side₿et is committed to being open-source and uses the Unlicense. This means that the software is completely free to use, modify, and distribute, without any conditions.

For the full text of the license, please refer to the LICENSE file.

---

Thank you for exploring the Side₿et repository, a beacon of decentralized betting on the RSK network and beyond. As we tread this pioneering path, your invaluable feedback, identified issues, and enthusiastic contributions amplify our strides. Cheers to decentralization and a revolutionized betting paradigm on RSK! 🍻
