# Decentralized Project Funding Platform(profunding)

A Clarity smart contract for managing decentralized project funding on the Stacks blockchain. This platform enables users to register projects, contribute funds, vote on proposals, and manage project funding in a transparent and secure manner.

## Features

### Member Management
- **Onboarding:** New members can be added by existing active members
- **Offboarding:** Members can be removed by admin or themselves
- **Role System:** Includes admin and contributor roles
- **Status Tracking:** Maintains active/inactive status for members

### Project Management
- **Project Registration:** Users can register new projects with:
  - Title (up to 50 characters)
  - Description (up to 500 characters)
  - Funding Goal
  - Project Deadline (based on block height)
- **Unique Project IDs:** Each project receives a unique identifier
- **Project Details Storage:** All project information is stored on-chain

### Voting System
- **Vote Casting:** Members can vote on project funding proposals
- **One Vote Per Member:** Each member can vote once per project
- **Vote Tracking:** All votes are recorded and retrievable
- **Vote Types:** Boolean votes (true for fund, false for not fund)

### Fund Management
- **Contributions:** Members can contribute STX to projects
- **Balance Tracking:** Keeps track of individual contributions
- **Fund Withdrawal:** Project owners can withdraw funds when:
  - Project deadline has passed
  - Funding goal has been reached
- **Balance Checking:** View current project balances

## Contract Functions

### Public Functions

#### Member Management
```clarity
(define-public (onboard-new-member (new-member principal)))
(define-public (offboard-member (member principal)))
```

#### Project Management
```clarity
(define-public (register-project (project-title (string-ascii 50)) 
                               (project-description (string-utf8 500))
                               (funding-goal uint)
                               (project-deadline uint)))
```

#### Voting System
```clarity
(define-public (cast-vote (project-id uint) (vote bool)))
```

#### Fund Management
```clarity
(define-public (contribute-funds (project-id uint) (contribution-amount uint)))
(define-public (withdraw-funds (project-id uint)))
```

### Read-Only Functions
```clarity
(define-read-only (get-project-details (project-id uint)))
(define-read-only (get-member-profile (member principal)))
(define-read-only (get-vote (project-id uint) (voter principal)))
(define-read-only (get-project-balance (project-id uint)))
```

## Error Handling

The contract includes several error constants for common scenarios:
- `error-access-denied`: Unauthorized access attempt
- `error-item-not-found`: Requested item doesn't exist
- `error-invalid-input`: Invalid input parameters
- `error-insufficient-funds`: Insufficient funds for operation

## Setup and Deployment

1. **Prerequisites**
   - Stacks blockchain development environment
   - Clarity CLI tools
   - A Stacks wallet with sufficient STX for deployment

2. **Deployment Steps**
   ```bash
   # Deploy the contract
   clarinet contract deploy
   ```

3. **Post-Deployment**
   - The contract automatically initializes with the deployer as admin
   - The contract state is set to "active"
   - The admin is added as the first member

## Usage Examples

### Registering a New Project
```clarity
(contract-call? .project-funding register-project 
    "My Project" 
    "A detailed description of my project" 
    u1000000 
    u100000)
```

### Contributing to a Project
```clarity
(contract-call? .project-funding contribute-funds 
    u1 
    u50000)
```

### Casting a Vote
```clarity
(contract-call? .project-funding cast-vote 
    u1 
    true)
```

## Security Considerations

1. **Access Control**
   - Only active members can register projects
   - Only project owners can withdraw funds
   - Only admin can perform certain operations

2. **Input Validation**
   - All string inputs have length limits
   - All numeric inputs are checked for valid ranges
   - Project deadlines must be in the future

3. **Fund Safety**
   - Funds are held by the contract until conditions are met
   - Withdrawal requires meeting funding goals
   - Multiple checks before fund transfers

## Best Practices

1. **Project Registration**
   - Provide clear, detailed project descriptions
   - Set realistic funding goals
   - Allow sufficient time for funding

2. **Contributing**
   - Verify project details before contributing
   - Check project deadlines
   - Verify funding progress

3. **Voting**
   - Review project details thoroughly
   - Consider project viability
   - Vote before project deadline

## Limitations

1. **Blockchain Constraints**
   - Block height is used for time measurements
   - Map limitations in Clarity
   - No direct iteration over maps

2. **Technical Constraints**
   - Fixed string length limits
   - Single vote per member per project
   - No partial fund withdrawals

## Future Improvements

1. **Potential Enhancements**
   - Multiple funding rounds
   - Partial fund withdrawals
   - Project updates/modifications
   - More detailed voting system
   - Project categories and tags

2. **Additional Features**
   - Project milestones
   - Reward tiers
   - Project updates
   - Contributor badges

