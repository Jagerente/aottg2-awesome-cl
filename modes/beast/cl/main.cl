# @import beast_titan
# @import game_state
# @import input_manager ui_manager music_manager cutscene_manager
# @import event_manager events
# @import titan_proxy titan_target titan_spawner
# @import router messages message_handlers
# @import i18n i18n_english i18n_korean i18n_russian
# @import ui_popups
# @import enums
# @import html
# @import supply_station_switcher
class Main
{
    StartTime = 3.5;

	_AbnormalTitanNum=8;
	_AbnormalTitanNumTooltip="The number of Abnormal Titans";
	JumperTitanNum=6;
	JumperTitanNumTooltip="The number of Jumpers";
	CrawlerTitanNum=4;
	CrawlerTitanNumTooltip="The number of Crawlers";
	ThrowerTitanNum=0;
	ThrowerTitanNumTooltip="The number of Throwers";
	PunkTitanNum=4;
	PunkTitanNumTooltip="The number of Punk Titans";

	Gass=100;
	GassTooltip="Gas quantity";
	Bladenumber=8;
	BladenumberTooltip="The number of blades";
	Thunderspearnumber=25;
	ThunderspearnumberTooltip = "The number of Thunderspear bullets";
	
	NoThrowBlade=true;
	NoThrowBladeTooltip="Whether ThrowBlade is allowed";
	JustSpin1=true;
	JustSpin1Tooltip="Set the skills of all players using blades to spin1";
	Spin123NoCD=true;
	Spin123NoCDTooltip="Spin1/Spin2/Spin3 skill no CD";
	Spin123Plus=true;
	Spin123PlusTooltip="Hold Spin1/Spin2/Spin3 to keep spinning.";

	TrueLevi=false;
	TrueLeviTooltip="Spin no CD Automatically lock the back of the Titan's neck. The Beast Titan can't hurt you.";

	TrueLeviDamageMin=1000;
	TrueLeviDamageMinTooltip="Player's minumum damage, when the Levi mode is enabled.";
	TrueLeviDamageMax=4500;
	TrueLeviDamageMaxTooltip="Player's maximum damage, when the Levi mode is enabled.";

    AttackTitanScoreMin= 1000;
	AttackTitanScoreMinTooltip="The minimum kill score to be targeted by all the titans. (Ignored by Levi mode)";

    TimeToBeastTypeSwitch = 10.0;
    TimeToBeastTypeSwitchRandomOffset = 5.0;
    BeastTypePitcherEnabled = true;
    BeastTypePitcherEnabledTooltip = "Long-range attack, low health";
    BeastTypeWarriorEnabled = true;
    BeastTypeWarriorEnabledTooltip = "It has both melee and long-range capabilities, high health";
    BeastTypeAssassinEnabled = true;
    BeastTypeAssassinEnabledTooltip = "It mainly uses close combat as its attack method, low health.";
	TheBeastTitanType = "Pitcher";

 	Phase1EndTime = 300.0;
	Phase1EndTimeTooltip="Limited Time Until Beast titan appeared. (Ignored by Levi mode)";
 	Phase2EndTime = 300.0;
	Phase2EndTimeTooltip="Time to kill Beast titan. (Ignored by Levi mode)";

	TitanStronger=false;
	TitanStrongerTooltip = "Make the Titans stronger";
	TitanStrongerLine=false;
	TitanStrongerLineTooltip = "Whether to highlight the stronger titans. (Ignored by Levi mode)";

	LastChance=false;
	LastChanceTooltip = "Without supplies, cross the Rubicon River!";
	OutlinePlayers=true;
	OutlinePlayersTooltip = "Whether to highlight the players";

	BgmSet = "BGM1-BGM2";
	BgmSetDropbox = "BGM1-BGM2, BGM3-BGM4, BGM5-BGM6, Battle, None";

    HumanHealth=100;
	PlayerTitanHealth=500;
	PlayerTitanHealthTooltip = "The Health of the PT";

    ShowHitBoxes=false;
    ShowHitBoxesTooltip = "Show hitboxes";
    
    # @type ZekeShifter
    _beastTitan = null;
    # @type Vector3
    _beastStartPos = null;

    # @type List<MapObject>
    _titanSpawnPoints = List();

