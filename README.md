# StoryNest
A decentralized platform for creating and sharing animated stories on the Stacks blockchain.

## Features
- Create animated stories with frames
- Share stories with other users
- Like and collect stories
- Story ownership tracking via NFTs
- Story discovery and feed functionality

## Setup and Installation
1. Clone the repository
2. Install Clarinet (if not already installed)
3. Run `clarinet check` to verify contracts
4. Run `clarinet test` to run test suite

## Usage Examples
```clarity
;; Create a new story
(contract-call? .story-nest create-story "My Story" "Story description" (list u1 u2 u3))

;; Like a story
(contract-call? .story-nest like-story u1)

;; Get story details
(contract-call? .story-nest get-story-details u1)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
- NFT trait implementation
