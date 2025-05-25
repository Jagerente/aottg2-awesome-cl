class TitanProxy
{
    # @type Titan
    Titan = null;

    function Init(t)
    {
        self.Titan = t;
    }

    function IdleRoar()
    {
        self.Titan.Emote("Roar");
        self.Titan.Idle(5.0);
    }

    # @param c Character
    # @param t float
    function Target(c, t)
    {
        self.Titan.Target(c, t);
        self.Titan.Emote("Roar");
    }
}