	function OnGameStart()
	{
        self._ValidateGameSettings();
        self._InitLocalization();
        self._InitRouter();
        InputManager.InitKeybinds();
        GameGuideUI.Initialize();
        MusicManager.Initialize();

        self._InitTitanSpawnPoints();
        SupplyStationSwitcher.Initialize();

        self._InitBeastTitan();

        self._InitEvents();

        self._InitUIManager();

        if (self.TrueLevi)
        {
            TitanTargetSwitcher.MinDamage = self.TrueLeviDamageMin;
        }
        else
        {
            TitanTargetSwitcher.MinDamage = self.AttackTitanScoreMin;
        }

        if(self.LastChance)
        {
            SupplyStationSwitcher.Deactivate();
        }

        if (Time.GameTime > Math.Min(self.StartTime, 3.0))
        {
            MusicManager.Play(Main.BgmSet);
        }
        else
        {
            MusicManager.Stop();
        }
	}

	function OnNetworkMessage(sender, msg)
	{
        Router.Route(sender, msg);
    }

	function OnCharacterSpawn(character)
	{
        if (character.IsMainCharacter)
        {
            PlayerProxy.OnSpawn();
        }
		
		if(character.Type=="Human")
		{
			self._HandleHumanSpawn(character);
		}	
		elif(character.Type=="Titan")
		{
			self._HandleTitanSpawn(character);
		}
	}

    function OnCharacterDie(victim, killer, killerName)
    {
        if (victim != null && victim.IsMainCharacter)
        {
            PlayerProxy.OnDie();
        }

        if (
            killer != null && killer.IsMainCharacter 
            && victim != null && victim.Type == "Titan"
        )
        {
            PlayerProxy.OnTitanKilled();
        }
    }

	function OnTick()
	{
        UIManager.OnTick();
        PlayerProxy.OnTick();
        CutsceneManager.OnTick();
	}
    
    function OnFrame()
    {
        UIManager.OnFrame();
        PlayerProxy.OnFrame();
    }

    function OnSecond()
    {
        UIManager.OnSecond();

        if (!Game.IsEnding && Network.IsMasterClient)
        {
            EventManager.UpdateEvent(1.0);
        }
    }

	function OnCharacterDamaged(victim, killer, killerName, damage)
	{
        TitanTargetSwitcher.OnCharacterDamaged(victim, killer, killerName, damage);
	}

    function _ValidateGameSettings()
    {
        self.TimeToBeastTypeSwitch = Math.Abs(self.TimeToBeastTypeSwitch);
        self.TimeToBeastTypeSwitchRandomOffset = Math.Min(
            self.TimeToBeastTypeSwitch, 
            Math.Abs(self.TimeToBeastTypeSwitchRandomOffset)
        );
    }

    function _InitTitanSpawnPoints()
    {
        self._titanSpawnPoints = Map.FindMapObjectsByName("Titan SpawnPoint");
    }

    function _InitBeastTitan()
    {
        self._beastStartPos = Vector3(-10, 0, -300);
        self._beastTitan = Map.FindMapObjectsByComponent("ZekeShifter").Get(0).GetComponent("ZekeShifter");

        self._beastTitan.ShowHitBoxes = self.ShowHitBoxes;
        self._beastTitan.BeastTypeAssassinEnabled = self.BeastTypeAssassinEnabled;
        self._beastTitan.BeastTypePitcherEnabled = self.BeastTypePitcherEnabled;
        self._beastTitan.BeastTypeWarriorEnabled = self.BeastTypeWarriorEnabled;

        self._beastTitan.TimeToTypeSwitch = self.TimeToBeastTypeSwitch;
        self._beastTitan.TimeToTypeSwitchRandomOffset = self.TimeToBeastTypeSwitchRandomOffset;
        if (self.TrueLevi)
        {
            self._beastTitan.Damage = 0;
        }
        else
        {
            self._beastTitan.Damage = 1000;
        }

        self._beastTitan.DamageText = HTML.Color(HTML.Size(I18n.Get("general.beast.titlecase"), 25), ColorEnum.Brown);

        self._beastTitan.Initialize();
        self._beastTitan.Disable();
    }

