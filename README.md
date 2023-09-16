# BettingExchangeToken.sol

From the desks of the **Side₿et Development Team**:

The `BettingExchangeToken` Solidity contract stands as a testament to the Side₿et ethos - pioneering, innovative, and user-centric. Positioned as the linchpin of the Side₿et platform on the RSK network, it pioneers a seamless pathway for users to place, accept, and settle bets. Dive into our crafted breakdown:

## Prerequisites and Libraries

- The contract is sculpted with Solidity version `^0.8.9`.
- Our dedication to standards reflects as we leverage OpenZeppelin's `ERC20`, ensuring the token retains both identity and functionality.
- Trust is paramount. Hence, OpenZeppelin's `Counters` library ensures the safe allocation of unique bet IDs.

## State Variables

- `betIds`: Not just a counter, but the heartbeat generating unique bet IDs.
- `refereeOracle`: The sentinel. Our primary oracle holding the scales of arbitration.
- `emergencyOracle`: For the unpredictable times. This oracle has the discretion to tweak the oracle address for any bet.
- `owner`: It's more than an address. It symbolizes the mastermind, often the deployer.
- `bets`: A meticulously crafted mapping that marries a bet ID to its respective `Bet` struct.

## Structs

- `Bet`: A chronicle of engagements between Alice and Bob, tracking amounts, state, and the overseeing oracle.

## Events

- `BetCreated`: Celebrates the inception of a new bet.
- `BetAccepted`: Marks the moment when Bob steps into the arena.
- `BetSettled`: The climax. The oracle's gavel drops, resolving the bet.
- `BetOracleUpdated`: Chronicles the shifts in the chosen oracle's narrative.
- `BetCanceled`: The twist. Captures when Alice opts for a strategic retreat.

## Modifiers

- `onlyOwner`: A sentinel ensuring that the realm's keys remain with its true master.

## Constructor

- Our blueprint. It breathes life into the betting token, designates the oracles, and heralds the token era by minting the first supply.

## Functions

- `setRefereeOracle`: A privilege of the throne, allowing the kingpin to crown or reassign the default oracle.
- `createBet`: The portal. Users script their tales, defining the stakes and the overseer. No oracle? The referee steps in.
- `readBet`: The crystal ball, revealing the intricacies of any chosen bet.
- `updateBetOracle`: A twist in the tale. The baton of oversight can shift, either by the bet's scribe or during emergencies.
- `acceptBet`: Bob's clarion call, echoing his acceptance.
- `settleBet`: The oracle's decree, heralding the victor.
- `cancelBet`: Alice's prerogative to dissolve her challenge if untouched by Bob.

## Subsequent Courses of Action

### Access Control

- As guardians of the realm, we contemplate on fortifying our defenses, possibly with more sentinels or through the arcane arts of RBAC. OpenZeppelin's `AccessControl` might be our chosen spellbook.

### Emergency Measures

- Preparedness defines us. We're charting out a "circuit breaker" or a "pause" rite to paralyze the contract's pulse during tempests.

### Extended Functionalities

- Justice above all. We envision a court where grievances against the oracle's judgement can seek redressal.

### Optimization

- Evolution is constant. Regular introspection and refinement promise the elixir of gas efficiency.

### Quality Assurance

- In the Side₿et sanctum, before any contract graces the mainnet, it undergoes the trials of a meticulous professional audit.

### Documentation

- Our scrolls are detailed and orderly, ensuring that any seeker finds clarity. And as our saga evolves, so will our chronicles.

In totality, this isn't just a contract. It's a beacon, illuminating the path for betting platforms across RSK and beyond, all while brandishing the flag of the ERC20 standard.
