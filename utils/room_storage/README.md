# Room Storage

RoomData proxy for syncing data between players.
> [Message Router](https://github.com/Jagerente/aottg2-awesome-cl/tree/main/utils/message_router) required.

### Components

- **RoomStorage**: Proxy that automatically syncs data between players whenever the Master Client updates it.
- **RoomDataSyncer**: Module for syncing all existing data between players.
- **SyncRoomDataMessage**: Message for syncing data between players per set.
- **SyncAllRoomDataMessage**: Message for syncing all existing data between players.

### Usage

- Use `RoomStorage` to store any data that needs to persist across game sessions (restarts) and be kept synced among players.
- Use `RoomDataSyncer` whenever you need to sync all data.