    function _InitEvents()
    {
        t1 = self.Phase1EndTime;
        t2 = self.Phase2EndTime;
        if (self.TrueLevi)
        {
            t1 = null;
            t2 = null;
        }

        killTitansEvent = KillTitansEvent(t1, self._AbnormalTitanNum / 2);
        killBeastEvent = KillBeastEvent(t2, self._beastTitan);

        killBeastNode = EventNode(killBeastEvent);
        killTitansNode = EventNode(killTitansEvent);
        killTitansNode.On(killTitansEvent.CODE_COMPLETED, killBeastNode);

        EventManager.SetStart(killTitansNode);
    }

    function _InitLocalization()
    {
        I18n.RegisterLanguagePack(EnglishLanguagePack());
        I18n.RegisterLanguagePack(KoreanLanguagePack());
        I18n.RegisterLanguagePack(RussianLanguagePack());
    }

    function _InitRouter()
    {
        Router.RegisterHandler(SetLocalizedLabelMessage.TOPIC, SetLocalizedLabelMessageHandler());
        Router.RegisterHandler(PlayMusicMessage.TOPIC, PlayMusicMessageHandler());
        Router.RegisterHandler(RunCutsceneMessage.TOPIC, RunCutsceneMessageHandler());
    }

    function _InitUIManager()
    {
        UIManager.RegisterProvider(
            UILabelTypeEnum.TOPLEFT, 
            InfoTextProvider(), 
            UpdateRateEnum.Second
        );
    }

    function _HandleHumanSpawn(human)
    {
        if(self.OutlinePlayers)
        {
            human.AddOutline(Color(60,0,0), "OutlineVisible");
        }
    }

    function OnPlayerJoin(player)
    {
        if (!Network.IsMasterClient) { return; }
        
        node = EventManager._currentNode;
        if (node == null) { return; }

        Dispatcher.Send(
            player, 
            SetLocalizedLabelMessage.New(
                UILabelTypeEnum.TOPCENTER,
                EventManager._currentNode._event.GoalKey(),
                EventManager._currentNode._event.GoalParams(),
                null
            )
        );
    }

    function _HandleTitanSpawn(titan)
    {
        if(self.TitanStronger || !titan.IsAI)
        {
            if(self.TitanStrongerLine)
            {
                titan.AddOutline(Color(150,60,0), "OutlineVisible");
            }

            if (!titan.IsAI)
            {
                titan.MaxHealth=self.PlayerTitanHealth;
                titan.Health=self.PlayerTitanHealth;
            }

            titan.MaxStamina=9999999;
            titan.Stamina=9999999;
            titan.AttackWait=0.0;
            titan.RunSpeedBase=40;
            titan.TurnPause=0.5;
            titan.TurnSpeed=5;
            titan.AttackPause=0.1;
            titan.ActionPause=0.1;
            titan.AttackSpeedMultiplier=1.8;
        }

        titan.DetectRange=9999;

        if (Network.IsMasterClient)
        {
            TitanProxy(titan).IdleRoar();
        }
    }
}

#######################
# Text Providers
#######################

class InfoTextProvider
{
    # @return string
    function String()
    {
        specialEvents = List();
        if (!Main.TrueLevi) {
            if (Main.TitanStronger) {
                specialEvents.Add(HTML.Color(I18n.Get("info.special_events.stronger"), ColorEnum.Red));
            }
            if (Main.LastChance) {
                specialEvents.Add(HTML.Color(I18n.Get("info.special_events.last_chance"), ColorEnum.Red));
            }
        }

        text = HTML.Color("|>  " + I18n.Get("ui.info.title"), ColorEnum.Orange) + String.Newline
             + HTML.Color("|>  " + Input.GetKeyName(InputManager.Guide) + ": ", ColorEnum.Orange) + I18n.Get("ui.info.rules");

        if (Main._beastTitan._enabled) {
            if (Main._beastTitan._currentType == "Pitcher") {
                beastType = I18n.Get("info.beast_type.pitcher");
            }
            elif (Main._beastTitan._currentType == "Warrior") {
                beastType = I18n.Get("info.beast_type.warrior");
            }
            elif (Main._beastTitan._currentType == "Assassin") {
                beastType = I18n.Get("info.beast_type.assassin");
            }
            text = text + String.Newline
                 + HTML.Color("|>  " + I18n.Get("ui.info.beast_type") + ": ", ColorEnum.Orange) + beastType;
        }

        if (specialEvents.Count > 0) {
            text = text + String.Newline
                 + HTML.Color("|>  " + I18n.Get("ui.info.special_events") + ": ", ColorEnum.Orange) + String.Newline
                 + String.Join(specialEvents, String.Newline);
        }

        if (Main.TrueLevi) {
            text = text + String.Newline + HTML.Color(I18n.Get("ui.info.levi_mode"), ColorEnum.Red);
        }

        return text;
    }
}

