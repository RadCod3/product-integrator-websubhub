# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**WSO2 Integrator: WebSubHub** is a WebSub-compliant hub implementation built on Ballerina that enables event-driven architectures through publish-subscribe communication over HTTP(S). The system uses Kafka as a message broker for persistence and state coordination between multiple hub instances.

## Architecture

This is a distributed, scalable WebSub hub system with two main Ballerina applications:

### Components

1. **websubhub**: The main WebSub hub service that handles WebSub protocol operations
2. **websubhub-consolidator**: A consolidator service that maintains global system state and provides state snapshots

### WebSub Hub Service (`components/websubhub/`)

The hub service implements the core WebSub protocol with the following key features:

- **WebSub Protocol Implementation** (`hub_service.bal`): Handles topic registration/deregistration, subscription/unsubscription, and content publishing
- **State Management** (`hub_state_update.bal`): Initializes from consolidator snapshots and processes real-time state updates via Kafka
- **Subscription Management** (`websub_subscribers.bal`): Manages active subscribers, handles content delivery with retry logic, and tracks stale subscriptions
- **Topic Management** (`websub_topics.bal`): Maintains registered topics cache and processes topic lifecycle events
- **Security** (`modules/security/`): JWT-based authentication with configurable scopes
- **Persistence** (`modules/persistence/`): Publishes state changes to Kafka topics for distributed coordination

#### Key Architecture Patterns

- **In-memory Caching**: Both topics and subscriptions are cached locally for fast access
- **Event-driven State Updates**: All state changes are persisted to Kafka and distributed to other instances
- **Resilient Message Delivery**: Failed deliveries result in stale subscription marking with retry capabilities
- **Multi-instance Coordination**: Each hub instance has a unique server ID for subscription ownership

### WebSub Consolidator Service (`components/websubhub-consolidator/`)

The consolidator maintains the authoritative system state:

- **State Snapshot API** (`consolidator_service.bal`): Provides `/consolidator/state-snapshot` endpoint for hub initialization
- **Event Consolidation** (`consolidator_service.bal`): Processes all hub events and maintains global state
- **State Persistence**: Periodically persists consolidated state snapshots to Kafka

### Module Structure

Both components share a similar modular architecture:

```
modules/
├── common/         # Shared utilities, types, environment configs
├── config/         # Configuration management with configurable values
├── persistence/    # Kafka-based state persistence and event handling
├── security/       # JWT authentication and authorization (hub only)
└── connections/    # Kafka producer/consumer management
```

## Development Commands

### Prerequisites

- Java SE Development Kit (JDK) version 21
- Ballerina SwanLake 2201.12.9 (verified during build)

### Build Commands

```bash
# Clean and build entire project
./gradlew clean build

# Build individual components
./gradlew :websubhub:build
./gradlew :websubhub-consolidator:build

# Create distribution
./gradlew :distribution:build
```

### Configuration

The system uses Ballerina's configurable variables pattern. Key configuration areas:

- **Server Config**: Port, server ID, authentication, SSL/TLS settings
- **Kafka Config**: Connection settings, consumer/producer configurations, security
- **State Config**: Consolidator endpoint, event topics, consumer groups
- **Delivery Config**: HTTP client settings for subscriber notifications

### Testing

The codebase doesn't include explicit test commands in build files. Check for:
- Ballerina test files (`.bal` files in `tests/` directories)
- Test execution via `bal test` command

### Key Technical Details

1. **State Synchronization**: Hub instances fetch initial state from consolidator, then consume Kafka events for updates
2. **Message Flow**: Content updates → Kafka topic → Consumer polls → HTTP delivery to subscribers
3. **Failure Handling**: Failed deliveries mark subscriptions as "stale" for later retry/cleanup
4. **Security Model**: Optional JWT authentication with scope-based authorization
5. **Scalability**: Multiple hub instances can run concurrently with Kafka coordination

### Development Notes

- All WebSub protocol operations are asynchronous and return appropriate WebSub response types
- State changes are immediately persisted to Kafka for consistency
- Consumer management includes partition assignment and offset tracking
- Error handling includes graceful shutdowns and resource cleanup
- Observability is enabled by default in all Ballerina.toml configurations