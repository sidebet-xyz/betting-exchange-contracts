# TestingBettingExchangeToken & TestingBettingExchangeTokenFaucet

This repository hosts the `TestingBettingExchangeToken` and `TestingBettingExchangeTokenFaucet` smart contracts. These contracts were designed for testing and facilitating betting activities in the Bitcoin ecosystem on the Rootstock testnet.

## Table of Contents
- [TestingBettingExchangeToken Overview](#testingbettingexchangetoken-overview)
- [TestingBettingExchangeTokenFaucet Overview](#testingbettingexchangetokenfaucet-overview)
- [License](#license)

## TestingBettingExchangeToken Overview

The `TestingBettingExchangeToken` is a smart contract on the Rootstock testnet. It streamlines betting within the Bitcoin ecosystem, making bet creation, acceptance, and settlement efficient.

### Features

#### Enums:
- **State**: Different phases a bet can be in, including `Listed`, `Active`, `Canceled`, and `Settled`.

#### Structs:
- **Bet**: Contains bet details such as involved parties, amount, state, and the designated oracle determining the outcome.

#### Key State Variables:
- `owner`: Contract administrator.
- `refereeOracle`: Primary oracle for bet adjudication.
- `emergencyOracle`: A backup oracle with override capabilities.

#### Mappings:
Mappings exist to categorize bets by ID, user-specific bet statuses (active, won, lost, canceled, open), etc.

### Interaction
- **Bet Creation**: Start a bet with token stakes.
- **Bet Acceptance**: Another user can acknowledge and match the bet.
- **Oracle's Duty**: The oracle determines the bet winner.
- **Bet Annulment**: Initiators can retract unaccepted bets.
- **Bet Inquiry**: Retrieve bet details using its ID.
- **List Available Bets**: View all current open bets.

### Events
Events like `BetCreated`, `BetAccepted`, `BetSettled`, `BetOracleUpdated`, and `BetCanceled` offer feedback on contract interactions.

### Utilities
The contract owner can modify oracles with `setRefereeOracle` and `setEmergencyOracle`.

### Future Updates
A roadmap includes plans like RSK Smart Bitcoin Integration, an enhanced oracle system, bet timers, group betting, oracle rewards, user interface improvements, and more.

### Precautions
It's crucial to vet the chosen oracle and practice caution during bet engagements.

### Disclaimer
This contract is a hackathon demonstration. Comprehensive audits are advised before production use.

## TestingBettingExchangeTokenFaucet Overview

### Description
`TestingBettingExchangeTokenFaucet` enables users to claim a certain amount of `BettingExchangeToken` for free, primarily for testing or initial distribution. Token claims are restricted to users with zero balances and first-time claimants.

### Features
- **Token Association**: Links with `TestingBettingExchangeToken`.
- **Max Request Limit**: Upper cap on tokens a user can claim.
- **Request Tracking**: Monitors addresses that claimed tokens.
- **Ownership & Blacklist**: The deployer controls the contract, including the ability to blacklist certain addresses.

### Functions
Functions allow users to request tokens, fetch faucet balance, transfer ownership, and blacklist users.

### Events
Events like `OwnershipTransferred` and `Blacklisted` provide feedback on significant contract activities.

### Key Notes
- Single token claim per user.
- No claims for blacklisted addresses.
- The owner manages blacklistings.

## License
Both contracts are under the Unlicense.