#######################
# Misc
#######################

extension PlayerProxy
{
    # @type Human
    Human = null;

    function OnSpawn()
    {
        if (Network.MyPlayer.CharacterType != "Human")
        {
            return;
        }
        
        self.Human = Network.MyPlayer.Character;
        
        self._InitWeapon();
        self._InitStats();
    }

    function OnDie()
    {
        self.Human = null;
    }

    function OnTick()
    {
        self._HandleInputOnTick();
    }

    function OnFrame()
    {
        self._HandleInputOnFrame();
    }

    function OnTitanKilled()
    {
        if(Main.TrueLevi)
        {
            self._UpdateCustomDamage();
        }
    }

    function _InitWeapon()
    {
        if(self.Human.Weapon == WeaponEnum.AHSS)
        {
            self.Human.SetWeapon(WeaponEnum.BLADES);
            self.Human.SetSpecial(SpecialEnum.SPIN1);
        }
        elif (self.Human.Weapon == WeaponEnum.APG)
        {
            self.Human.SetWeapon(WeaponEnum.TS);
            self.Human.SetSpecial(SpecialEnum.SWITCHBACK);
        }

        if(
            (Main.NoThrowBlade && self.Human.CurrentSpecial == SpecialEnum.BLADETHROW && self.Human.Weapon == WeaponEnum.BLADES)
            || (self.Human.Weapon == WeaponEnum.BLADES && Main.JustSpin1)
            || self.Human.CurrentSpecial == SpecialEnum.DANCE
            || self.Human.CurrentSpecial == SpecialEnum.ANNIE
            || self.Human.CurrentSpecial == SpecialEnum.EREN
        )
        {
            self.Human.SetSpecial(SpecialEnum.SPIN1);
        }
    }

    function _UpdateCustomDamage()
    {
        self.Human.CustomDamage = Random.RandomInt(Main.TrueLeviDamageMin, Main.TrueLeviDamageMax);
    }

    function _InitStats()
    {
        self.Human.MaxHealth=Main.HumanHealth;
        self.Human.Health=Main.HumanHealth;

        if(Main.TrueLevi)
        {
            self.Human.MaxHealth=2500;
            self.Human.Health=2500;
            self.Human.CustomDamageEnabled = true;
            self._UpdateCustomDamage();
            self.Human.SetWeapon("Blade");
        }
        
        if (self.Human.Weapon=="Blade")
        {
            self.Human.MaxBlade = Main.Bladenumber;
            self.Human.CurrentBlade = Main.Bladenumber;
            self.Human.MaxBladeDurability = 150;
            self.Human.CurrentBladeDurability= 150;
            self.Human.MaxGas=Main.Gass;
            self.Human.CurrentGas=Main.Gass;
        }
        elif (self.Human.Weapon=="Thunderspear")
        {
            self.Human.MaxAmmoTotal = Main.Thunderspearnumber;
            self.Human.CurrentAmmoLeft = Main.Thunderspearnumber;
            self.Human.MaxGas=Main.Gass/0.2;
            self.Human.CurrentGas=Main.Gass/0.2;
        }
    }

    function _HandleInputOnTick()
    {
        if (self.Human == null)
        {
            return;
        }

        if (
            Input.GetKeyHold(KeyBindsEnum.HUMAN_ATTACKSPECIAL)
            && String.StartsWith(PlayerProxy.Human.CurrentSpecial, "Spin")
        )
        {
            if (PlayerProxy.Human.State != PlayerStateEnum.SPECIALATTACK)
            {
                self.Human.SpecialCooldown = 0.0;
                PlayerProxy.Human.ActivateSpecial();
            }
            else
            {
                PlayerProxy.Human.Rotation+=Vector3(0,250,0);
            }
            
        }

        if(Main.TrueLevi && self.Human.Weapon == "Blade")
        {	
            
            if (
                self.Human.State == PlayerStateEnum.SPECIALATTACK 
                && String.StartsWith(self.Human.CurrentSpecial, "Spin")
            )  
            {
                targetTitan = self.FindNearestTitan(self.Human.Position);
                if (Main._beastTitan._enabled && Main._beastTitan.Health > 0)
                {
                    if (
                        targetTitan == null
                        || Vector3.Distance(self.Human.Position, Main._beastTitan._napeHurtBox.MapObject.Position)
                        < Vector3.Distance(self.Human.Position, targetTitan.NapePosition)
                    )
                    {
                        targetTitan = null;
                        self.TeleportTo(self.Human, Main._beastTitan._napeHurtBox.MapObject.Position);
                    }
                }
                
                if (targetTitan != null)
                {
                    targetTitan.AddOutline(Color(255,255,255), "OutlineAll");
                    offset = 3.0;
                    napePos = targetTitan.NapePosition - offset * targetTitan.TargetDirection;

                    self.TeleportTo(self.Human, napePos);
                }
            }
        }
    }

