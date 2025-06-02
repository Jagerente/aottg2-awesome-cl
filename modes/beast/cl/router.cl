#######################
# Router
#######################

class Router
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

	# @param c NetworkViewable
	# @param p Player
	# @param msg Dict<string, any>
	function CSend(c, p, msg)
	{
		raw = Json.SaveToString(msg);
		c.NetworkView.SendMessage(p, raw);
	}

	# @param c NetworkViewable
	# @param msg Dict<string, any>
	function CSendOthers(c, msg)
	{
		raw = Json.SaveToString(msg);
		c.NetworkView.SendMessageOthers(raw);
	}

	# @param c NetworkViewable
	# @param msg Dict<string, any>
	function CSendAll(c, msg)
	{
		raw = Json.SaveToString(msg);
		c.NetworkView.SendMessageAll(raw);
	}
}

class NetworkViewable
{
	# @type NetworkView
	NetworkView = null;
}

class MessageHandler
{
	# @param sender Player
	# @param msg Dict<string, any>
	function Handle(sender, msg){}
}

extension BaseMessage
{
	KEY_TOPIC = "topic";
}
