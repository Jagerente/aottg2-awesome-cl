# @import router
# @import messages
# @import enums

class IEvent
{
    # @param t float
    function Update(t){}

    # @return string
    function Goal(){}

    # @return string
    function GoalKey(){}

    # @return List<string>
    function GoalParams(){}

    # @return boolean
    function IsDone(){}

    # @return string
    function Outcome(){}
}

class EventNode
{
    # @type IEvent
    _event = null;
    # @type Dict
    _nextByCode = Dict();

    # @param evt IEvent
    # @return EventNode
    function Init(evt)
    {
        self._event = evt;
        return self;
    }

    # @param code string
    # @param node EventNode
    # @return EventNode
    function On(code, node)
    {
        self._nextByCode.Set(code, node);
        return self;
    }
}

extension EventManager
{
    # @type EventNode
    _currentNode = null;

    # @param node EventNode
    function SetStart(node)
    {
        self._currentNode = node;
    }

    # @param t float
    function UpdateEvent(t)
    {
        if (self._currentNode == null) { return; }
        self._currentNode._event.Update(t);

        Dispatcher.SendAll(
            SetLocalizedLabelMessage.New(
                UILabelTypeEnum.TOPCENTER,
                self._currentNode._event.GoalKey(),
                self._currentNode._event.GoalParams(),
                null
            )
        );

        if (self._currentNode._event.IsDone())
        {
            code = self._currentNode._event.Outcome();
            next = self._currentNode._nextByCode.Get(code, null);
            
            self._currentNode = next;
        }
    }

    # @return string
    function GetGoal()
    {
        if (self._currentNode == null) { return null; }
        return self._currentNode._event.Goal();
    }
}
