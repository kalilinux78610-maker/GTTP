# Architecture Diagram

The GTTP Mobile App strictly uses a **Feature-First Clean Architecture** driven by **Riverpod** for Dependency Injection and State Management.

```mermaid
graph TD
    subgraph Presentation Layer
        UI[UI Widgets / Screens]
        Providers[Riverpod State Providers]
    end

    subgraph Domain Layer
        Entities[Business Models]
        Interfaces[Abstract Repositories]
    end

    subgraph Data Layer
        Impl[Repository Implementations]
        API[Remote Data Source / Dio]
        Local[Local Storage / Hive / SecureStorage]
    end

    %% Flow
    UI -->|Watches/Reads| Providers
    Providers -->|Calls| Interfaces
    Impl -.->|Implements| Interfaces
    Impl -->|Fetches from| API
    Impl -->|Caches to| Local
    API -->|Maps JSON to| Entities
    Local -->|Returns| Entities

    %% styling
    style UI fill:#398FDE,stroke:#fff,stroke-width:2px,color:#fff
    style Providers fill:#398FDE,stroke:#fff,stroke-width:2px,color:#fff
    style Entities fill:#1F9254,stroke:#fff,stroke-width:2px,color:#fff
    style Interfaces fill:#1F9254,stroke:#fff,stroke-width:2px,color:#fff
    style Impl fill:#EA7A1A,stroke:#fff,stroke-width:2px,color:#fff
    style API fill:#EA7A1A,stroke:#fff,stroke-width:2px,color:#fff
    style Local fill:#EA7A1A,stroke:#fff,stroke-width:2px,color:#fff
```

## Description
- **Presentation Layer:** Contains Flutter Views and Riverpod Providers. The UI never parses JSON or hits APIs directly.
- **Domain Layer:** Contains core business logic, Entities (e.g., `Course`, `Notice`), and Repository Interfaces. This layer is entirely independent of Flutter.
- **Data Layer:** Implements the Domain interfaces. Contains API logic utilizing `Dio` and local caching mechanisms (e.g., `flutter_secure_storage`).
