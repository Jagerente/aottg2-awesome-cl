class Main
{
    RealismDeathVelocity = 100.0;

    function OnGameStart()
    {
        RealismImpactMode.SetDeathVelocity(self.RealismDeathVelocity);
    }

    function OnTick()
    {
        RealismImpactMode.OnTick();
    }

    # @param character Character
    function OnCharacterSpawn(character)
    {
        RealismImpactMode.OnCharacterSpawn(character);
    }

    # @param victim Character
    # @param killer Character
    # @param killerName string
    function OnCharacterDie(victim, killer, killerName)
    {
        RealismImpactMode.OnCharacterDie(victim, killer, killerName);
    }
}

extension RealismImpactMode
{
    # @type Human
    _human = null;

    _lastVelocity = Vector3.Zero;

    _deathVelocity = 100.0;

    # @param velocity float
    function SetDeathVelocity(velocity)
    {
        self._deathVelocity = velocity;
    }

    # @param character Character
    function OnCharacterSpawn(character)
    {
        if (!character.IsMine || character.Type != "Human")
        {
            return;
        }

        self._human = character;
        self._lastVelocity = Vector3.Zero;
    }

    # @param victim Character
    # @param killer Character
    # @param killerName string
    function OnCharacterDie(victim, killer, killerName)
    {
        if (victim != self._human)
        {
            return;
        }

        self._human = null;
    }

    function OnTick()
    {
        if (self._human == null)
        {
            return;
        }

        if (self._HasFatalImpact())
        {
            self._human.GetKilled("Impact");
            return;
        }

        self._UpdateVelocity();
    }

    function _UpdateVelocity()
    {
        self._lastVelocity = self._human.Velocity;
    }

    function _HasFatalImpact()
    {
        if (self._human == null)
        {
            return false;
        }

        hasExcessVelocity = self._lastVelocity.Magnitude - self._human.Velocity.Magnitude > self._deathVelocity;
        isVulnerable = self._human.CurrentAnimation != "Armature|attack_3_1";


        return hasExcessVelocity && isVulnerable;
    }
}