    function _HandleInputOnFrame()
    {
        if(Input.GetKeyDown(InputManager.Guide))
        {
            UI.ShowPopup("GameGuide");
            return;
	    }
        elif (Input.GetKeyDown(InputManager.SkipCutscene))
        {
            CutsceneManager.ResetTimer();
            return;
        }

	    if(Network.IsMasterClient)
        {	    
            if (Input.GetKeyDown(InputManager.Interaction1))
            {
                Game.PrintAll(I18n.Get("interaction.chat.1"));	
            }
            elif (Input.GetKeyDown(InputManager.Interaction2))
            {
		        Game.PrintAll(I18n.Get("interaction.chat.2"));
            }
        }
    }

    # @return Titan
    function FindNearestTitan(position)
    {
        nearest = null;
        minDist = Math.Infinity;
        for(t in Game.AITitans)
        {
            dist = Vector3.Distance(position, t.Position);
            t.RemoveOutline();
            if (dist < minDist)
            {
                minDist = dist;
                nearest = t;
            }
        }

        return nearest;
    }

    function TeleportTo(human, pos)
    {
        dist = Vector3.Distance(human.Position, pos);

        if(dist > 5)
        {
            t = 3 / dist;
            human.Position = Vector3.SlerpUnclamped(human.Position, pos, t);
        }
        else
        {
            human.Position = pos;
        }
    }
}

