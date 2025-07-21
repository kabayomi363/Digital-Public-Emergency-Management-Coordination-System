# Digital Public Emergency Management Coordination System

A comprehensive blockchain-based emergency management system built on Stacks using Clarity smart contracts. This system coordinates emergency response activities across multiple domains including alerts, resource deployment, shelter management, damage assessment, and recovery coordination.

## System Overview

The Emergency Management Coordination System consists of five interconnected smart contracts that work together to provide a complete emergency response framework:

### 1. Alert System Contract (`alert-system.clar`)
- **Purpose**: Manages emergency notifications and alerts to residents
- **Features**:
    - Multi-channel alert distribution (SMS, email, radio, mobile apps)
    - Alert severity levels (LOW, MEDIUM, HIGH, CRITICAL)
    - Geographic targeting capabilities
    - Alert status tracking and confirmation
    - Emergency contact management

### 2. Resource Deployment Contract (`resource-deployment.clar`)
- **Purpose**: Coordinates emergency personnel and equipment deployment
- **Features**:
    - Personnel assignment and tracking
    - Equipment inventory and allocation
    - Deployment status monitoring
    - Resource availability management
    - Emergency response team coordination

### 3. Shelter Management Contract (`shelter-management.clar`)
- **Purpose**: Manages emergency shelter operations during disasters
- **Features**:
    - Shelter registration and capacity management
    - Occupancy tracking and resident check-in/out
    - Resource allocation (food, medical supplies, bedding)
    - Shelter status updates (open, closed, full)
    - Emergency contact coordination

### 4. Damage Assessment Contract (`damage-assessment.clar`)
- **Purpose**: Evaluates and tracks infrastructure damage after emergencies
- **Features**:
    - Damage report creation and categorization
    - Infrastructure status tracking
    - Assessment priority levels
    - Repair cost estimation
    - Recovery timeline management

### 5. Recovery Coordination Contract (`recovery-coordination.clar`)
- **Purpose**: Manages post-disaster cleanup and restoration efforts
- **Features**:
    - Recovery task assignment and tracking
    - Resource allocation for cleanup efforts
    - Progress monitoring and reporting
    - Community coordination
    - Long-term recovery planning

## Technical Architecture

### Data Types
- **Emergency Levels**: `u1` (LOW), `u2` (MEDIUM), `u3` (HIGH), `u4` (CRITICAL)
- **Status Types**: `u1` (INACTIVE), `u2` (ACTIVE), `u3` (COMPLETED), `u4` (CANCELLED)
- **Resource Types**: Personnel, Equipment, Supplies, Vehicles
- **Geographic Zones**: Defined by coordinate boundaries

### Key Features
- **Decentralized Coordination**: No single point of failure
- **Transparent Operations**: All activities recorded on blockchain
- **Real-time Updates**: Immediate status changes across all contracts
- **Access Control**: Role-based permissions for different user types
- **Data Integrity**: Immutable record keeping for accountability

## Contract Interactions

While contracts operate independently, they share common data structures and patterns:

1. **Emergency Declarations**: Trigger coordinated responses across all systems
2. **Resource Sharing**: Common resource identification and tracking
3. **Status Synchronization**: Consistent status reporting across contracts
4. **Geographic Coordination**: Shared location-based operations

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for deployment

### Installation
\`\`\`bash
git clone <repository-url>
cd emergency-management-system
npm install
clarinet check
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

### Deployment
\`\`\`bash
clarinet deploy --testnet
\`\`\`

## Usage Examples

### Creating an Emergency Alert
\`\`\`clarity
(contract-call? .alert-system create-alert
u4 ;; CRITICAL level
"Tornado Warning - Seek Shelter Immediately"
u1000 u2000 u3000 u4000) ;; Geographic bounds
\`\`\`

### Deploying Emergency Resources
\`\`\`clarity
(contract-call? .resource-deployment deploy-personnel
"FIRE-001"
u10 ;; 10 firefighters
u1000 u2000) ;; Location coordinates
\`\`\`

### Opening Emergency Shelter
\`\`\`clarity
(contract-call? .shelter-management open-shelter
"Community Center Alpha"
u500 ;; Capacity for 500 people
u1500 u2500) ;; Location coordinates
\`\`\`

## Security Considerations

- **Access Control**: Only authorized emergency management personnel can execute critical functions
- **Data Validation**: All inputs are validated before processing
- **State Management**: Careful state transitions prevent invalid operations
- **Emergency Override**: Special provisions for emergency situations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For technical support or questions about the Emergency Management System, please contact the development team or create an issue in the repository.
