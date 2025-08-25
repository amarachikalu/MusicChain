# MusicChain

A decentralized music composition and practice reward system that gamifies musical skill development and creative collaboration on Stacks blockchain.

## Features

- Practice session management with instrument and difficulty tracking
- Performance quality-based reward system with skill bonuses
- Recording project mechanics with time-based bonuses
- Original composition creation for advanced musicians
- Collaboration system for multi-musician projects
- Comprehensive music statistics and analytics

## Smart Contract Functions

### Public Functions
- `start-practice-session` - Begin practice session with instrument and difficulty
- `complete-practice-session` - Complete practice and earn rewards based on performance
- `claim-music-rewards` - Claim accumulated music tokens
- `start-recording-project` - Begin recording project for enhanced rewards
- `release-recording` - Complete recording with time-based bonuses
- `compose-original-piece` - Create original compositions for bonus rewards
- `collaborate-with-musicians` - Collaborate on projects for bonus rewards

### Read-Only Functions
- `get-music-activity-count` - Get total music activities for user
- `get-music-token-balance` - Get current token balance
- `get-skill-level` - Get current musical skill level
- `get-performance-count` - Get number of performances completed
- `get-recording-project` - Get current recording project scope
- `get-instrument-mastery` - Get instrument mastery bonus level
- `get-studio-stats` - Get platform-wide music statistics
- `calculate-practice-reward` - Calculate potential practice rewards

## Music Mechanics
- Instrument type affects practice time requirements
- Performance quality scores (0-100) provide bonus rewards
- Recording projects add time-based reward multipliers
- Original compositions unlock at higher skill levels
- Early recording release incurs penalties

## Usage

Deploy the contract to create a gamified music ecosystem where musicians can earn rewards for practicing, composing, recording, and collaborating on musical projects.

## License

MIT