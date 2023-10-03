# TestingBettingExchangeToken

## Overview
The `TestingBettingExchangeToken` is a smart contract constructed on the Rootstock testnet. Its primary function is to streamline betting activities within the Bitcoin ecosystem, allowing users to create, accept, and settle bets seamlessly.

## Table of Contents
- [Features](#features)
- [Deployment](#deployment)
- [Interaction](#interaction)
- [Events](#events)
- [Utilities](#utilities)
- [Future Updates](#future-updates)

## Features

### Enums:
- **State**:
  - `Listed`: An uninitialized bet awaiting acceptance.
  - `Active`: An ongoing bet.
  - `Canceled`: A bet that's been retracted by the creator.
  - `Settled`: A concluded bet with a discerned winner.

### Structs:
- **Bet**:
  - Stores data of the betting parties (`alice` and `bob`), the bet amount, its prevailing state, and the appointed oracle determining the outcome.

### Important State Variables:
- `owner`: The account that initiates and manages the contract.
- `refereeOracle`: The standard oracle for arbitrating bets.
- `emergencyOracle`: An oracle with elevated privileges for overruling.

### Mappings:
- Bets indexed by ID: `bets`.
- User-specific active bets: `userActiveBets`.
- User-specific winning bets: `userWonBets`.
- User-specific losing bets: `userLostBets`.
- User-specific retracted bets: `userCanceledBets`.
- User-specific open bets: `userOpenBets`.

## Deployment
Before deploying, ensure you have the necessary dependencies:
- OpenZeppelin Contracts for ERC20 and Counters.

On deployment, the addresses for both `refereeOracle` and `emergencyOracle` should be provided as constructor arguments.

## Interaction
1. **Bet Creation**: Users can initiate a bet by staking a specified amount of tokens.
2. **Bet Acceptance**: A secondary user can acknowledge a bet by staking an equivalent amount.
3. **Oracle's Duty**: The oracle finalizes the winner post the culmination of the bet event.
4. **Bet Annulment**: The bet's initiator (alice) can annul the bet if unaccepted.
5. **Bet Inquiry**: Any user can retrieve the specifics of a bet using its unique ID.
6. **List Available Bets**: Users can extract a list of all open bets.

## Events
- `BetCreated`: Triggered post a bet's initiation.
- `BetAccepted`: Triggered when a user acknowledges a bet.
- `BetSettled`: Triggered post a bet's culmination.
- `BetOracleUpdated`: Triggered when a bet's oracle gets updated.
- `BetCanceled`: Triggered when a bet gets annulled by the creator.

## Utilities
- The contractual owner has the ability to update the default and emergency oracles using `setRefereeOracle` and `setEmergencyOracle` functions, respectively.

## Future Updates
1. **RSK Smart Bitcoin Integration**: Permit users to wager using RSK's Smart Bitcoin, pegged to Bitcoin, offering a broader range of currency options.
2. **Augmented Oracle System**: Enhance the oracle system to ensure accuracy and security, possibly including multiple oracles, AI-driven analytics, and anti-collusion measures.
3. **Bet Timers**: Embed bet expiration timers to ensure clarity and prevent indefinite bets.
4. **Collective Betting**: Allow users to participate in pooled bets, distributing the winnings based on predefined rules or contribution.
5. **Oracle Rewards & Reputation**: Design an incentive model for oracles, factoring in consistency and accuracy, supplemented by a reputation system.
6. **UI/UX Enhancements**: Regular improvements to the user interface and experience.
7. **Multilingual Support**: Introduce support for multiple languages to cater to a global audience.
8. **Security Enhancements**: Regularly assess and reinforce security protocols.
9. **Cryptocurrency Integration**: Beyond RSK's Smart Bitcoin, consider support for prominent altcoins.
10. **Educational Modules**: Integrate tutorials, FAQs, and resources for new users.
11. **Mobile Application**: Craft dedicated mobile apps for Android and iOS platforms.
12. **Community Integration**: Establish a community platform for bet discussions, strategy sharing, and direct developer feedback.

## Precautions
- Ensure the selected oracle is credible before proceeding with bets.
- Always exercise caution during bet management and settlement.

## Disclaimer
This contract is intended for demonstration during the hackathon. A comprehensive review is recommended before transitioning to a live environment.

## License
This contract adheres to the Unlicense.
