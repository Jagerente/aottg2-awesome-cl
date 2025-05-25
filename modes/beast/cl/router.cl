#######################
# Router
#######################

extension Router
{
    # @type Dict<string, MessageHandler>
    _handlers = Dict();

    # @param topic string
    # @param handler MessageHandler
    function RegisterHandler(topic, handler)
    {
        self._handlers.Set(topic, handler);
    }

    # @param sender Player
    # @param msg string
    function Route(sender, msg)
    {
        # @type Dict<string, any>
        msgDict = Json.LoadFromString(msg);
        topic = msgDict.Get("topic");

        h = self._handlers.Get(topic, null);
        if (h == null)
        {
            return;
        }

        h.Handle(sender, msgDict);
    }
}

#######################
# Dispatcher
#######################

extension Dispatcher
{
    # @param p Player
    # @param msg Dict<string, any>
    function Send(p, msg)
    {
        raw = Json.SaveToString(msg);
        Network.SendMessage(p, raw);
    }

    # @param msg Dict<string, any>
    function SendOthers(msg)
    {
        raw = Json.SaveToString(msg);
        Network.SendMessageOthers(raw);
    }

    # @param msg Dict<string, any>
    function SendAll(msg)
    {
        raw = Json.SaveToString(msg);
        Network.SendMessageAll(raw);
    }
}

class MessageHandler
{
    # @param sender Player
    # @param msg Dict<string, any>
    function Handle(sender, msg){}
}
