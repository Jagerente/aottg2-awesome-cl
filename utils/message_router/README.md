# Message Router

A structured way to send and handle messages.

### Components

- **Router**: Registers handlers for specific message topics and routes incoming messages to the registered handler.
- **Messages**: Defines message types and their structure.
- **Handlers**: Processes received messages.
- **Dispatcher**: Network sender proxy.

### Usage

1. Add `Router.RouteMessage(sender, msg)` in `Main.OnNetworkMessage(sender, msg)`.
2. Define your messages structures.
3. Create a handler class for each message.
4. Define message sending functions using `Dispatcher`.
5. Register handlers using `Router.RegisterHandler(topic, handler)` in `Main.OnGameStart()`.
