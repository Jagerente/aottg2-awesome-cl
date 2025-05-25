class Main
{   
    Description = "Survive multiple waves of titans.";
    RealismDeathVelocity = 100.0;
    StartTitans = 3;
    AddTitansPerWave = 1;
    MaxWaves = 20;
    RespawnOnWave = true;
    GradualSpawn = true;
    GradualSpawnTooltip = "Spawn new titans gradually over time. Helpful for reducing lag.";
    ChallengeWaves = "Punks";
    ChallengeWavesTooltip = "Makes every Nth wave spawn special titans";
    ChallengeWavesDropbox = "Disabled, Punks, Throwers, Crawlers, Random";
    ChallengeWavesEveryX = 5;

    _currentWave = 0;
    _hasSpawned = false;

    function OnGameStart()
    {
        RealismImpactMode.SetDeathVelocity(self.RealismDeathVelocity);

        if (Network.IsMasterClient)
        {
            self.NextWave();
        }
    }

    function OnCharacterSpawn(character)
    {
        RealismImpactMode.OnCharacterSpawn(character);

        if (character.IsMine && character.Type == "Titan")
        {
            if (character.DetectRange > 0)
            {
                character.DetectRange = 2000;
            }
        }
    }

    # @param victim Character
    # @param killer Character
    # @param killerName string
    function OnCharacterDie(victim, killer, killerName)
    {
        RealismImpactMode.OnCharacterDie(victim, killer, killerName);
    }

    function OnTick()
    {
        RealismImpactMode.OnTick();

        if (Network.IsMasterClient && !Game.IsEnding)
        {
            titans = Game.Titans.Count;
            humans = Game.Humans.Count;
		    playerShifters = Game.PlayerShifters.Count;
            if (humans > 0 || playerShifters > 0)
            {
                self._hasSpawned = true;
            }
            if (titans == 0)
            {
                self.NextWave();
            }
            if (humans == 0 && playerShifters == 0 && self._hasSpawned)
            {
                UI.SetLabelAll("MiddleCenter", "Humanity failed!");
                Game.End(10.0);
                return;
            }
            UI.SetLabelAll("TopCenter", "Titans Left: " + Convert.ToString(titans) + "  " + "Wave: " + Convert.ToString(self._currentWave));
        }
    }

    function NextWave()
    {
        self._currentWave = self._currentWave + 1;
        if (self._currentWave > self.MaxWaves)
        {
            UI.SetLabelAll("MiddleCenter", "All waves cleared, humanity wins!");
            Game.End(10.0);
            return;
        }
        amount = self.AddTitansPerWave * (self._currentWave - 1) + self.StartTitans;
        type = "Default";
        if (self.ChallengeWaves != "Disabled" && self.ChallengeWavesEveryX > 0 && Math.Mod(self._currentWave, self.ChallengeWavesEveryX) == 0)
        {
            amount = self._currentWave / self.ChallengeWavesEveryX;
            if (self.ChallengeWaves == "Punks")
            {
                type = "Punk";
            }
            elif (self.ChallengeWaves == "Throwers")
            {
                type = "Thrower";
            }
            elif (self.ChallengeWaves == "Crawlers")
            {
                type = "Crawler";
            }
            elif (self.ChallengeWaves == "Random")
            {
                type = "Random";
            }
        }
        if (self.GradualSpawn)
        {
            Game.SpawnTitansAsync(type, amount);
        }
        else
        {
            Game.SpawnTitans(type, amount);
        }
        if (self.RespawnOnWave)
        {
            Game.SpawnPlayerAll(false);
        }
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