cutscene Cutscene_1
{
    _name = "Cutscene_1";

    coroutine Start()
    {
        Cutscene.HideDialogue();

        timeUntilStart   = Math.Max(Main.StartTime - Time.GameTime, 0);

        delayBeforeMusic = 0;
        if (Main.BgmSet == "BGM3-BGM4")
        {
            offset = 2.25;
            delayBeforeMusic = Math.Max(timeUntilStart - offset, 0);
        }

        MusicManager.CrossFade(Main.BgmSet, delayBeforeMusic, 0.0);

        wait timeUntilStart;

        Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.a.1"));

        if(Network.IsMasterClient)
        {
            for (i in Range(0, Main.JumperTitanNum, 1))
            {
                TitanSpawner.SpawnAsync(
                    "Jumper", 
                    self._GetRandomTitanSpawnPointPosition(),
                    0.3 + i * 0.25
                );
            }
            for (i in Range(0, Main.CrawlerTitanNum, 1))
            {
                TitanSpawner.SpawnAsync(
                    "Crawler", 
                    self._GetRandomTitanSpawnPointPosition(),
                    0.35 + i * 0.25
                );
            }
            for (i in Range(0, Main.ThrowerTitanNum, 1))
            {
                TitanSpawner.SpawnAsync(
                    "Thrower", 
                    self._GetRandomTitanSpawnPointPosition(),
                    0.4 + i * 0.25
                );
            }
            for (i in Range(0, Main.PunkTitanNum, 1))
            {
                TitanSpawner.SpawnAsync(
                    "Punk", 
                    self._GetRandomTitanSpawnPointPosition(),
                    0.5 + i * 0.25
                );
            }

            for (i in Range(0, Main._AbnormalTitanNum, 1))
            {
                TitanSpawner.Spawn(
                    "Abnormal", 
                    self._GetRandomTitanSpawnPointPosition()
                );
                wait i * 0.05;
            }
        }

        GameState.GameStarted = true;
        CutsceneManager.Wait(0.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		
        Cutscene.ShowDialogue("Levi1", I18n.Get("dialogue.name.levi"), I18n.Get("dialogue.a.2"));
        CutsceneManager.Wait(1.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		
        Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.a.3"));
        CutsceneManager.Wait(5.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		
        Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.a.4"));
        CutsceneManager.Wait(5.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		
        Cutscene.ShowDialogue("Levi1", I18n.Get("dialogue.name.levi"), I18n.Get("dialogue.a.5"));
        CutsceneManager.Wait(9.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		
        Cutscene.ShowDialogue("Levi1", I18n.Get("dialogue.name.levi"), I18n.Get("dialogue.a.6"));
        CutsceneManager.Wait(6.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }

    # @return Position
    function _GetRandomTitanSpawnPointPosition()
    {
        sp = Main._titanSpawnPoints.Get(
            Random.RandomInt(0, Main._titanSpawnPoints.Count - 1)
        );

        return sp.Position;
    }
}

cutscene Cutscene_2
{
    _name = "Cutscene_2";

    coroutine Start()
    {
        Cutscene.HideDialogue();

        Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.b.1"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.b.2"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.b.3"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.b.4"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.b.5"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_3
{
    _name = "Cutscene_3";

    coroutine Start()
    {
        Cutscene.HideDialogue();

        for (t in Game.AITitans)
        {
            t.Reveal(90.5);
        }

        Main._beastTitan.Enable();

        if (Network.IsMasterClient)
        {
            Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 3.0);
            Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 4.0);
            Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
            Game.SpawnEffect("Boom7",Vector3(-10, -110, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 4.0);
            Game.SpawnEffect("Boom2",Vector3(-10, -110, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 4.0);
            Game.SpawnEffect("Boom2",Vector3(-10, -10, -300) + Vector3.Up * 150.0, Vector3(90.0, 90.0, 0.0), 4.0);
            Game.SpawnEffect("Boom2",Vector3(-10, -110, -300) + Vector3.Up * 150.0, Vector3(45.0, 90.0, 0.0), 4.0);
            Game.SpawnEffect("Boom2",Vector3(-10, -110, -300) + Vector3.Up * 150.0, Vector3(-45.0, 90.0, 0.0), 4.0);
            Game.SpawnEffect("Boom7",Vector3(-10, -110, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 4.0);
            wait 0.01;
            Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 3.0);
            Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 4.0);
            Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
            wait 0.01;
            Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 3.0);
            Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 4.0);
            Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);

            Main._beastTitan.TeleportTo(Main._beastStartPos);

            for(t in Game.AITitans)
            {
                t.Emote("Roar");
            }
        }

        monkey1Text = HTML.Size(I18n.Get("general.beast.uppercase"), 25);
        monkeyText = HTML.Color(monkey1Text, ColorEnum.Brown);

        params = List();
        params.Add(monkeyText);

        UI.SetLabelForTime(
            "MiddleCenter",
            String.FormatFromList(I18n.Get("dialogue.c.ui.1"), params),
            10.0
        );
        
        Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.c.1"));	
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
        Cutscene.ShowDialogue("Titan14", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.c.2"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
        Cutscene.ShowDialogue("Titan14", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.c.3"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
        Cutscene.ShowDialogue("Levi1", I18n.Get("dialogue.name.levi"), I18n.Get("dialogue.c.4"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
        Cutscene.ShowDialogue("Levi1", I18n.Get("dialogue.name.levi"), I18n.Get("dialogue.c.5"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
        Cutscene.ShowDialogue("Levi1", I18n.Get("dialogue.name.levi"), I18n.Get("dialogue.c.6"));
        CutsceneManager.Wait(5.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_4
{
    _name = "Cutscene_4";

    coroutine Start()
    {
        Cutscene.HideDialogue();

		Game.Print(I18n.Get("dialogue.d.chat"));
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.d.1"));
        CutsceneManager.Wait(4.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.d.2"));
        CutsceneManager.Wait(4.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_5
{
    _name = "Cutscene_5";

    coroutine Start()
    {
        Cutscene.HideDialogue();

		Game.Print(I18n.Get("dialogue.e.chat"));
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.e.1"));
        CutsceneManager.Wait(4.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.e.2"));
        CutsceneManager.Wait(4.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_6
{
    _name = "Cutscene_6";

    coroutine Start()
    {
        Cutscene.HideDialogue();

		Game.Print(I18n.Get("dialogue.f.chat"));
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.f.1"));
        CutsceneManager.Wait(4.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}
		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.f.2"));
        CutsceneManager.Wait(4.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}
