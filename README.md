# TestingBettingExchangeToken

## Overview
The `TestingBettingExchangeToken` is a smart contract built on the Rootstock testnet, and it's designed to facilitate betting activities in the Bitcoin ecosystem. This contract lets users engage in various stages of betting including creating, accepting, and settling bets.

## Table of Contents
- [Features](#features)
- [Deployment](#deployment)
- [Interaction](#interaction)
- [Events](#events)
- [Utilities](#utilities)

## Features

### Enums:
1. **State**
    - `Listed`: A bet that's been created but not accepted yet.
    - `Active`: A bet that's ongoing.
    - `Canceled`: A bet that was canceled by its creator.
    - `Settled`: A bet that has ended with a winner.

### Structs:
1. **Bet**
    - Contains the two betting parties (`alice` and `bob`), the bet amount, its current state, and the oracle in charge of declaring the outcome.

### Important State Variables:
1. `owner`: The account that deploys and owns the contract.
2. `refereeOracle`: The default oracle for settling bets.
3. `emergencyOracle`: Oracle with emergency privileges for overriding.

### Mappings:
- Bets by ID: `bets`.
- User's active bets: `userActiveBets`.
- User's won bets: `userWonBets`.
- User's lost bets: `userLostBets`.
- User's canceled bets: `userCanceledBets`.
- User's open bets: `userOpenBets`.

## Deployment
Make sure you have the required dependencies installed:
- OpenZeppelin Contracts for ERC20 and Counters.

When deploying, provide the addresses for the `refereeOracle` and the `emergencyOracle` as constructor arguments.

## Interaction
1. **Bet Creation**: Any user can create a bet by staking a certain amount of tokens.
2. **Accepting a Bet**: Another user can accept a bet by staking the same amount.
3. **Oracle's Role**: The oracle determines the winner when the event being bet on concludes.
4. **Bet Cancellation**: The bet creator (alice) can cancel the bet if it hasn't been accepted.
5. **Reading Bet Details**: Anyone can read the details of a specific bet using its ID.
6. **Fetching Available Bets**: Users can fetch all available bets.

## Events
1. `BetCreated`: Emitted when a new bet is made.
2. `BetAccepted`: Emitted when a bet is accepted by another user.
3. `BetSettled`: Emitted when a bet has concluded.
4. `BetOracleUpdated`: Emitted when the oracle for a specific bet is updated.
5. `BetCanceled`: Emitted when a bet is canceled by its creator.

## Utilities
- The contract owner can change the default and emergency oracles using `setRefereeOracle` and `setEmergencyOracle` respectively.

## Important Notes
- Always make sure that the oracle involved in your bets is trustworthy.
- Ensure adequate precautions when managing and settling bets.

## Review
This contract is for demonstration purposes for the hackathon. Please ensure thorough review before using in a production environment.

## License
This contract uses the Unlicense.
