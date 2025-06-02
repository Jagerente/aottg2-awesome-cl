class Main
{
	StartTime = 3.5;

	AbnormalTitanNum=10;
	AbnormalTitanNumTooltip="The number of Abnormal Titans";
	JumperTitanNum=6;
	JumperTitanNumTooltip="The number of Jumpers";
	CrawlerTitanNum=6;
	CrawlerTitanNumTooltip="The number of Crawlers";
	ThrowerTitanNum=2;
	ThrowerTitanNumTooltip="The number of Throwers";
	PunkTitanNum=6;
	PunkTitanNumTooltip="The number of Punk Titans";

	HumanHealth=100;
	HumanHealthTooltip="Maximum health of the Human players";
	GasAmount=100;
	GasAmountTooltip="Maximum amount of Gas";
	TSGasMultiplier=5.0;
	TSGasMultiplierTooltip="Multiplier for the amount of Gas when using Thunder Spear";
	BladesCount=8;
	BladesCountTooltip="Maximum amount of Blades";
	BladesDurability=150;
	BladesDurabilityTooltip="Maximum amount of Blades Durability";
	ThunderSpearsCount=25;
	ThunderSpearsCountTooltip = "Maximum amount of Thunder Spears";

	PlayerTitanHealth=500;
	PlayerTitanHealthTooltip = "The Health of the PT";

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

	BeastHealth = 4000;
	BeastIdle = false;
	TimeToBeastTypeSwitch = 10.0;
	TimeToBeastTypeSwitchRandomOffset = 5.0;
	BeastTypePitcherEnabled = true;
	BeastTypePitcherEnabledTooltip = "Long-range attack, low health";
	BeastTypeWarriorEnabled = true;
	BeastTypeWarriorEnabledTooltip = "It has both melee and long-range capabilities, high health";
	BeastTypeAssassinEnabled = true;
	BeastTypeAssassinEnabledTooltip = "It mainly uses close combat as its attack method, low health.";

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

	ShowHitBoxes=false;
	ShowHitBoxesTooltip = "Show hitboxes";

	# @type ZekeShifter
	_beastTitan = null;
	# @type Vector3
	_beastStartPos = null;

	# @type List<MapObject>
	_titanSpawnPoints = List();

	# @type Router
	_router = null;

	# @type MapObject
	_titansFloor = null;

	# @type MapObject
	_spawnLight = null;

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

		self._titansFloor = Map.FindMapObjectByName("TitansFloor");
		self._spawnLight = Map.FindMapObjectByName("SpawnLight");
	}

	function OnNetworkMessage(sender, msg)
	{
		self._router.Route(sender, msg);
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

		if (victim.Type == "Titan")
		{
			self._OnTitanDied(victim);
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
		self._UpdateTitansOnTick();
	}

	function OnFrame()
	{
		UIManager.OnFrame();
		PlayerProxy.OnFrame();

		if (self._spawnLight.Active)
		{
			self._spawnLight.Position = Vector3.Lerp(self._spawnLight.Position, Vector3(0, 1500, 0), Time.FrameTime * 0.25);
		}
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

		self.AbnormalTitanNum = Math.Max(self.AbnormalTitanNum, 3);
		self.JumperTitanNum = Math.Max(self.JumperTitanNum, 0);
		self.CrawlerTitanNum = Math.Max(self.CrawlerTitanNum, 0);
		self.PunkTitanNum = Math.Max(self.PunkTitanNum, 0);
		self.ThrowerTitanNum = Math.Max(self.ThrowerTitanNum, 0);
	}

	function _InitTitanSpawnPoints()
	{
		self._titanSpawnPoints = Map.FindMapObjectsByName("Titan SpawnPoint");
	}

	function _InitBeastTitan()
	{
		self._beastStartPos = Vector3(-10, 0, -300);
		self._beastTitan = Map.FindMapObjectsByComponent("ZekeShifter").Get(0).GetComponent("ZekeShifter");

		self._beastTitan.Health = self.BeastHealth;
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

		if (self.BeastIdle)
		{
			self._beastTitan.Idle(99999999);
		}
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

		killTitansEvent = KillTitansEvent(
			t1,
			(self.AbnormalTitanNum + self.JumperTitanNum + self.CrawlerTitanNum + self.PunkTitanNum + self.ThrowerTitanNum) / 2
		);
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
		self._router = Router();
		self._router.RegisterHandler(SetLocalizedLabelMessage.TOPIC, SetLocalizedLabelMessageHandler());
		self._router.RegisterHandler(PlayMusicMessage.TOPIC, PlayMusicMessageHandler());
		self._router.RegisterHandler(RunCutsceneMessage.TOPIC, RunCutsceneMessageHandler());
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

	# @param titan Titan
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
			t = TitanProxy(titan);
			t.IdleRoar();

			GameState.Titans.Add(t);
		}
	}

	function _UpdateTitansOnTick()
	{
		if (!Network.IsMasterClient)
		{
			return;
		}

		for (t in GameState.Titans)
		{
			t.OnTick();
		}
	}

	# @param titans Titan
	function _OnTitanDied(titan)
	{
		if (!Network.IsMasterClient)
		{
			return;
		}

		for (t in GameState.Titans)
		{
			if (t.Titan == titan)
			{
				GameState.Titans.Remove(t);
				return;
			}
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

		text = HTML.Color("|>  " + I18n.Get("ui.info.title"), ColorEnum.Orange)
		+ String.Newline + HTML.Color("|>  " + Input.GetKeyName(InputManager.Guide) + ": ", ColorEnum.Orange) + I18n.Get("ui.info.rules")
		+ String.Newline + HTML.Color("|>  " + Input.GetKeyName(InputManager.SwitchWeapon) + ": ", ColorEnum.Orange) + I18n.Get("ui.info.switch_weapon");

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

	_lastGas = 0;
	_lastBladesCount = 0;
	_lastBladesDurability = 0;
	_lastTSAmmoRound = 0;
	_lastTSAmmoLeft = 0;

	_bladesSpecial = null;
	_tsSpecial = null;

	_bladesSpecialCD = 0.0;
	_tsSpecialCD = 0.0;

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
		self._UpdateSupplyTracking();
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
		}

		self._lastGas = Main.GasAmount;
		self._lastBladesDurability = Main.BladesDurability;
		self._lastBladesCount = Main.BladesCount;
		self._lastTSAmmoLeft =  Math.Max(Main.ThunderSpearsCount - 2, 0);
		self._lastTSAmmoRound = Math.Min(Main.ThunderSpearsCount, 2);

		self.Human.MaxGas = Main.GasAmount;
		self.Human.CurrentGas = Main.GasAmount;

		if (self.Human.Weapon=="Blade")
		{
			self.Human.MaxBlade = Main.BladesCount;
			self.Human.CurrentBlade = Main.BladesCount;
			self.Human.MaxBladeDurability = Main.BladesDurability;
			self.Human.CurrentBladeDurability= Main.BladesDurability;
		}
		elif (self.Human.Weapon=="Thunderspear")
		{
			self.Human.MaxAmmoTotal = Main.ThunderSpearsCount;
			self.Human.CurrentAmmoLeft = Main.ThunderSpearsCount - 2;
			self.Human.CurrentAmmoRound = 2;
			self.Human.MaxGas = Main.GasAmount * Main.TSGasMultiplier;
			self.Human.CurrentGas = self.Human.MaxGas;
		}

		self._bladesSpecial = self.Human.CurrentSpecial;
		self._tsSpecial = SpecialEnum.SWITCHBACK;
		if (Main.Spin123NoCD && String.StartsWith(self._bladesSpecial, "Spin"))
		{
			self._bladesSpecialCD = 0.0;
		}
		else
		{
			self._bladesSpecialCD = SpecialEnum.GetCooldown(self._bladesSpecial);
		}
		self._tsSpecialCD = SpecialEnum.GetCooldown(self._tsSpecial);
	}

	function _HandleInputOnTick()
	{
		if (self.Human == null)
		{
			return;
		}

		if (
			self.Human.Weapon == "Blade"
			&& Input.GetKeyHold(KeyBindsEnum.HUMAN_ATTACKSPECIAL)
			&& String.StartsWith(PlayerProxy.Human.CurrentSpecial, "Spin")
		)
		{
			if (
				PlayerProxy.Human.State != PlayerStateEnum.SPECIALATTACK
				&& (Main.Spin123NoCD || Main.TrueLevi)
			)
			{
				self.Human.SpecialCooldown = 0.0;
				PlayerProxy.Human.ActivateSpecial();
			}
			elif (PlayerProxy.Human.State == PlayerStateEnum.SPECIALATTACK && Main.Spin123Plus || Main.TrueLevi)
			{
				PlayerProxy.Human.Rotation+=Vector3(0,250,0);
			}

			if (Main.TrueLevi)
			{
				if (
					self.Human.State == PlayerStateEnum.SPECIALATTACK
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
		elif (Input.GetKeyDown(InputManager.SwitchWeapon))
		{
			self._SwitchWeapon();
			return;
		}

		if(Network.IsMasterClient)
		{
			if (Input.GetKeyDown(InputManager.Interaction1))
			{
				Game.PrintAll(I18n.Get("interaction.chat.1"));
				return;
			}
			elif (Input.GetKeyDown(InputManager.Interaction2))
			{
				Game.PrintAll(I18n.Get("interaction.chat.2"));
				return;
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

	function _SwitchWeapon()
	{
		if (self.Human == null || PlayerProxy.Human.State == PlayerStateEnum.SPECIALATTACK)
		{
			return;
		}

		if (self.Human.Weapon == WeaponEnum.BLADES)
		{
			self.Human.SetWeapon(WeaponEnum.TS);
			self.Human.MaxAmmoTotal = Main.ThunderSpearsCount;
			self.Human.CurrentAmmoLeft = self._lastTSAmmoLeft;
			self.Human.MaxAmmoRound = 2;
			self.Human.CurrentAmmoRound = self._lastTSAmmoRound;

			self.Human.MaxGas = Main.GasAmount * Main.TSGasMultiplier;
			self.Human.CurrentGas = self._lastGas * Main.TSGasMultiplier;

			self.Human.SetSpecial(self._tsSpecial);
			self.Human.SpecialCooldown = self._tsSpecialCD;
		}
		else
		{
			self.Human.SetWeapon(WeaponEnum.BLADES);
			self.Human.MaxBlade = Main.BladesCount;
			self.Human.CurrentBlade = self._lastBladesCount;
			self.Human.MaxBladeDurability = Main.BladesDurability;
			self.Human.CurrentBladeDurability = self._lastBladesDurability;

			self.Human.MaxGas = Main.GasAmount;
			self.Human.CurrentGas = self._lastGas / Main.TSGasMultiplier;

			self.Human.SetSpecial(self._bladesSpecial);
			self.Human.SpecialCooldown = self._bladesSpecialCD;
		}
	}

	function _UpdateSupplyTracking()
	{
		if (self.Human == null)
		{
			return;
		}

		self._lastGas = self.Human.CurrentGas;

		if (self.Human.Weapon == WeaponEnum.BLADES)
		{
			self._lastBladesDurability = self.Human.CurrentBladeDurability;
			self._lastBladesCount = self.Human.CurrentBlade;
			self._bladesSpecialCD = self.Human.SpecialCooldown;
		}
		elif (self.Human.Weapon == WeaponEnum.TS)
		{
			self._lastTSAmmoRound = self.Human.CurrentAmmoRound;
			self._lastTSAmmoLeft = self.Human.CurrentAmmoLeft;
			self._tsSpecialCD = self.Human.SpecialCooldown;
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

		Main._spawnLight.Active = true;
		Main._titansFloor.Active = false;

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

			for (i in Range(0, Main.AbnormalTitanNum, 1))
			{
				TitanSpawner.Spawn(
					"Abnormal",
					self._GetRandomTitanSpawnPointPosition()
				);
				wait i * 0.05;
			}
		}

		while (Game.AITitans.Count < Main.AbnormalTitanNum + Main.JumperTitanNum + Main.CrawlerTitanNum + Main.ThrowerTitanNum + Main.PunkTitanNum)
		{
			wait 0.15;
		}

		GameState.GameStarted = true;
				CutsceneManager.Wait(0.5); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}

		Cutscene.ShowDialogue("Levi1", I18n.Get("dialogue.name.levi"), I18n.Get("dialogue.a.2"));
				CutsceneManager.Wait(1.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}

		Cutscene.ShowDialogue("Zeke1", I18n.Get("dialogue.name.zeke"), I18n.Get("dialogue.a.3"));
				CutsceneManager.Wait(5.0); while (!CutsceneManager.IsTimerDone()){if (CutsceneManager.SkipSent()){ self.Skip(); return; }}

		Main._spawnLight.Active = false;

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

		Main._beastTitan.Idle(1.0);
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
			Main._beastTitan.Roar();

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
		Cutscene.ShowDialogue("Levi1", I18n.Get("dialogue.name.levi"), I18n.Get("dialogue.f.2"));
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

component RigidbodyBuiltin
{
	Mass = 1.0;
	Gravity = Vector3(0.0, -20.0, 0.0);
	FreezeRotation = false;
	Interpolate = false;

	function Init()
	{
		self.MapObject.AddBuiltinComponent("Rigidbody", self.Mass, self.Gravity, self.FreezeRotation, self.Interpolate);
	}

	function SetVelocity(velocity)
	{
		self.MapObject.UpdateBuiltinComponent("Rigidbody", "SetVelocity", velocity);
	}

	function AddForce(force)
	{
		self.MapObject.UpdateBuiltinComponent("Rigidbody", "AddForce", force);
	}

	function AddForceWithMode(force, mode)
	{
		self.MapObject.UpdateBuiltinComponent("Rigidbody", "AddForce", force, mode);
	}

	function AddForceWithModeAtPoint(force, point, mode)
	{
		self.MapObject.UpdateBuiltinComponent("Rigidbody", "AddForce", force, mode, point);
	}

	function AddTorque(force, mode)
	{
		self.MapObject.UpdateBuiltinComponent("Rigidbody", "AddTorque", force, mode);
	}

	# @return Vector3
	function GetVelocity()
	{
		return self.MapObject.ReadBuiltinComponent("Rigidbody", "Velocity");
	}

	# @return Vector3
	function GetAngularVelocity()
	{
		return self.MapObject.ReadBuiltinComponent("Rigidbody", "AngularVelocity");
	}
}

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

class Timer
{
	_time = 0.0;
	_lastInitialTime = 0.0;

	# @param time float
	function Init(time)
	{
		self.Reset(time);
	}

	# @param decimals int
	# @return string
	function String(decimals)
	{
		return String.FormatFloat(self._time, decimals);
	}

	# @return float
	function GetTime()
	{
		return self._time;
	}

	# @return float
	function GetInitialTime()
	{
		return self._lastInitialTime;
	}

	# @return bool
	function IsDone()
	{
		return self._time <= 0.0;
	}

	# @param time float
	function Reset(time)
	{
		self._time = time;
		self._lastInitialTime = time;
	}

	function UpdateOnFrame()
	{
		self.UpdateOn(Time.FrameTime);
	}

	function UpdateOnTick()
	{
		self.UpdateOn(Time.TickTime);
	}

	# @param t float
	function UpdateOn(t)
	{
		self._time -= t;
	}
}

extension UILabelTypeEnum
{
	TOPCENTER = "TopCenter";
	TOPLEFT = "TopLeft";
	TOPRIGHT = "TopRight";
	MIDDLECENTER = "MiddleCenter";
	MIDDLELEFT = "MiddleLeft";
	MIDDLERIGHT = "MiddleRight";
	BOTTOMLEFT = "BottomLeft";
	BOTTOMRIGHT = "BottomRight";
}

extension KeyBindsEnum
{
	GENERAL_FORWARD = "General/Forward";
	GENERAL_BACK = "General/Back";
	GENERAL_LEFT = "General/Left";
	GENERAL_RIGHT = "General/Right";
	GENERAL_UP = "General/Up";
	GENERAL_DOWN = "General/Down";
	GENERAL_AUTORUN = "General/Autorun";
	GENERAL_PAUSE = "General/Pause";
	GENERAL_HIDEUI = "General/HideUI";
	GENERAL_RESTARTGAME = "General/RestartGame";
	GENERAL_CHANGECHARACTER = "General/ChangeCharacter";
	GENERAL_CHAT = "General/Chat";
	GENERAL_PUSHTOTALK = "General/PushToTalk";
	GENERAL_CHANGECAMERA = "General/ChangeCamera";
	GENERAL_MINIMAPMAXIMIZE = "General/MinimapMaximize";
	GENERAL_SPECTATEPREVIOUSPLAYER = "General/SpectatePreviousPlayer";
	GENERAL_SPECTATENEXTPLAYER = "General/SpectateNextPlayer";
	GENERAL_SKIPCUTSCENE = "General/SkipCutscene";
	GENERAL_TOGGLESCOREBOARD = "General/ToggleScoreboard";
	GENERAL_TAPSCOREBOARD = "General/TapScoreboard";
	GENERAL_TAPSCOREBOARDTOOLTIP = "General/TapScoreboardTooltip";
	GENERAL_HIDECURSOR = "General/HideCursor";
	HUMAN_ATTACKDEFAULT = "Human/AttackDefault";
	HUMAN_ATTACKSPECIAL = "Human/AttackSpecial";
	HUMAN_HOOKLEFT = "Human/HookLeft";
	HUMAN_HOOKRIGHT = "Human/HookRight";
	HUMAN_HOOKBOTH = "Human/HookBoth";
	HUMAN_DASH = "Human/Dash";
	HUMAN_REELIN = "Human/ReelIn";
	HUMAN_REELOUT = "Human/ReelOut";
	HUMAN_DODGE = "Human/Dodge";
	HUMAN_FLARE1 = "Human/Flare1";
	HUMAN_FLARE2 = "Human/Flare2";
	HUMAN_FLARE3 = "Human/Flare3";
	HUMAN_JUMP = "Human/Jump";
	HUMAN_RELOAD = "Human/Reload";
	HUMAN_SALUTE = "Human/Salute";
	HUMAN_HORSEMOUNT = "Human/HorseMount";
	HUMAN_HORSEWALK = "Human/HorseWalk";
	HUMAN_HORSEJUMP = "Human/HorseJump";
	HUMAN_NAPELOCK = "Human/NapeLock";
	HUMAN_DASHDOUBLETAP = "Human/DashDoubleTap";
	HUMAN_AUTOUSEGAS = "Human/AutoUseGas";
	HUMAN_AUTOUSEGASTOOLTIP = "Human/AutoUseGasTooltip";
	HUMAN_REELOUTSCROLLSMOOTHING = "Human/ReelOutScrollSmoothing";
	HUMAN_REELOUTSCROLLSMOOTHINGTOOLTIP = "Human/ReelOutScrollSmoothingTooltip";
	HUMAN_SWAPTSATTACKSPECIAL = "Human/SwapTSAttackSpecial";
	HUMAN_SWAPTSATTACKSPECIALTOOLTIP = "Human/SwapTSAttackSpecialTooltip";
	HUMAN_AUTOREFILLGAS = "Human/AutoRefillGas";
	HUMAN_REELINHOLDING = "Human/ReelInHolding";
	HUMAN_REELINHOLDINGTOOLTIP = "Human/ReelInHoldingTooltip";
	TITAN_COVERNAPE = "Titan/CoverNape";
	TITAN_KICK = "Titan/Kick";
	TITAN_JUMP = "Titan/Jump";
	TITAN_SIT = "Titan/Sit";
	TITAN_WALK = "Titan/Walk";
	TITAN_SPRINT = "Titan/Sprint";
	INTERACTION_INTERACT = "Interaction/Interact";
	INTERACTION_INTERACT2 = "Interaction/Interact2";
	INTERACTION_INTERACT3 = "Interaction/Interact3";
	INTERACTION_ITEMMENU = "Interaction/ItemMenu";
	INTERACTION_EMOTEMENU = "Interaction/EmoteMenu";
	INTERACTION_MENUNEXT = "Interaction/MenuNext";
	INTERACTION_QUICKSELECT1 = "Interaction/QuickSelect1";
	INTERACTION_QUICKSELECT2 = "Interaction/QuickSelect2";
	INTERACTION_QUICKSELECT3 = "Interaction/QuickSelect3";
	INTERACTION_QUICKSELECT4 = "Interaction/QuickSelect4";
	INTERACTION_QUICKSELECT5 = "Interaction/QuickSelect5";
	INTERACTION_QUICKSELECT6 = "Interaction/QuickSelect6";
	INTERACTION_QUICKSELECT7 = "Interaction/QuickSelect7";
	INTERACTION_QUICKSELECT8 = "Interaction/QuickSelect8";
	INTERACTION_QUICKSELECT9 = "Interaction/QuickSelect9";
	INTERACTION_FUNCTION1 = "Interaction/Function1";
	INTERACTION_FUNCTION2 = "Interaction/Function2";
	INTERACTION_FUNCTION3 = "Interaction/Function3";
	INTERACTION_FUNCTION4 = "Interaction/Function4";
}

extension PlayerStateEnum
{
	IDLE = "Idle";
	ATTACK = "Attack";
	GROUNDDODGE = "GroundDodge";
	AIRDODGE = "AirDodge";
	RELOAD = "Reload";
	REFILL = "Refill";
	DIE = "Die";
	GRAB = "Grab";
	EMOTEACTION = "EmoteAction";
	SPECIALATTACK = "SpecialAttack";
	SPECIALACTION = "SpecialAction";
	SLIDE = "Slide";
	RUN = "Run";
	LAND = "Land";
	MOUNTINGHORSE = "MountingHorse";
	STUN = "Stun";
	WALLSLIDE = "WallSlide";
}

extension WeaponEnum
{
	BLADES = "Blade";
	APG = "APG";
	AHSS = "AHSS";
	TS = "Thunderspear";
}

extension SpecialEnum
{
	AHSSTWINSHOT = "AHSSTwinShot";
	ANNIE = "Annie";
	BLADETHROW = "BladeThrow";
	CARRY = "Carry";
	CONFUSE = "Confuse";
	DANCE = "Dance";
	DISTRACT = "Distract";
	DOWNSTRIKE = "DownStrike";
	EREN = "Eren";
	ESCAPE = "Escape";
	NONE = "None";
	POTATO = "Potato";
	SMELL = "Smell";
	SMOKEBOMB = "SmokeBomb";
	SPIN1 = "Spin1";
	SPIN2 = "Spin2";
	SPIN3 = "Spin3";
	STOCK = "Stock";
	SUPPLY = "Supply";
	SWITCHBACK = "Switchback";

	_cooldowns = Dict();

	function Init()
	{
		self._cooldowns.Set(self.AHSSTWINSHOT, 1.0);
		self._cooldowns.Set(self.ANNIE, 60.0);
		self._cooldowns.Set(self.BLADETHROW, 1.0);
		self._cooldowns.Set(self.CARRY, 2.0);
		self._cooldowns.Set(self.CONFUSE, 30.0);
		self._cooldowns.Set(self.DANCE, 2.0);
		self._cooldowns.Set(self.DISTRACT, 5.0);
		self._cooldowns.Set(self.DOWNSTRIKE, 5.0);
		self._cooldowns.Set(self.EREN, 60.0);
		self._cooldowns.Set(self.ESCAPE, 0);
		self._cooldowns.Set(self.POTATO, 20.0);
		self._cooldowns.Set(self.SMELL, 60.0);
		self._cooldowns.Set(self.SMOKEBOMB, 15.0);
		self._cooldowns.Set(self.SPIN1, 5.0);
		self._cooldowns.Set(self.SPIN2, 5.0);
		self._cooldowns.Set(self.SPIN3, 3.5);
		self._cooldowns.Set(self.STOCK, 0);
		self._cooldowns.Set(self.SUPPLY, 300.0);
		self._cooldowns.Set(self.SWITCHBACK, 2.0);
	}

	function GetCooldown(special)
	{
		return self._cooldowns.Get(special);
	}
}

extension ColorEnum
{
	Orange  = "FFA500";
	Blue    = "0000FF";
	Cyan    = "00FFFF";
	Fuchsia = "FF00FF";
	Green   = "008000";
	Yellow  = "FFFF00";
	Red     = "FF0000";
	Brown   = "A52A2A";
}

extension EffectEnum
{
	THUNDERSPEAREXPLODE = "ThunderspearExplode";
	GASBURST = "GasBurst";
	GROUNDSHATTER = "GroundShatter";
	BLOOD1 = "Blood1";
	BLOOD2 = "Blood2";
	PUNCHHIT = "PunchHit";
	GUNEXPLODE = "GunExplode";
	CRITICALHIT = "CriticalHit";
	TITANSPAWN = "TitanSpawn";
	TITANDIE1 = "TitanDie1";
	TITANDIE2 = "TitanDie2";
	BOOM1 = "Boom1";
	BOOM2 = "Boom2";
	BOOM3 = "Boom3";
	BOOM4 = "Boom4";
	BOOM5 = "Boom5";
	BOOM6 = "Boom6";
	BOOM7 = "Boom7";
	SPLASH = "Splash";
	TITANBITE = "Bite";
	SHIFTERTHUNDER = "ShifterThunder";
	BLADETHROWHIT = "BladeThrowHit";
	APGTRAIL = "APGTrail";
	SINGLESPLASH = "Splash";
	SPLASH1 = "Splash1";
	SPLASH2 = "Splash2";
	SPLASH3 = "Splash3";
	WATERWAKE = "WaterWake";
}

extension PlayerSoundEnum
{
	BLADEBREAK = "BladeBreak";
	BLADEHIT = "BladeHit";
	OLDBLADEHIT = "OldBladeHit";
	NAPEHIT = "NapeHit";
	LIMBHIT = "LimbHit";
	OLDNAPEHIT = "OldNapeHit";
	BLADERELOADAIR = "BladeReloadAir";
	BLADERELOADGROUND = "BladeReloadGround";
	GUNRELOAD = "GunReload";
	BLADESWING1 = "BladeSwing1";
	BLADESWING2 = "BladeSwing2";
	BLADESWING3 = "BladeSwing3";
	BLADESWING4 = "BladeSwing4";
	OLDBLADESWING = "OldBladeSwing";
	DODGE = "Dodge";
	FLARELAUNCH = "FlareLaunch";
	THUNDERSPEARLAUNCH = "ThunderspearLaunch";
	GASBURST = "GasBurst";
	HOOKLAUNCH = "HookLaunch";
	OLDHOOKLAUNCH = "OldHookLaunch";
	HOOKRETRACTLEFT = "HookRetractLeft";
	HOOKRETRACTRIGHT = "HookRetractRight";
	HOOKIMPACT = "HookImpact";
	HOOKIMPACTLOUD = "HookImpactLoud";
	GASSTART = "GasStart";
	GASLOOP = "GasLoop";
	GASEND = "GasEnd";
	REELIN = "ReelIn";
	REELOUT = "ReelOut";
	CRASHLAND = "CrashLand";
	JUMP = "Jump";
	LAND = "Land";
	NOGAS = "NoGas";
	REFILL = "Refill";
	SLIDE = "Slide";
	FOOTSTEP1 = "Footstep1";
	FOOTSTEP2 = "Footstep2";
	DEATH1 = "Death1";
	DEATH2 = "Death2";
	DEATH3 = "Death3";
	DEATH4 = "Death4";
	DEATH5 = "Death5";
	CHECKPOINT = "Checkpoint";
	GUNEXPLODE = "GunExplode";
	GUNEXPLODELOUD = "GunExplodeLoud";
	WATERSPLASH = "WaterSplash";
	SWITCHBACK = "Switchback";
	APGSHOT1 = "APGShot1";
	APGSHOT2 = "APGShot2";
	APGSHOT3 = "APGShot3";
	APGSHOT4 = "APGShot4";
	BLADENAPE1VAR1 = "BladeNape1Var1";
	BLADENAPE1VAR2 = "BladeNape1Var2";
	BLADENAPE1VAR3 = "BladeNape1Var3";
	BLADENAPE2VAR1 = "BladeNape2Var1";
	BLADENAPE2VAR2 = "BladeNape2Var2";
	BLADENAPE2VAR3 = "BladeNape2Var3";
	BLADENAPE3VAR1 = "BladeNape3Var1";
	BLADENAPE3VAR2 = "BladeNape3Var2";
	BLADENAPE3VAR3 = "BladeNape3Var3";
	BLADENAPE4VAR1 = "BladeNape4Var1";
	BLADENAPE4VAR2 = "BladeNape4Var2";
	BLADENAPE4VAR3 = "BladeNape4Var3";
	AHSSGUNSHOT1 = "AHSSGunShot1";
	AHSSGUNSHOT2 = "AHSSGunShot2";
	AHSSGUNSHOT3 = "AHSSGunShot3";
	AHSSGUNSHOT4 = "AHSSGunShot4";
	AHSSGUNSHOTDOUBLE1 = "AHSSGunShotDouble1";
	AHSSGUNSHOTDOUBLE2 = "AHSSGunShotDouble2";
	AHSSNAPE1VAR1 = "AHSSNape1Var1";
	AHSSNAPE1VAR2 = "AHSSNape1Var2";
	AHSSNAPE2VAR1 = "AHSSNape2Var1";
	AHSSNAPE2VAR2 = "AHSSNape2Var2";
	AHSSNAPE3VAR1 = "AHSSNape3Var1";
	AHSSNAPE3VAR2 = "AHSSNape3Var2";
	TSLAUNCH1 = "TSLaunch1";
	TSLAUNCH2 = "TSLaunch2";
}

component ZekeShifter
{
	Health = 4000;

	Damage = 1000;
	DamageText = "Beast Titan";

	MoveSpeed = 20.0;
	RotateSpeed = 5.0;

	ThrowCooldown = 4.0;
	ActionCooldown = 2.0;

	TimeToTypeSwitch = 10.0;
	TimeToTypeSwitchRandomOffset = 5.0;

	BeastTypePitcherEnabled = true;
	BeastTypePitcherEnabledTooltip = "Long-range attack, low health";
	BeastTypeWarriorEnabled = true;
	BeastTypeWarriorEnabledTooltip = "It has both melee and long-range capabilities, high health";
	BeastTypeAssassinEnabled = true;
	BeastTypeAssassinEnabledTooltip = "It mainly uses close combat as its attack method, low health.";

	ShowHitBoxes = false;

	# @type MapObject
	_rock = null;

	# @type RigidbodyBuiltin
	_rigidbody = null;

	# @type Transform
	_transform = null;

	# @type ZekeNapeHurtBox
	_napeHurtBox = null;

	# @type ZekeEyesHurtBox
	_eyesHurtBox = null;

	# @type Transform
	_armLeftTransform = null;
	# @type Transform
	_armRightTransform = null;

	# @type ZekeHitBox
	_armLeftHitBox = null;
	# @type ZekeHitBox
	_armRightHitBox = null;

	# @type ZekeBombHitBox
	_bombHitBox = null;

	_onDieHandler = null;

	_hitBoxVisibility = "0";

	_initialized = false;
	_enabled = false;

	_types = List();
	_currentType = "";

	# @type Human
	_target = null;
	# @type Vector3
	_turnDirection = null;

	# @type Timer
	_throwCDLeft = null;
	# @type Timer
	_actionCDLeft = null;
	# @type Timer
	_attackCDLeft = null;
	# @type Timer
	_rockThrownCDLeft = null;
	# @type Timer
	_typeSwitchCDLeft = null;
	# @type Timer
	_blindCDLeft = null;
	# @type Timer
	_idleCDLeft = null;

	_dieOnce = false;

	# @type Router
	_router = null;

	# @type string
	_currentAnimation = null;

	_currentAnimationTime = 0.0;
	_currentAttackState = 0;

	function Initialize()
	{
		self._throwCDLeft = Timer(0.0);
		self._actionCDLeft = Timer(0.0);
		self._attackCDLeft = Timer(0.0);
		self._rockThrownCDLeft = Timer(0.0);
		self._typeSwitchCDLeft = Timer(0.0);
		self._blindCDLeft = Timer(0.0);
		self._idleCDLeft = Timer(0.0);

		self._transform = self.MapObject.Transform;
		self._rigidbody = self.MapObject.GetComponent("Rigidbody");

		if (self.ShowHitBoxes)
		{
			self._hitBoxVisibility = "1";
		}
		else
		{
			self._hitBoxVisibility = "0";
		}

		self._InitTypes();

		self._SwitchType(self._RandomType());

		self._AddNape();
		self._AddHitBox();
		self._AddRock();

		self._router = Router();

		self._router.RegisterHandler(BeastPlayAnimationMessage.TOPIC, BeastPlayAnimationMessageHandler(self));
		self._router.RegisterHandler(BeastGetDamageMessage.TOPIC, BeastGetDamageMessageHandler(self));
		self._router.RegisterHandler(BeastBlindMessage.TOPIC, BeastBlindMessageHandler(self));
		
		self._initialized = true;
	}

	function RegisterOnDieHandler(handler)
	{
		self._onDieHandler = handler;
	}

	function Idle(t)
	{
		self._idleCDLeft.Reset(t);
	}

	function Enable()
	{
		self.MapObject.Active = true;
		self._enabled = true;
	}

	function Disable()
	{
		self.MapObject.Active = false;
		self._enabled = false;
	}

	function TeleportTo(pos)
	{
		self.MapObject.Position = pos;
	}

	function FindTarget()
	{
		if (self._target != null && self._target.Health <= 0)
		{
			self._target = null;
		}

		if (self._target == null)
		{
			minDistance = 0;
			for (human in Game.Humans)
			{
				direction = human.Position - self.MapObject.Position;
				direction.Y = 0;
				distance = direction.Magnitude;
				if (self._target == null || distance < minDistance)
				{
					self._target = human;
					minDistance = distance;
				}
			}
		}
	}

	function Blind()
	{
		if (!self._blindCDLeft.IsDone())
		{
			return;
		}

		duration = self._transform.GetAnimationLength(BeastAnimationEnum.Blind);
		self._actionCDLeft.Reset(duration);
		self._blindCDLeft.Reset(duration);
		self.PlayAnimation(BeastAnimationEnum.Blind);
	}

	function Roar()
	{
		self.PlayAnimation(BeastAnimationEnum.EmoteRoar);
		self._actionCDLeft.Reset(self._transform.GetAnimationLength(BeastAnimationEnum.EmoteRoar));
	}

	function Attack()
	{
		self.PlayAnimation(BeastAnimationEnum.Attack);
		duration = self._transform.GetAnimationLength(BeastAnimationEnum.Attack);
		self._actionCDLeft.Reset(duration);
		self._attackCDLeft.Reset(duration);
	}

	function Move()
	{
		direction = self._target.Position - self.MapObject.Position;
		direction.Y = 0;
		direction = direction.Normalized;
		velocity = self._rigidbody.GetVelocity();
		velocity.X = 0;
		velocity.Z = 0;
		self._rigidbody.SetVelocity(direction * self.MoveSpeed + velocity);
	}

	function ThrowRock()
	{
		self.PlayAnimation(BeastAnimationEnum.Throw);
		duration = self._transform.GetAnimationLength(BeastAnimationEnum.Throw);
		self._actionCDLeft.Reset(duration);
		self._rockThrownCDLeft.Reset(duration - 1);
	}

	function RockBomb()
	{
		if (self._target == null)
		{
			return;
		}
		start = self._rock.Position;
		end = self._target.Position;
		direction = end - start;
		distance = direction.Magnitude;
		direction = direction.Normalized;
		start += 10 * direction.Normalized;
		end += 50 * direction.Normalized;

		effectRotation = Quaternion.LookRotation(direction).Euler;
		Game.SpawnEffect("Boom1", self._rock.Position, effectRotation, 5.0);

		result = Physics.LineCast(start, end, "All");
		if (result != null)
		{
			end = result.Point;
		}

		Game.SpawnEffect("Boom1", (self._rock.Position + end) * 0.7, effectRotation, 5.0);
		Game.SpawnEffect("Boom1", (self._rock.Position + end) * 0.3, effectRotation, 5.0);

		Game.SpawnEffect("Boom3", end, direction, 10.0);
		Game.SpawnEffect("Boom2", end, direction, 10.0);
		Game.SpawnEffect("Boom7", end, direction, 15.0);

		result2 = Physics.LineCast(end, end + 10 * Vector3.Down, "MapObjects");
		if (result2 != null)
		{
			Game.SpawnEffect("GroundShatter", result2.Point + Vector3.Up * 0.1, Vector3.Zero, 10.0);
		}

		Game.SpawnProjectile("Rock1", end + Vector3(-10, 10, 0), Vector3.Zero, Random.RandomVector3(Vector3(-20,5,0), Vector3(0,10,20)).Normalized * 100, Vector3(0, -10000, 0), 10.0, "Shifter",5.0);
		Game.SpawnProjectile("Rock1", end + Vector3(10, 10, 0), Vector3.Zero, Random.RandomVector3(Vector3(0,5,-20), Vector3(20,10,0)).Normalized * 100, Vector3(0, -10000, 0), 10.0, "Shifter", 5.0);
		Game.SpawnProjectile("Rock1", end + Vector3(0, 10, -10), Vector3.Zero, Random.RandomVector3(Vector3(-20,5,-20), Vector3(0,10,0)).Normalized * 100, Vector3(0, -10000, 0), 10.0, "Shifter", 5.0);
		Game.SpawnProjectile("Rock1", end + Vector3(0, 10, 10), Vector3.Zero, Random.RandomVector3(Vector3(0,5,0), Vector3(20,10,20)).Normalized * 100, Vector3(0, -10000, 0), 10.0, "Shifter", 5.0);

		self._bombHitBox.MapObject.Scale = Vector3(20,20,20);
		self._bombHitBox.MapObject.Position = end;
		self._bombHitBox.Bomb(0.2);
	}

	function _UpdateActions(t)
	{
		self.FindTarget();
		if (self._target == null)
		{
			return;
		}

		direction = self._target.Position - self.MapObject.Position;
		direction.Y = 0;
		distance = direction.Magnitude;
		isMove = true;
		angle = Vector3.SignedAngle(direction, self.MapObject.Forward, Vector3.Right);

		if (distance > 50)
		{
			self.Move();
			isMove = true;

			if (self._throwCDLeft.IsDone())
			{
				if (Random.RandomFloat(0,1) < 0.7)
				{
					self.ThrowRock();
				}
				self._throwCDLeft.Reset(self.ThrowCooldown);
			}
		}
		else
		{
			attackChosen = self._ChooseCloseRangeAttack();
			if (!attackChosen && Math.Abs(angle) > 30)
			{
				if (angle > 0)
				{
					self.PlayAnimation(BeastAnimationEnum.TurnRight);
					self._actionCDLeft.Reset(self._transform.GetAnimationLength(BeastAnimationEnum.TurnRight));
				}
				else
				{
					self.PlayAnimation(BeastAnimationEnum.TurnLeft);
					self._actionCDLeft.Reset(self._transform.GetAnimationLength(BeastAnimationEnum.TurnLeft));
				}
				self._turnDirection = direction.Normalized;
			}
			elif (!attackChosen)
			{
				self.Attack();
			}
		}

		if (isMove)
		{
			self.MapObject.Forward = Vector3.Lerp(self.MapObject.Forward, direction.Normalized, self.RotateSpeed * t);
		}
		else
		{
			velocity = self._rigidbody.GetVelocity();
			velocity.X = 0;
			velocity.Z = 0;
			self._rigidbody.SetVelocity(velocity);
		}
	}

	# @return bool
	function _ChooseCloseRangeAttack()
	{
		targetPos = self._target.Position;
		eyesPos = self._eyesHurtBox.MapObject.Position;
		napePos = self._napeHurtBox.MapObject.Position;

		distanceToEyes = (targetPos - eyesPos).Magnitude;
		distanceToNape = (targetPos - napePos).Magnitude;

		if (distanceToEyes < 15)
		{
			directionToTarget = (targetPos - self.MapObject.Position).Normalized;
			angleToTarget = Vector3.Angle(directionToTarget, self.MapObject.Forward);

			if (angleToTarget >= 70 && angleToTarget <= 85)
			{
				self.SlapFace();
				return true;
			}
		}

		if (distanceToNape < 10)
		{
			directionToTarget = (targetPos - self.MapObject.Position).Normalized;
			angleToTarget = Vector3.Angle(directionToTarget, self.MapObject.Forward * -1);

			if (angleToTarget >= 80 && angleToTarget <= 95)
			{
				self.SlapBack();
				return true;
			}
		}

		return false;
	}

	function SlapFace()
	{
		self.PlayAnimation(BeastAnimationEnum.AttackSlapFace);
		duration = self._transform.GetAnimationLength(BeastAnimationEnum.AttackSlapFace);
		self._actionCDLeft.Reset(duration);
		self._attackCDLeft.Reset(duration);
	}

	function SlapBack()
	{
		self.PlayAnimation(BeastAnimationEnum.AttackSlapBack);
		duration = self._transform.GetAnimationLength(BeastAnimationEnum.AttackSlapBack);
		self._actionCDLeft.Reset(duration);
		self._attackCDLeft.Reset(duration);
	}

	function GetDamaged(character, damage)
	{
		Game.ShowKillFeedAll(character.Name, self.DamageText, damage, character.Weapon);

		if (damage < self.Health)
		{
			self.Health -= damage;
		}
		elif (!self._dieOnce)
		{
			self._dieOnce = true;

			self.Health = 0;
			self._rigidbody=null;
			self.MapObject.SetComponentEnabled("Rigidbody", false);

			self._transform.Rotation = self._transform.Rotation + Vector3(10,0,0);
			self.WaitAndDie(self._actionCDLeft.GetTime());
			self._actionCDLeft.Reset(2.5);
			self.PlayAnimation(BeastAnimationEnum.Die);

			if (self._onDieHandler != null)
			{
				self._onDieHandler.Handle(character, damage);
			}
		}
	}

	coroutine WaitAndDie(delay)
	{
		t = Game.SpawnTitanAt("normal",self._transform.Position+Vector3(0,-200,0));
		t.PlaySound("Roar");
		t.Health=0;

		Game.SpawnEffect("Blood1", self._transform.Position+Vector3(0,80,0), Vector3.Zero, 10.0);
		Game.SpawnEffect("Blood2", self._transform.Position+Vector3(0,80,0), Vector3.Zero, 10.0);
		wait 0.5;
		Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
		Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
		Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
		Game.SpawnEffect("TitanDie2", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
		Game.SpawnEffect("TitanDie2", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
		Game.SpawnEffect("TitanDie2", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);

		wait 1.4;
		Game.SpawnEffect("Boom7", self._transform.Position+Vector3(0,25,0), Vector3.Zero, 50.0);
		self.PlayAnimation(BeastAnimationEnum.Die3);
		wait 1.0;
		self._transform.Position =self._transform.Position+ Vector3(0,0,0);

		Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,12,0), Vector3.Zero, 15.0);
		Game.SpawnEffect("TitanDie2", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
		wait 1.5;
		Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,12,0), Vector3.Zero, 15.0);
		Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,12,0), Vector3.Zero, 15.0);
		self.MapObject.Active = false;
	}

	function PlayAnimation(animation)
	{
		self._currentAnimation = animation;
		self._currentAnimationTime = 0.0;
		self._currentAttackState = 0;
		self._transform.PlayAnimation(animation);

		Dispatcher.CSendOthers(self, BeastPlayAnimationMessage.New(animation));
	}

	function OnFrame()
	{
		if (!self._initialized || !self._enabled || self.Health <= 0)
		{
			return;
		}

		if (self.NetworkView.Owner == Network.MyPlayer)
		{
			if (self._currentAnimation != null)
			{
				self._currentAnimationTime += Time.FrameTime;

				if (self._currentAnimation == BeastAnimationEnum.AttackSlapFace)
				{
					if (self._currentAttackState == 0 && self._currentAnimationTime > 1.68)
					{
						Game.SpawnEffect(
							EffectEnum.BOOM3,
							self._eyesHurtBox.MapObject.Position,
							Vector3(270.0, 0.0, 0.0),
							3.0
						);
	
						self._currentAttackState = 1;
					}
				}
				elif (self._currentAnimation == BeastAnimationEnum.AttackSlapBack)
				{
					if (self._currentAttackState == 0 && self._currentAnimationTime > 1.68)
					{
						Game.SpawnEffect(
							EffectEnum.BOOM3,
							self._napeHurtBox.MapObject.Position,
							Vector3(270.0, 0.0, 0.0),
							3.0
						);
						
						self._currentAttackState = 1;
					}
				}
			}

			self._UpdateCD(Time.FrameTime);
			if (!self._idleCDLeft.IsDone())
			{
				return;
			}

			if (self._actionCDLeft.IsDone())
			{
				self._currentAttackState = 0;
				self._currentAnimation = null;
				self._currentAnimationTime = 0.0;

				self._UpdateActions(Time.FrameTime);
			}

			if (self._target != null && !self._rockThrownCDLeft.IsDone())
			{
				direction = (self._target.Position - self.MapObject.Position);
				direction.Y = 0;
				direction = direction.Normalized;
				self.MapObject.Forward = Vector3.Lerp(self.MapObject.Forward, direction, self.RotateSpeed * Time.FrameTime);
			}

			if (self._turnDirection != null && !self._actionCDLeft.IsDone())
			{
				if (self.MapObject.Forward != self._turnDirection)
				{
					self.MapObject.Forward = Vector3.Lerp(self.MapObject.Forward, self._turnDirection, self.RotateSpeed * Time.FrameTime);
				}
				else
				{
					self._turnDirection = null;
				}
			}
			else
			{
				self._turnDirection = null;
			}
		}

		if (self._actionCDLeft.IsDone())
		{
			velocity = self._rigidbody.GetVelocity();
			velocity.Y = 0;
			if (velocity.Magnitude > 5)
			{
				self._transform.PlayAnimation(BeastAnimationEnum.Move, 0.2);
			}
			else
			{
				self._transform.PlayAnimation(BeastAnimationEnum.Idle, 0.2);
			}
		}

		self._rock.Transform.SetRenderersEnabled(!self._rockThrownCDLeft.IsDone());
	}

	function OnSecond()
	{
		if (
			!self._initialized
			|| !self._enabled
			|| self.NetworkView.Owner != Network.MyPlayer
			|| self.Health <= 0
		)
		{
			return;
		}

		self._UpdateTypeSwitch(1.0);
	}

	function OnNetworkMessage(sender, message)
	{
		self._router.Route(sender, message);
	}

	function SendNetworkStream()
	{
		self.NetworkView.SendStream(self.Health);
		self.NetworkView.SendStream(self._actionCDLeft.GetTime());
		self.NetworkView.SendStream(self._rockThrownCDLeft.GetTime());
		self.NetworkView.SendStream(self.MapObject.Active);
	}

	function OnNetworkStream()
	{
		self.Health = self.NetworkView.ReceiveStream();
		self._actionCDLeft.Reset(self.NetworkView.ReceiveStream());
		self._rockThrownCDLeft.Reset(self.NetworkView.ReceiveStream());
		self.MapObject.Active = self.NetworkView.ReceiveStream();
	}

	function _AddNape()
	{
		neck = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/neck");
		napeNew = Map.CreateMapObjectRaw("Scene,Geometry/Sphere1,0,0,1,0," + self._hitBoxVisibility + ",0,NapeCollider,0,0,0,0,0,0,6,3,3,Region,Hitboxes,Default,Transparent|0/255/0/111|Misc/None|1/1|0/0,ZekeNapeHurtBox");
		napeNew.Parent = neck;
		self._napeHurtBox = napeNew.GetComponent("ZekeNapeHurtBox");
		self._napeHurtBox.SetShifter(self);

		napeNew.LocalPosition = Vector3(0,0,-0.09);
		napeNew.LocalRotation = Vector3.Zero;
		napeNew.Forward = neck.Forward;

		head = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/neck/head");
		eyesHurtBox = Map.CreateMapObjectRaw("Scene,Geometry/Sphere1,0,0,1,0," + self._hitBoxVisibility + ",0,EyesCollider,0,0,0,0,0,0,6,3,3,Region,Hitboxes,Default,Transparent|0/0/255/111|Misc/None|1/1|0/0,ZekeEyesHurtBox");
		eyesHurtBox.Parent = head;
		self._eyesHurtBox = eyesHurtBox.GetComponent("ZekeEyesHurtBox");
		self._eyesHurtBox.SetShifter(self);

		eyesHurtBox.Forward = head.Forward;
		eyesHurtBox.LocalPosition = Vector3.Zero + Vector3(0, 0.1, 0.1);
	}

	function _AddHitBox()
	{
		self._armLeftTransform = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/shoulder.L/upper_arm.L/forearm.L/hand.L");
		armNew = Map.CreateMapObjectRaw("Scene,Geometry/Cube1,0,0,1,0," + self._hitBoxVisibility + ",0,ArmCollider,0,0,0,0,0,0,12,60,12,Region,Humans,Default,Transparent|255/0/0/111|Misc/None|1/1|0/0,ZekeHitBox");
		armNew.Parent = self._armLeftTransform;
		armNew.Forward = self._armLeftTransform.Forward;
		armNew.LocalPosition = Vector3.Zero;
		armNew.LocalRotation = Vector3.Zero;
		self._armLeftHitBox = armNew.GetComponent("ZekeHitBox");
		self._armLeftHitBox.SetShifter(self);
		self._armLeftHitBox.Damage = self.Damage;
		self._armLeftHitBox.DamageText = self.DamageText;

		self._armRightTransform = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/shoulder.R/upper_arm.R/forearm.R/hand.R");
		armNew = Map.CreateMapObjectRaw("Scene,Geometry/Cube1,0,0,1,0," + self._hitBoxVisibility + ",0,ArmCollider,0,0,0,0,0,0,12,60,12,Region,Humans,Default,Transparent|255/0/0/111|Misc/None|1/1|0/0,ZekeHitBox");
		armNew.Parent = self._armRightTransform;
		armNew.Forward = self._armRightTransform.Forward;
		armNew.LocalPosition = Vector3.Zero;
		armNew.LocalRotation = Vector3.Zero;
		self._armRightHitBox = armNew.GetComponent("ZekeHitBox");
		self._armRightHitBox.SetShifter(self);
		self._armRightHitBox.Damage = self.Damage;
		self._armRightHitBox.DamageText = self.DamageText;
	}

	function _AddRock()
	{
		self._rock = Map.CreateMapObjectRaw("Scene,Decor/Rubble1,0,0,1,0,1,0,Rock1,0,0,0,0,0,0,1,1,1,None,Humans,Default,DefaultNoTint|255/255/255/255,");
		self._rock.Parent = self._armRightTransform;
		self._rock.Forward = self._armRightTransform.Forward;
		self._rock.LocalPosition = Vector3(0,0.09,0.04);
		self._rock.LocalRotation = Vector3.Zero;
		self._bombHitBox = Map.CreateMapObjectRaw("Scene,Geometry/Sphere1,0,0,1,0," + self._hitBoxVisibility + ",0,Rock1HitBox,0,0,0,0,0,0,5,5,5,Region,Characters,Default,Transparent|255/0/0/111|Misc/None|1/1|0/0,ZekeBombHitBox").GetComponent("ZekeBombHitBox");
		self._bombHitBox.SetShifter(self);
		self._bombHitBox.Damage = self.Damage;
		self._bombHitBox.DamageText = self.DamageText;

	}

	function _RandomType()
	{
		return self._types.Get(
			Random.RandomInt(0, self._types.Count - 1)
		);
	}

	function _InitTypes()
	{
		self._typeSwitchCDLeft.Reset(self.TimeToTypeSwitch);

		if (
			!self.BeastTypeAssassinEnabled
			&& !self.BeastTypePitcherEnabled
			&& !self.BeastTypeWarriorEnabled
		)
		{
			self.BeastTypeAssassinEnabled = true;
			self.BeastTypePitcherEnabled = false;
			self.BeastTypeWarriorEnabled = false;
		}

		if (self.BeastTypeAssassinEnabled)
		{
			self._types.Add("Assassin");
		}
		if (self.BeastTypePitcherEnabled)
		{
			self._types.Add("Pitcher");
		}
		if (self.BeastTypeWarriorEnabled)
		{
			self._types.Add("Warrior");
		}
	}

	function _SwitchType(type)
	{
		if(type == "Pitcher")
		{
			BeastAnimationEnum.Move="Amarture_VER2|run.walk";
			self.MoveSpeed = 20;
			self.ThrowCooldown = 4;
			self.ActionCooldown = 2;
		}
		elif(type == "Warrior")
		{
			BeastAnimationEnum.Move="Amarture_VER2|run.abnormal.1";
			self.MoveSpeed = 100;
			self.ThrowCooldown = 6;
			self.ActionCooldown=1.5;
		}
		elif(type == "Assassin")
		{
			BeastAnimationEnum.Move="Amarture_VER2|run.abnormal.3";
			self.MoveSpeed = 120;
			self.ThrowCooldown = 8;
			self.ActionCooldown = 1.0;
		}

		self._currentType = type;
	}

	function _UpdateCD(t)
	{
		self._actionCDLeft.UpdateOn(t);
		self._attackCDLeft.UpdateOn(t);

		if (!self._rockThrownCDLeft.IsDone())
		{
			self._rockThrownCDLeft.UpdateOn(t);
			if (self._rockThrownCDLeft.IsDone())
			{
				self.RockBomb();
			}
		}

		self._throwCDLeft.UpdateOn(t);
		self._blindCDLeft.UpdateOn(t);
		self._idleCDLeft.UpdateOn(t);
	}

	function _UpdateTypeSwitch(t)
	{
		self._typeSwitchCDLeft.UpdateOn(t);

		if (self._typeSwitchCDLeft.IsDone())
		{
			self._SwitchType(self._RandomType());
			offset = Random.RandomFloat(self.TimeToTypeSwitchRandomOffset * -1.0, self.TimeToTypeSwitchRandomOffset);
			self._typeSwitchCDLeft.Reset(self.TimeToTypeSwitch + offset);
		}
	}
}

component ZekeNapeHurtBox
{
	# @type ZekeShifter
	_shifter = null;
	_getDamagedCoolDown = 0.0;

	# @param shifter ZekeShifter
	function SetShifter(shifter)
	{
		self._shifter = shifter;
		return self;
	}

	function OnTick()
	{
		if (self._getDamagedCoolDown > 0)
		{
			self._getDamagedCoolDown -= Time.TickTime;
		}
	}

	function OnGetHit(character, name, damage, type, hitPosition)
	{
		if (self._getDamagedCoolDown > 0)
		{
			return;
		}

		self._getDamagedCoolDown = 0.02;
		if (character.IsMainCharacter)
		{
			Dispatcher.CSend(self._shifter, self._shifter.NetworkView.Owner, BeastGetDamageMessage.New(character.ViewID, Convert.ToInt(damage)));
			Game.ShowKillScore(damage);
		}
	}
}

component ZekeEyesHurtBox
{
	# @type ZekeShifter
	_shifter = null;
	_getDamagedCoolDown = 0.0;

	# @param shifter ZekeShifter
	function SetShifter(shifter)
	{
		self._shifter = shifter;
		return self;
	}

	function OnTick()
	{
		if (self._getDamagedCoolDown > 0)
		{
			self._getDamagedCoolDown -= Time.TickTime;
		}
	}

	function OnGetHit(character, name, damage, type, hitPosition)
	{
		if (self._getDamagedCoolDown > 0)
		{
			return;
		}

		Dispatcher.CSend(self._shifter, self._shifter.NetworkView.Owner, BeastBlindMessage.New());

		self._getDamagedCoolDown = 5.0;
	}
}

component ZekeHitBox
{
	Damage = 1000;
	DamageText = "Beast Titan";

	# @type ZekeShifter
	_shifter = null;

	function SetShifter(shifter)
	{
		self._shifter = shifter;
		return self;
	}

	function OnCollisionEnter(other)
	{
		if (self._shifter._attackCDLeft.IsDone())
		{
			return;
		}
		if (other.Type != "Human")
		{
			return;
		}

		# @type Human
		human = other;

		human.GetDamaged(self.DamageText, self.Damage);
	}
}

component ZekeBombHitBox
{
	Damage = 1000;
	DamageText = "Beast Titan";

	# @type ZekeShifter
	_shifter = null;
	_bombCoolDown = 0.0;
	_hitTargets = Dict();

	function SetShifter(shifter)
	{
		self._shifter = shifter;
		return self;
	}

	function OnTick()
	{
		if (self._bombCoolDown > 0)
		{
			self._bombCoolDown -= Time.TickTime;
			if (self._bombCoolDown <= 0)
			{
				self._hitTargets.Clear();
				self.MapObject.Scale = Vector3.Zero;
				self.MapObject.LocalPosition = Vector3.Zero;
			}
		}
	}

	function OnCollisionStay(other)
	{
		if (self._bombCoolDown <= 0)
		{
			return;
		}
		if (other.Type != "Human")
		{
			return;
		}

		# @type Human
		human = other;

		if (self._hitTargets.Contains(human.ViewID))
		{
			return;
		}
		human.GetDamaged(self.DamageText, self.Damage);
		self._hitTargets.Set(human.ViewID, 0);
	}

	function Bomb(time)
	{
		self._bombCoolDown = time;
	}
}

extension BeastAnimationEnum
{
	Idle = "Amarture_VER2|idle";
	Move = "Amarture_VER2|run.walk";
	TurnLeft = "Amarture_VER2|turnaround.L";
	TurnRight = "Amarture_VER2|turnaround.R";

	Jump = "Amarture_VER2|attack.jumper.0";
	Fall = "Amarture_VER2|attack.jumper.1";
	Land = "Amarture_VER2|attack.jumper.2";

	SitIdle = "Amarture_VER2|sit_idle";
	SitDown = "Amarture_VER2|sit_down";
	SitUp = "Amarture_VER2|sit_getup";
	SitFall = "Amarture_VER2|sit_hunt_down";
	SitBlind = "Amarture_VER2|sit_hit_eye";

	Stun = "Amarture_VER2|hit.eren.L";
	StunRight = "Amarture_VER2|hit.eren.R";

	Die = "Amarture_VER2|die.front";
	DieBack = "Amarture_VER2|die.back";
	DieGround = "Amarture_VER2|die.ground";
	DieSit = "Amarture_VER2|sit_die";
	Die3 = "Amarture_VER2|crawler.die";

	Throw = "Amarture_VER2|attack.throw";
	Attack = "Amarture_VER2|attack.comboPunch";
	AttackCombo = "Amarture_VER2|attack.combo";
	AttackSlam = "Amarture_VER2|attack.front.ground";
	AttackKick = "Amarture_VER2|attack.kick";
	AttackStomp = "Amarture_VER2|attack.stomp";
	AttackSwingL = "Amarture_VER2|attack.swing.l";
	AttackSwingR = "Amarture_VER2|attack.swing.r";
	AttackBiteF = "Amarture_VER2|bite";
	AttackSlapFace = "Amarture_VER2|attack.slap.face";
	AttackSlapBack = "Amarture_VER2|attack.slap.back";
	AttackRoar = "Amarture_VER2|attack.scream";
	AttackGrabCoreL = "Amarture_VER2|grab.core.L";
	AttackGrabCoreR = "Amarture_VER2|grab.core.R";

	CoverNape = "Amarture_VER2|idle.recovery";
	Blind = "Amarture_VER2|hit.eye";

	EmoteLaugh = "Amarture_VER2|laugh";
	EmoteNod = "Amarture_VER2|emote_titan_yes";
	EmoteShake = "Amarture_VER2|emote_titan_no";
	EmoteRoar = "Amarture_VER2|attack.scream";
}

extension BeastPlayAnimationMessage
{
	TOPIC = "beast.play_animation";

	KEY_ANIMATION = "animation";

	function New(animation)
	{
		msg = Dict();
		msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
		msg.Set(self.KEY_ANIMATION, animation);
		return msg;
	}
}

class BeastPlayAnimationMessageHandler
{
	# @type ZekeShifter
	_beast = null;

	# @param beast ZekeShifter
	function Init(beast)
	{
		self._beast = beast;
	}

	function Handle(sender, msg)
	{
		animation = msg.Get(BeastPlayAnimationMessage.KEY_ANIMATION);

		self._beast._transform.PlayAnimation(animation);
	}
}

extension BeastGetDamageMessage
{
	TOPIC = "beast.get_damage";

	KEY_VIEW_ID = "view_id";
	KEY_DAMAGE = "damage";

	function New(viewID, damage)
	{
		msg = Dict();
		msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
		msg.Set(self.KEY_VIEW_ID, viewID);
		msg.Set(self.KEY_DAMAGE, damage);
		return msg;
	}
}

class BeastGetDamageMessageHandler
{
	# @type ZekeShifter
	_beast = null;

	# @param beast ZekeShifter
	function Init(beast)
	{
		self._beast = beast;
	}

	function Handle(sender, msg)
	{
		viewID = msg.Get(BeastGetDamageMessage.KEY_VIEW_ID);
		damage = msg.Get(BeastGetDamageMessage.KEY_DAMAGE);
		character = Game.FindCharacterByViewID(viewID);

		self._beast.GetDamaged(character, damage);
	}
}

extension BeastBlindMessage
{
	TOPIC = "beast.blind";

	function New()
	{
		msg = Dict();
		msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
		return msg;
	}
}

class BeastBlindMessageHandler
{
	# @type ZekeShifter
	_beast = null;

	# @param beast ZekeShifter
	function Init(beast)
	{
		self._beast = beast;
	}

	function Handle(sender, msg)
	{
		self._beast.Blind();
	}
}

extension GameState
{
	GameStarted = false;

	# @type List<TitanProxy>
	Titans = List();
}

extension InputManager
{
	# @type string
	Guide = null;
	# @type string
	Interaction1 = null;
	# @type string
	Interaction2 = null;
	# @type string
	SkipCutscene = null;
	# @type string
	SwitchWeapon = null;

	function InitKeybinds()
	{
		Input.SetKeyDefaultEnabled(KeyBindsEnum.INTERACTION_FUNCTION1, false);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.INTERACTION_FUNCTION3, false);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.INTERACTION_FUNCTION4, false);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.GENERAL_SKIPCUTSCENE, false);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.INTERACTION_ITEMMENU, false);

		self.Guide = KeyBindsEnum.INTERACTION_FUNCTION1;
		self.Interaction1 = KeyBindsEnum.INTERACTION_FUNCTION3;
		self.Interaction2 = KeyBindsEnum.INTERACTION_FUNCTION4;
		self.SkipCutscene = KeyBindsEnum.GENERAL_SKIPCUTSCENE;
		self.SwitchWeapon = KeyBindsEnum.INTERACTION_ITEMMENU;
	}
}

extension UIManager
{
	# @type Dict<string, Dict<string, ITextProvider>>
	_providersByRate = Dict();
	# @type Dict<string, Dict<string, string>>
	_activeTexts = Dict();

	# @param pos string
	# @param provider ITextProvider
	# @param rate string
	function RegisterProvider(pos, provider, rate)
	{
		dict = self._providersByRate.Get(rate, Dict());
		self._providersByRate.Set(rate, dict);
		dict.Set(pos, provider);
	}

	function OnFrame()
	{
		self._UpdateLabels(UpdateRateEnum.Frame);
	}

	function OnTick()
	{
		self._UpdateLabels(UpdateRateEnum.Tick);
	}

	function OnSecond()
	{
		self._UpdateLabels(UpdateRateEnum.Second);
	}

	# @param rate string
	function _UpdateLabels(rate)
	{
		providers = self._providersByRate.Get(rate, Dict());

		for (pos in providers.Keys)
		{
			newText  = providers.Get(pos).String();

			oldText  = self._activeTexts.Get(pos, "");
			if (newText != oldText)
			{
				UI.SetLabel(pos, newText);
				self._activeTexts.Set(pos, newText);
			}
		}
	}
}

class ITextProvider
{
	# @return string
	function String(){}
}

extension UpdateRateEnum
{
	Tick   = "Tick";
	Frame  = "Frame";
	Second = "Second";
}

extension MusicManager
{
	BGM_1_2_CODE = "BGM1-BGM2";
	BGM_3_4_CODE = "BGM3-BGM4";
	BGM_5_6_CODE = "BGM5-BGM6";

	_collection = Dict();

	# @type MapObject
	_currentlyPlaying = null;

	function Initialize()
	{
		for (obj in Map.FindMapObjectsByTag("BGM"))
		{
			self._collection.Set(obj.Name, obj);
		}
	}

	# @param code string
	function Play(code)
	{
		self.Stop();

		if (!self._collection.Contains(code))
		{
			Game.SetPlaylist(code);
			return;
		}

		self._currentlyPlaying = self._collection.Get(code);
		self._currentlyPlaying.Active = true;
	}

	# @param code string
	# @param fadeInDelay float
	# @param fadeOutDelay float
	coroutine CrossFade(code, fadeInDelay, fadeOutDelay)
	{
		if (!self._collection.Contains(code))
		{
			Game.SetPlaylist(code);
			wait fadeOutDelay;
			self.Stop();
			return;
		}

		toStop = self._currentlyPlaying;

		wait fadeInDelay;
		self._currentlyPlaying = self._collection.Get(code);
		self._currentlyPlaying.Active = true;

		if (toStop == null)
		{
			return;
		}

		wait fadeOutDelay;
		toStop.Active = false;
	}

	function Stop()
	{
		Game.SetPlaylist("None");
		if (self._currentlyPlaying == null)
		{
			return;
		}

		self._currentlyPlaying.Active = false;
		self._currentlyPlaying = null;
	}
}

extension CutsceneManager
{
	_timers = Dict();
	_cutscenesState = Dict();
	_cutscenesCanPlay = Dict();
	_timer = Timer(0.0);
	_pendingTimer = Timer(0.0);
	_pendingCutsceneID = null;
	_pendingCutsceneFull = null;
	_isCutsceneRunning = false;
	_skipSignal = false;

	# @param id string
	# @param full bool
	function Start(id, full)
	{
		if (self._pendingCutsceneID == id || !self.GetCanPlay(id))
		{
			return;
		}

		if (self._isCutsceneRunning)
		{
			self._pendingCutsceneID = id;
			self._pendingCutsceneFull = full;
			self._skipSignal = true;
		}
		else
		{
			self.SetCanPlay(id, false);
			self._isCutsceneRunning = true;
			Cutscene.Start(id, full);
		}
	}

	# @param t float
	function Wait(t)
	{
		self._timer.Reset(t);
	}

	function ResetTimer()
	{
		self._timer.Reset(0.0);
	}

	function IsTimerDone()
	{
		return self._timer.IsDone();
	}

	function GetState(k)
	{
		return self._cutscenesState.Get(k, 0);
	}

	# @param k string
	# @param v int
	function SetState(k, v)
	{
		return self._cutscenesState.Set(k, v);
	}

	# @param k string
	function GetCanPlay(k)
	{
		return self._cutscenesCanPlay.Get(k, true);
	}

	# @param k string
	# @param v bool
	function SetCanPlay(k, v)
	{
		return self._cutscenesCanPlay.Set(k, v);
	}

	# @return bool
	function SkipSent()
	{
		return self._skipSignal;
	}

	function OnTick()
	{
		self._timer.UpdateOnTick();

		if (!self._isCutsceneRunning)
		{
			self._pendingTimer.UpdateOnTick();
			pID = self._pendingCutsceneID;
			pFull = self._pendingCutsceneFull;
			if (self._pendingTimer.IsDone() && pID != null)
			{
				# self._pendingTimer.Reset(0.25);
				self._isCutsceneRunning = true;
				self._pendingCutsceneID = null;
				self._pendingCutsceneFull = null;
				self.SetCanPlay(pID, false);
				Cutscene.Start(pID, pFull);
			}
		}
	}

	function ResetAll()
	{
		if (self._isCutsceneRunning)
		{
			self._skipSignal = true;
		}
		else
		{
			self._skipSignal = false;
		}
		self._pendingCutsceneID = null;
		self._pendingCutsceneFull = null;

		self._cutscenesState.Clear();
		self._cutscenesCanPlay.Clear();

		self._isCutsceneRunning = false;
	}

	# @param k string
	function OnCutsceneComplete(k)
	{
		self.Wait(0.0);
		self._isCutsceneRunning = false;
		self._skipSignal = false;
		if (self._pendingCutsceneID != null)
		{
			self._pendingTimer.Reset(0.1);
		}
	}
}

#######################
# Messages
#######################

extension SetLocalizedLabelMessage
{
	TOPIC = "set_localized_label";

	KEY_POSITION = "position";
	KEY_LOCALIZED_KEY = "localized_key";
	KEY_PARAMS = "params";
	KEY_TIME = "time";

	function New(
		position,
		localizedKey,
		params,
		time
	)
	{
		msg = Dict();
		msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
		msg.Set(self.KEY_POSITION, position);
		msg.Set(self.KEY_LOCALIZED_KEY, localizedKey);
		msg.Set(self.KEY_PARAMS, params);
		msg.Set(self.KEY_TIME, time);
		return msg;
	}
}

extension PlayMusicMessage
{
	TOPIC = "play_music";

	KEY_CODE = "code";

	function New(code)
	{
		msg = Dict();
		msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
		msg.Set(self.KEY_CODE, code);
		return msg;
	}
}

extension RunCutsceneMessage
{
	TOPIC = "run_cutscene";

	KEY_ID = "id";

	function New(id)
	{
		msg = Dict();
		msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
		msg.Set(self.KEY_ID, id);
		return msg;
	}
}

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
		if (self._currentNode == null)
		{
			return null;
		}
		return self._currentNode._event.Goal();
	}
}

extension I18n
{
	ArabicLanguage = "العربية";
	BrasilianPortugueseLanguage = "PT-BR";
	ChineseLanguage = "简体中文";
	CzechLanguage = "Čeština";
	DutchLanguage = "Dutch";
	EnglishLanguage = "English";
	FrenchLanguage = "Français";
	GermanLanguage = "Deutsch";
	GreekLanguage = "Ελληνικά";
	IndonesianLanguage = "Indonesian";
	ItalianLanguage = "Italiano";
	JapaneseLanguage = "日本語";
	KoreanLanguage = "한국어";
	PolishLanguage = "Polski";
	RussianLanguage = "Russian";
	SpanishLanguage = "Español";
	TraditionalChineseLanguage = "繁體中文";
	TurkishLanguage = "Türkçe";

	# @type Dict<string, Dict<string, string>>
	_languages = Dict();
	# @type string
	_defaultLanguage = null;

	# @param key string
	# @return string
	function Get(key)
	{
		pack = self._LoadLanguagePack();
		localized = pack.Get(key, null);
		if (localized != null)
		{
			return localized;
		}
		else
		{
			Game.Print(key);
		}

		defaultPack = self._languages.Get(self._defaultLanguage);
		localized = defaultPack.Get(key, null);
		if (localized != null)
		{
			return localized;
		}

		return "[ERR] Localized string not found: " + key;
	}

	# @param language string
	function SetDefaultLanguage(language)
	{
		self._defaultLanguage = language;
	}

	# @param pack LanguagePack
	function RegisterLanguagePack(pack)
	{
		self._languages.Set(pack.Language(), pack.Load());

		if (self._defaultLanguage == null)
		{
			self._defaultLanguage = pack.Language();
		}
	}

	# @return Dict<string, string>
	function _LoadLanguagePack()
	{
		return self._languages.Get(UI.GetLanguage(), self._languages.Get(self._defaultLanguage));
	}
}

class LanguagePack
{
	# @return Dict<string, string>
	function Load(){}

	# @return string
	function Language(){}
}

extension HTML
{
	# @param str string
	# @param color string
	# @return string
	function Color(str, color)
	{
		return "<color=#" + color + ">" + str + "</color>";
	}

	# @param str string
	# @param size int
	# @return string
	function Size(str, size)
	{
		return "<size=" + size + ">" + str + "</size>";
	}

	# @param str string
	# @return string
	function Bold(str)
	{
		return "<b>" + str + "</b>";
	}

	# @param str string
	# @return string
	function Italic(str)
	{
		return "<i>" + str + "</i>";
	}
}

#######################
# Events
#######################

class KillTitansEvent
{
	CODE_IN_PROGRESS = -1;
	CODE_COMPLETED = 0;
	CODE_ALL_DIED = 1;
	CODE_OUT_OF_TIME = 2;

	_status = -1;
	_cutscene1Once = false;
	_cutscene2Once = false;

	_timeLeft = 0.0;
	_playersReady = false;
	_titansNumForPhase2 = 0;

	# @param time float|null
	# @param titans int
	function Init(time, titans)
	{
		self._timeLeft = time;
		self._titansNumForPhase2 = titans;
	}

	# @param t float
	function Update(t)
	{
		if (self.IsDone())
		{
			return;
		}

		self._playersReady = self._playersReady || Game.Humans.Count > 0;
		if (!self._playersReady)
		{
			Game.SpawnPlayerAll(false);
			return;
		}

		if(!self._cutscene1Once)
		{
			self._cutscene1Once = true;
			Dispatcher.SendAll(RunCutsceneMessage.New(1));
		}

		if (!GameState.GameStarted)
		{
			return;
		}

		if (self._timeLeft != null) {
			self._timeLeft -= t;
		}

		if (Game.Humans.Count == 0)
		{
			Dispatcher.SendAll(RunCutsceneMessage.New(4));
			Dispatcher.SendAll(SetLocalizedLabelMessage.New(
				"MiddleCenter",
				"ui.lose",
				null,
				10.0
			));

			Game.End(10.0);

			for(t in Game.Titans)
			{
				t.Emote("Laugh");
			}

			self._status = self.CODE_ALL_DIED;
			return;
		}
		elif(Game.Titans.Count <= 3)
		{
			self._status = self.CODE_COMPLETED;
			return;
		}
		elif (self._timeLeft != null && self._timeLeft <= 0)
		{
			Game.End(10.0);

			Dispatcher.SendAll(RunCutsceneMessage.New(5));
			Dispatcher.SendAll(SetLocalizedLabelMessage.New(
				"MiddleCenter",
				"ui.lose.2",
				null,
				10.0
			));

			self._status = self.CODE_OUT_OF_TIME;
			return;
		}
		elif (!self._cutscene2Once && Game.Titans.Count <= self._titansNumForPhase2)
		{
			self._cutscene2Once = true;
			Dispatcher.SendAll(RunCutsceneMessage.New(2));
		}
	}

	# @return string
	function Goal()
	{
		if (self.IsDone())
		{
			return "";
		}

		params = List();
		params.Add(Convert.ToString(Game.Titans.Count));
		if (self._timeLeft == null)
		{
			return String.FormatFromList(I18n.Get("ui.goal.kill_titans"), params);
		}
		else
		{
			params.Add(String.FormatFloat(self._timeLeft, 0));

			return String.FormatFromList(I18n.Get("ui.goal.kill_titans_time"), params);
		}
	}

	# @return string
	function GoalKey()
	{
		if (!GameState.GameStarted)
		{
			return "";
		}

		if (self._timeLeft == null)
		{
			return "ui.goal.kill_titans";
		}
		else
		{
			return "ui.goal.kill_titans_time";
		}
	}

	# @return List<string>
	function GoalParams()
	{
		params = List();
		params.Add(Convert.ToString(Game.Titans.Count));
		if (self._timeLeft != null)
		{
			params.Add(String.FormatFloat(self._timeLeft, 0));
		}
		return params;
	}

	# @return boolean
	function IsDone(){
		return self._status != self.CODE_IN_PROGRESS;
	}

	# @return string
	function Outcome(){
		return self._status;
	}
}

class KillBeastEvent
{
	CODE_IN_PROGRESS = -1;
	CODE_COMPLETED = 0;
	CODE_ALL_DIED = 1;
	CODE_OUT_OF_TIME = 2;

	_status = -1;
	_beastKilled = false;

	# @type ZekeShifter
	_beastTitan = null;

	_timeLeft = 0.0;

	_once = false;

	# @param time float|null
	# @param beastTitan ZekeShifter
	function Init(time, beastTitan)
	{
		self._timeLeft = time;
		self._beastTitan = beastTitan;
		self._beastTitan.RegisterOnDieHandler(self);
	}

	# @param t float
	function Update(t)
	{
		if (self.IsDone())
		{
			return;
		}

		if (!self._once)
		{
			Dispatcher.SendAll(RunCutsceneMessage.New(3));
			self._once = true;
		}

		if (self._timeLeft != null) {
			self._timeLeft -= t;
		}

		if (Game.Humans.Count == 0)
		{
			Dispatcher.SendAll(RunCutsceneMessage.New(4));
			Dispatcher.SendAll(SetLocalizedLabelMessage.New(
				"MiddleCenter",
				"ui.lose",
				null,
				10.0
			));

			Game.End(10.0);

			for(t in Game.Titans)
			{
				t.Emote("Laugh");
			}

			self._status = self.CODE_ALL_DIED;
			return;
		}
		elif (self._beastKilled)
		{
			if(Network.IsMasterClient)
			{
				Dispatcher.SendAll(RunCutsceneMessage.New(6));
				Dispatcher.SendAll(SetLocalizedLabelMessage.New(
					"MiddleCenter",
					"ui.zeke_defeated",
					null,
					10.0
				));
				Game.End(10.0);
			}
			self._status = self.CODE_COMPLETED;
		}
		elif (self._timeLeft != null && self._timeLeft <= 0)
		{
			Game.End(10.0);

			Dispatcher.SendAll(RunCutsceneMessage.New(5));
			Dispatcher.SendAll(SetLocalizedLabelMessage.New(
				"MiddleCenter",
				"ui.lose.2",
				null,
				10.0
			));

			self._status = self.CODE_OUT_OF_TIME;
			return;
		}
	}

	# Callback for Beast
	function Handle(character, damage)
	{
		self._beastKilled = true;
	}

	# @return string
	function Goal()
	{
		if (self.IsDone())
		{
			return "";
		}

		if (self._beastTitan._enabled)
		{
			monkey1Text = HTML.Size(I18n.Get("general.beast.sentencecase"), 25);
			monkeyText = HTML.Color(monkey1Text, ColorEnum.Brown);

			params = List();
			params.Add(monkeyText);

			return String.FormatFromList(I18n.Get("ui.goal.kill_beast"), params);
		}
	}

	# @return string
	function GoalKey()
	{
		if (self.IsDone())
		{
			return "";
		}

		return "ui.goal.kill_beast";
	}

	# @return List<string>
	function GoalParams()
	{
		return null;
	}

	# @return boolean
	function IsDone(){
		return self._status != self.CODE_IN_PROGRESS;
	}

	# @return string
	function Outcome(){
		return self._status;
	}
}

class TitanProxy
{
	# @type Titan
	Titan = null;

	_locking = false;
	_lockingPos = Vector3();
	_lockingTimer = Timer(0.0);

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

	# @param pos Vector3
	# @param time float
	function Lock(pos, time)
	{
		self._lockingPos = pos;
		self._lockingTimer.Reset(time);
		self._locking = true;
	}

	function OnTick()
	{
		self._UpdateLocking(Time.TickTime);
	}

	function _UpdateLocking(t)
	{
		if (!self._locking)
		{
			return;
		}

		self._lockingTimer.UpdateOnTick();
		if (self._lockingTimer.IsDone())
		{
			self._locking = false;
			return;
		}

		self.Titan.Position = self._lockingPos;
	}
}

extension TitanTargetSwitcher
{
	MinDamage = 1000;

	# @param Human
	_currentTarget = null;

	function OnCharacterDamaged(victim, killer, killerName, damage)
	{
		if (victim.Type == "Titan")
		{
			if (damage >= self.MinDamage && self._currentTarget != killer)
			{
				self._currentTarget = killer;

				killer.AddOutline(Color(255,0,0), "OutlineVisible");

				if(Network.IsMasterClient)
				{
					for(t in GameState.Titans)
					{
						t.Target(killer, 15);
					}

					params = List();
					params.Add(killer.Name);

					Dispatcher.SendAll(SetLocalizedLabelMessage.New(
						"MiddleCenter",
						"ui.titans_target",
						params,
						6.0
					));
				}
			}
		}
	}
}

extension TitanSpawner
{
	_spawnFxSize = 5.0;
	_boomFxOffset = Vector3.Up * 100.0;
	_boomFxRotation = Vector3(0.0, 20.0, 0.0);
	_boomFxSize = 4.0;

	# @param type string
	# @param pos Vector3
	function Spawn(type, pos)
	{
		fxPos = pos;

		Game.SpawnTitanAt(type, pos);
		for (i in Range(1, 4, 1))
		{
			Game.SpawnEffect("ShifterThunder", fxPos, Vector3.Zero, i * 1.5);
		}
		Game.SpawnEffect("TitanSpawnEffect", fxPos, Vector3.Zero, self._spawnFxSize);
		Game.SpawnEffect("Boom7", fxPos + self._boomFxOffset, self._boomFxRotation, self._boomFxSize);
	}

	# @param type string
	# @param pos Vector3
	# @param delay float
	coroutine SpawnAsync(type, pos, delay)
	{
		wait delay;
		self.Spawn(type, pos);
	}
}

#######################
# Message Handlers
#######################

class SetLocalizedLabelMessageHandler
{
	function Handle(sender, msg)
	{
		position = msg.Get(SetLocalizedLabelMessage.KEY_POSITION);
		localizedKey = msg.Get(SetLocalizedLabelMessage.KEY_LOCALIZED_KEY);
		params = msg.Get(SetLocalizedLabelMessage.KEY_PARAMS, null);
		time = msg.Get(SetLocalizedLabelMessage.KEY_TIME, null);

		if (localizedKey == "")
		{
			UI.SetLabel(position, "");
			return;
		}

		if (params != null)
		{
			label = String.FormatFromList(I18n.Get(localizedKey), params);
		}
		else
		{
			label = I18n.Get(localizedKey);
		}

		if (time != null)
		{
			UI.SetLabelForTime(position, label, time);
		}
		else
		{
			UI.SetLabel(position, label);
		}
	}
}

class PlayMusicMessageHandler
{
	function Handle(sender, msg)
	{
		code = msg.Get(PlayMusicMessage.KEY_CODE);

		MusicManager.Play(code);
	}
}

class RunCutsceneMessageHandler
{
	function Handle(sender, msg)
	{
		id = msg.Get(RunCutsceneMessage.KEY_ID);

		CutsceneManager.Start("Cutscene_" + id, false);
	}
}

class EnglishLanguagePack
{
	# @type Dict<string, string>
	_pack = Dict();

	# @return Dict<string, string>
	function Load()
	{
		return self._pack;
	}

	# @return string
	function Language()
	{
		return I18n.EnglishLanguage;
	}

	function Init()
	{
		self._pack.Set("general.beast.lowercase", "beast titan");
		self._pack.Set("general.beast.uppercase", "BEAST TITAN");
		self._pack.Set("general.beast.titlecase", "Beast Titan");
		self._pack.Set("general.beast.sentencecase", "Beast titan");

		self._pack.Set("chat.start", "Kill your companions, Stop Zeke");
		self._pack.Set("chat.soldier_died", "Soldier {0} is dead.");

		self._pack.Set("info.beast_type.pitcher", "Pitcher
		Using throwing as the main attack method, it has a relatively slow movement speed and the least health.");
		self._pack.Set("info.beast_type.warrior", "Warrior
		It has both melee and long-range capabilities, with a relatively fast movement speed and the highest health points.");
		self._pack.Set("info.beast_type.assassin", "Assassin
		It mainly uses close combat as its attack method, has extremely fast movement speed and relatively low health points.");
		self._pack.Set("info.special_events.stronger", "The companions has transformed into an even more powerful titans!!");
		self._pack.Set("info.special_events.last_chance", "Without supplies, cross the Rubicon River!");

		self._pack.Set("ui.info.title", "How to play");
		self._pack.Set("ui.info.rules", "Check out the Rules");
		self._pack.Set("ui.info.switch_weapon", "Switch Weapon");
		self._pack.Set("ui.info.beast_type", "Beast Titan Type");
		self._pack.Set("ui.info.special_events", "Special Events");
		self._pack.Set("ui.info.levi_mode", "Levi Mode-ON");

		self._pack.Set("guide.mao", "OrangeCat橘猫");
		self._pack.Set("guide.1", "Welcome to {0}'s {1} map!");
		self._pack.Set("guide.2", "Here's what to look out for when you first play:");
		self._pack.Set("guide.3", "How To Play");
		self._pack.Set("guide.4", "Kill the titans within the time limit, and when there are no more than 5 titans left, {0} will appear.");
		self._pack.Set("guide.5", "Then, the game end condition is: {0} dies, or all players die.");

		self._pack.Set("guide.recommendations.header", "Recommendations");
		self._pack.Set("guide.recommendations.skill", "Skill-Spin1");
		self._pack.Set("guide.recommendations.weapon", "Weapon-Only Blade or Thunderspear");
		self._pack.Set("guide.recommendations.difficulty", "Difficulty-Abnormal");
		self._pack.Set("guide.recommendations.settings.endless", "Endless Respawn-off");
		self._pack.Set("guide.recommendations.settings.invincible", "Spawn invincible time-15s");

		self._pack.Set("guide.description.header", "Description of the Map");
		self._pack.Set("guide.description.body", "The attack speed and movement speed of PT are extremely fast, and it has unlimited stamina
When you use the Thunderspear, you will be able to obtain more gas
Ban AHSS/APG
Ban Dance/Eren/Annie skill,Limited supply and limited battle time
Some building/supply sites can be destroyed
Players who score more than a certain number of kill points will become the target of all titans within 20 seconds
		When Levi Mode is OFF, the player's health points are fixed at 100, and they are not immune to the attacks of the Beast Titan");

		self._pack.Set("guide.mode_settings.header", "Mode setting");
		self._pack.Set("guide.mode_settings.1", "The number of various titans");
		self._pack.Set("guide.mode_settings.2", "Number of blades/Thunderspear bullets");
		self._pack.Set("guide.mode_settings.3", "Gas quantity");
		self._pack.Set("guide.mode_settings.4", "Whether ThrowBlade is allowed");
		self._pack.Set("guide.mode_settings.5", "Set the skills of all players using blades to spin1");
		self._pack.Set("guide.mode_settings.6", "Spin1/Spin2/Spin3 skill no CD");
		self._pack.Set("guide.mode_settings.7", "Whether to strengthen Spin1/Spin2/Spin3");
		self._pack.Set("guide.mode_settings.8", "Levi Mode: Spin no CD
Automatically lock the back of the Titan's neck
		The Beast Titan can't hurt you");
		self._pack.Set("guide.mode_settings.9", "The minimum kill score to be targeted by all the titans");
		self._pack.Set("guide.mode_settings.10", "Limited Time(Until Beast titan appeared)");
		self._pack.Set("guide.mode_settings.11", "Beast titan Type:Pitcher/Warrior/Assassin");
		self._pack.Set("guide.mode_settings.12", "Make the Titans stronger");
		self._pack.Set("guide.mode_settings.13", "Whether to highlight the stronger titans");
		self._pack.Set("guide.mode_settings.14", "Without supplies, cross the Rubicon River");
		self._pack.Set("guide.mode_settings.15", "Whether to highlight the players");
		self._pack.Set("guide.mode_settings.16", "Game Music");
		self._pack.Set("guide.mode_settings.17", "The Health of the PT");

		self._pack.Set("guide.staff.header", "STAFF");
		self._pack.Set("guide.staff.yy", "天格 绅士君");
		self._pack.Set("guide.staff.xx", "Callis");
		self._pack.Set("guide.staff.hongyao", "Hongyao");
		self._pack.Set("guide.staff.kun", "君");
		self._pack.Set("guide.staff.levi", "Levi");
		self._pack.Set("guide.staff.hikari", "Hikari");
		self._pack.Set("guide.staff.ring", "Ring");
		self._pack.Set("guide.staff.han", "ㅎㄱ");
		self._pack.Set("guide.staff.jagerente", "Jagerente");

		self._pack.Set("guide.staff.yy.role", "Beast Titan Model");
		self._pack.Set("guide.staff.xx.role", "Beast Titan Animations");
		self._pack.Set("guide.staff.hongyao.role", "Beast Titan CL");
		self._pack.Set("guide.staff.kun_levi.role", "CL Assistants");
		self._pack.Set("guide.staff.hikari.role", "Localization, optimizations");
		self._pack.Set("guide.staff.ring.role", "Levi Mode CL");
		self._pack.Set("guide.staff.han.role", "Korean Localization");
		self._pack.Set("guide.staff.jagerente.role", "CL Rework, refactoring & optimizations");

		self._pack.Set("guide.about.header", "About the Tea party");
		self._pack.Set("guide.about.contacts", "Contact information");
		self._pack.Set("guide.about.1", "茶话会TeaParty, is a technical guild from China.");
		self._pack.Set("guide.about.2", "we will discuss about Custom Logic, ASO, Racing and other AOTTG game content.");
		self._pack.Set("guide.about.3", "we've been working on creating or optimizing some Custom contents recently.");
		self._pack.Set("guide.about.4", "We are responsible for making some minor changes and translations to them");
		self._pack.Set("guide.about.5", "so that excellent custom maps from China can also appear here!");
		self._pack.Set("guide.about.qq_group", "QQ group: 662494094");
		self._pack.Set("guide.about.discord", "Discord: 茶话会TeaParty (https://discord.gg/RdhPSUAMSt)");

		self._pack.Set("ui.goal.kill_titans", "{0} titans need to be killed, or Zeke will escape the forest");
		self._pack.Set("ui.goal.kill_beast", HTML.Size(HTML.Color("Beast Titan", ColorEnum.Brown), 25) + " has appeared. Kill him!");
		self._pack.Set("ui.goal.kill_titans_time", "{0} titans need to be killed, or Zeke will escape the forest | Time Left: {1}s");

		self._pack.Set("ui.lose", "This is the gap between the ordinary soldier and Ackerman...");
		self._pack.Set("ui.lose.2", "There's no one left to stop Zeke...");

		self._pack.Set("ui.titans_target", "The titans' target: {0}");

		self._pack.Set("dialogue.name.zeke", "Zeke Jager");
		self._pack.Set("dialogue.name.levi", "Levi Ackerman");

		self._pack.Set("dialogue.a.1", "YEAAAAAAAAAAGH!!!");
		self._pack.Set("dialogue.a.2", "No...");
		self._pack.Set("dialogue.a.3", "Farewell, Levi... Your soldiers did nothing wrong. They just... got a little bigger..");
		self._pack.Set("dialogue.a.4", "You're not really going to cut them down for that... are you?");
		self._pack.Set("dialogue.a.5", "Zeke's spinal fluid was in the wine...?! When did he even mix it in...? There were no signs. No one froze up... Or was that part a lie?");
		self._pack.Set("dialogue.a.6", "Damn it! They're fast... Is that Zeke's doing too?! Varis...!! Are you still in there? All of you...?");

		self._pack.Set("dialogue.b.1", "What a shame... We never really learned to trust each other.");
		self._pack.Set("dialogue.b.2", "The entire world's armies will soon descend on this island. You have no idea... what that truly means.");
		self._pack.Set("dialogue.b.3", "You thought you had strength, time, choices... They were just foolish illusions.");
		self._pack.Set("dialogue.b.4", "It wouldn't have mattered. Even if I had told you my true intentions... you wouldn't have understood.");
		self._pack.Set("dialogue.b.5", "Eren, once I'm out of this forest, I'll be by your side in an instant!");

		self._pack.Set("dialogue.c.ui.1", "{0} <color=#FF0000> has entered the battlefield!</color>
		Hide behind trees to avoid being crushed by his rocks!");
		self._pack.Set("dialogue.c.1", "MMMMGH!! FORWAAAAARD!!");
		self._pack.Set("dialogue.c.2", "Where'd you go, LEVI?! Where are your cute little soldiers?! Don't tell me you killed them all! Poor little things!");
		self._pack.Set("dialogue.c.3", "What?! Branches...?!");
		self._pack.Set("dialogue.c.4", "You're desperate, you bearded bastard. All you had to do was lie low and read your books. What made you think... you could escape from me?");
		self._pack.Set("dialogue.c.5", "Did you really think I wouldn't kill them? Just because you turned them into Titans?");
		self._pack.Set("dialogue.c.6", "You have no idea... how many friends we've had to put down!");

		self._pack.Set("dialogue.d.chat", "The fallen comrades stared right through us...");
		self._pack.Set("dialogue.d.1", "This is goodbye, Levi.");
		self._pack.Set("dialogue.d.2", "Eren, I'll be with you soon!");

		self._pack.Set("dialogue.e.chat", "You could never be him, no matter what...");
		self._pack.Set("dialogue.e.1", "Looks like that guy won't be catching up anytime soon. Rot in this forest, Levi.");
		self._pack.Set("dialogue.e.2", "Eren's dream — our dream... No one will ever stop it!");

		# self._pack.Set("dialogue.f.chat", "何も捨てることができない人には、何も変えることはできない...");
		self._pack.Set("dialogue.f.chat", "If you can't let go of anything, you can't change anything.");
		self._pack.Set("dialogue.f.1", "NOOOOOOOOOOOOOOOO!!!!");
		self._pack.Set("dialogue.f.2", "Hey, Beardy. Look at you...
you reeking, filthy, ugly piece of shit. Well... Don't worry. I won't kill you.
		NOT YET.");

		self._pack.Set("interaction.chat.1", "
I get annoyed when I see Zeke...
——OrangeCat橘猫

Someone always has to take the lead in doing something, doesn't they?
——Hikari

Meow~
		——君");

		self._pack.Set("interaction.chat.2", "
At work...
——Hongyao

A new member of the tea party who is seriously studying custom logic.
——Ring

AVE 83.
		——Jagerente");

		self._pack.Set("ui.zeke_defeated", "Zeke Jager was defeated! Humanity wins!");
	}
}

class KoreanLanguagePack
{
	# @type Dict<string, string>
	_pack = Dict();

	# @return Dict<string, string>
	function Load()
	{
		return self._pack;
	}

	# @return string
	function Language()
	{
		return I18n.KoreanLanguage;
	}

	function Init()
	{
		self._pack.Set("general.beast.lowercase", "짐승 거인");
		self._pack.Set("general.beast.uppercase", "짐승 거인");
		self._pack.Set("general.beast.titlecase", "짐승 거인");
		self._pack.Set("general.beast.sentencecase", "짐승 거인");

		self._pack.Set("chat.start", "동료를 죽여라, 지크를 멈춰라.");
		self._pack.Set("chat.soldier_died", "병사 {0}가 죽었다.");

		self._pack.Set("info.beast_type.pitcher", "투수
		투석을 주 공격 방식으로 사용하며, 비교적 느린 이동 속도와 가장 낮은 체력을 가지고 있습니다.");
		self._pack.Set("info.beast_type.warrior", "전사
		근접 및 원거리 공격 능력을 모두 갖추었으며, 비교적 빠른 이동 속도와 가장 높은 체력을 가지고 있습니다.");
		self._pack.Set("info.beast_type.assassin", "암살자
		주로 근접 전투를 공격 방식으로 사용하며, 매우 빠른 이동 속도와 비교적 낮은 체력을 가지고 있습니다.");
		self._pack.Set("info.special_events.stronger", "동료들이 더욱 강력한 거인이 되었습니다!!");
		self._pack.Set("info.special_events.last_chance", "보급품 없이 루비콘 강을 건너십시오!");

		self._pack.Set("ui.info.title", "게임 방법");
		self._pack.Set("ui.info.rules", "규칙 확인");
		self._pack.Set("ui.info.switch_weapon", "무기 교체");
		self._pack.Set("ui.info.beast_type", "짐승 거인 타입");
		self._pack.Set("ui.info.special_events", "특수 이벤트");
		self._pack.Set("ui.info.levi_mode", "리바이 모드-활성화");

		self._pack.Set("guide.mao", "OrangeCat橘猫");
		self._pack.Set("guide.1", "{0} 의 {1} 맵에 오신 것을 환영합니다!");
		self._pack.Set("guide.2", "처음 플레이할 때 주의할 점은 다음과 같습니다:");
		self._pack.Set("guide.3", "게임 방법");
		self._pack.Set("guide.4", "제한 시간 내에 거인을 처치하고, 거인이 5마리 이하로 줄면, {0} 이 등장합니다.");
		self._pack.Set("guide.5", "그럼 게임 종료 조건은: {0} 이 죽거나, 모든 유저가 죽는 것입니다.");

		self._pack.Set("guide.recommendations.header", "추천");
		self._pack.Set("guide.recommendations.skill", "스킬-Spin1");
		self._pack.Set("guide.recommendations.weapon", "장비-검 또는 뇌창 중 택 1");
		self._pack.Set("guide.recommendations.difficulty", "난이도-기행종");
		self._pack.Set("guide.recommendations.settings.endless", "무한 리스폰-비활성화");
		self._pack.Set("guide.recommendations.settings.invincible", "스폰 무적 시간-15초");

		self._pack.Set("guide.description.header", "맵 설명");
		self._pack.Set("guide.description.body", "플레이어 거인의 공격 속도와 이동 속도는 매우 빠르며, 스태미너가 무제한입니다.
뇌창을 사용하면 가스를 더 많이 얻을 수 있습니다.
대인/신형 사용 금지
댄스/에렌/애니 스킬 사용 금지, 보급과 전투 시간이 제한되어 있습니다.
일부 건물 및 보급 지점은 파괴될 수 있습니다.
일정 킬 점수 이상을 획득한 플레이어는 20초 동안 모든 거인의 타겟이 됩니다.
		리바이 모드가 꺼져 있을 때 플레이어의 체력은 100으로 고정되며, 짐승 거인의 공격에 면역되지 않습니다.");

		self._pack.Set("guide.mode_settings.header", "모드 셋팅");
		self._pack.Set("guide.mode_settings.1", "거인 수");
		self._pack.Set("guide.mode_settings.2", "칼날 수");
		self._pack.Set("guide.mode_settings.3", "가스 양");
		self._pack.Set("guide.mode_settings.4", "칼날 투척 사용이 허용되는지 여부");
		self._pack.Set("guide.mode_settings.5", "칼날을 사용하는 모든 플레이어의 스킬을 Spin1으로 설정하십시오.");
		self._pack.Set("guide.mode_settings.6", "돌려베기 1/2/3 스킬 쿨타임 없음.");
		self._pack.Set("guide.mode_settings.7", "돌려베기 1/2/3 강화 여부");
		self._pack.Set("guide.mode_settings.8", "리바이 모드: 돌려베기 스킬 쿨타임 없음.
거인의 목 뒷부분을 자동으로 조준함.
		짐승 거인의 공격에 피해 없음.");
		self._pack.Set("guide.mode_settings.9", "모든 거인의 타겟이 되기 위한 최소 킬 점수");
		self._pack.Set("guide.mode_settings.10", "제한 시간 (짐승 거인이 등장할 때까지)");
		self._pack.Set("guide.mode_settings.11", "짐승 거인 타입: 투수 / 전사 / 암살자");
		self._pack.Set("guide.mode_settings.12", "더욱 강력한 거인");
		self._pack.Set("guide.mode_settings.13", "강화된 거인의 강조 여부");
		self._pack.Set("guide.mode_settings.14", "보급없이 루비콘 강 건너기");
		self._pack.Set("guide.mode_settings.15", "플레이어 강조 여부");
		self._pack.Set("guide.mode_settings.16", "게임 음악");
		self._pack.Set("guide.mode_settings.17", "플레이어 거인의 체력");

		self._pack.Set("guide.staff.header", "STAFF");
		self._pack.Set("guide.staff.yy", "天格 绅士君");
		self._pack.Set("guide.staff.xx", "Callis");
		self._pack.Set("guide.staff.hongyao", "Hongyao");
		self._pack.Set("guide.staff.kun", "君");
		self._pack.Set("guide.staff.levi", "Levi");
		self._pack.Set("guide.staff.hikari", "Hikari");
		self._pack.Set("guide.staff.ring", "Ring");
		self._pack.Set("guide.staff.han", "ㅎㄱ");
		self._pack.Set("guide.staff.jagerente", "Jagerente");

		self._pack.Set("guide.staff.yy.role", "짐승 거인 모델");
		self._pack.Set("guide.staff.xx.role", "짐승 거인 애니메이션");
		self._pack.Set("guide.staff.hongyao.role", "짐승 거인 로직");
		self._pack.Set("guide.staff.kun_levi.role", "커스텀 로직 전문가");
		self._pack.Set("guide.staff.hikari.role", "최적화 및 번역가");
		self._pack.Set("guide.staff.ring.role", "리바이 모드 로직");
		self._pack.Set("guide.staff.han.role", "번역가");
		self._pack.Set("guide.staff.jagerente.role", "멀티 로컬라이제이션 지원, 리팩토링 및 최적화");

		self._pack.Set("guide.about.header", "Tea party에 관하여");
		self._pack.Set("guide.about.contacts", "컨텐츠 정보");
		self._pack.Set("guide.about.1", "茶话会TeaParty는 중국에 있는 기술 길드입니다.");
		self._pack.Set("guide.about.2", "우리는 커스텀 로직, ASO, 레이싱 및 기타 AOTTG 게임 콘텐츠에 대해 이야기 합니다.");
		self._pack.Set("guide.about.3", "저희는 최근에 몇 가지 커스텀 콘텐츠를 제작하거나 최적화하는 작업을 하고 있습니다.");
		self._pack.Set("guide.about.4", "저희 팀은 그것들에 대해 약간의 수정과 번역 작업을 담당하고 있습니다.");
		self._pack.Set("guide.about.5", "중국의 훌륭한 커스텀 맵들도 여기서도 등장할 수 있도록 말입니다!");
		self._pack.Set("guide.about.qq_group", "QQ 그룹: 662494094");
		self._pack.Set("guide.about.discord", "디스코드: 茶话会TeaParty (https://discord.gg/RdhPSUAMSt)");

		self._pack.Set("ui.goal.kill_titans", "{0} 마리의 거인들을 죽여야 합니다, 그렇지 않으면 지크가 숲을 빠져나갈 것입니다.");
		self._pack.Set("ui.goal.kill_beast", HTML.Size(HTML.Color("짐승 거인", ColorEnum.Brown), 25) + " 이 등장했습니다, 그를 죽이세요!");
		self._pack.Set("ui.goal.kill_titans_time", "{0} 마리의 거인들을 죽여야 합니다, 그렇지 않으면 지크가 숲을 빠져나갈 것입니다. | 남은시간: {1}초");

		self._pack.Set("ui.lose", "이것이 평범한 병사와 아커만의 차이입니다..");
		self._pack.Set("ui.lose.2", "지크를 막을 사람은 이제 아무도 없습니다..");

		self._pack.Set("ui.titans_target", "거인들의 표적: {0}");

		self._pack.Set("dialogue.name.zeke", "지크 예거");
		self._pack.Set("dialogue.name.levi", "리바이 아커만");

		self._pack.Set("dialogue.a.1", "으아아아아아아!!!");
		self._pack.Set("dialogue.a.2", "잠깐...");
		self._pack.Set("dialogue.a.3", "잘 있어라, 리바이… 네 병사들은 잘못한 게 없어. 다만 조금 더 커졌을 뿐이야.");
		self._pack.Set("dialogue.a.4", "그 하나 때문에 그들을 산산조각 내겠다고 하진 않겠지?");
		self._pack.Set("dialogue.a.5", "지크의 척수액이 와인에 섞여 있었다고…?!
대체 언제부터 준비 해놨던 거지...?
전혀 그런 흔적이 없었는데..
		아무도 경직되지 않았어... 거짓말이었나?");
		self._pack.Set("dialogue.a.6", "망할, 빠르구만! 몸놀림이 예사롭지 않아… 이것도 지크의 소행인가!
		바리스..!! 너희들… 아직 거기 있는 거냐?");

		self._pack.Set("dialogue.b.1", "결별이다...
		끝내 서로를 믿지 못했으니...");
		self._pack.Set("dialogue.b.2", "전 세계의 모든 세력이 이 섬에 모이려 하고 있어.
		그게 무슨 뜻인지 이해를 못 하고 있어.");
		self._pack.Set("dialogue.b.3", "자신들한테는 힘과 시간, 선택권을 가지고 있다고 생각했지.
		그건 모두 어리석은 믿음이다...");
		self._pack.Set("dialogue.b.4", "뭐 내 진의를 털어놓은 들 이해해줄 턱이 없겠다마는...");
		self._pack.Set("dialogue.b.5", "에렌, 내가 이 숲을 벗어나면
		금방 네 곁으로 갈거다!");

		self._pack.Set("dialogue.c.ui.1", "{0} <color=#FF0000> 이 전장에 나타났습니다!!</color>
		투석을 피하려면 나무 뒤에 숨으십시오!");
		self._pack.Set("dialogue.c.1", "뭐냐고! 진짜!!!");
		self._pack.Set("dialogue.c.2", "어디로 간 거냐!? 리바이!
네 부하들은 어디 갔냐!
		설마 죽인 거냐? 불쌍하게도!!");
		self._pack.Set("dialogue.c.3", "뭣?! 나뭇가지...?!");
		self._pack.Set("dialogue.c.4", "넌 너무 절박했어, 수염 면상아.
		그저 앉아서 독서만 하면 된건데, 대체 뭘 믿고 내게서 도망칠 수 있다고 생각한거지?");
		self._pack.Set("dialogue.c.5", "나한테서 도망칠 수 있을 거라고 생각했나?
		부하들을 거인으로 만들면 내가 동료들을 못 죽일 줄 알았던 거냐?");
		self._pack.Set("dialogue.c.6", "아마 너는 모를 거야...
		우리가 얼마나 많은 동료들을 죽여야 했는지!!");

		self._pack.Set("dialogue.d.chat", "희생된 동료들이 우리를 응시하고 있습니다...");
		self._pack.Set("dialogue.d.1", "작별이다, 리바이.");
		self._pack.Set("dialogue.d.2", "에렌, 내가 곧 그 곳으로 가마!!");

		self._pack.Set("dialogue.e.chat", "결국 당신은 그가 될 수 없었습니다...");
		self._pack.Set("dialogue.e.1", "저 녀석이 나를 따라잡지 못하는 것 같군.
		여기서 묻혀라, 리바이.");
		self._pack.Set("dialogue.e.2", "에렌과 나의 위대한 대의는... 그 아무도 막을 수 없어!!");

		# self._pack.Set("dialogue.f.chat", "何も捨てることができない人には、何も変えることはできない...");
		self._pack.Set("dialogue.f.chat", "아무것도 버릴 수 없는 사람은 아무것도 바꿀 수 없다.");
		self._pack.Set("dialogue.f.1", "안돼에!!!!!!!");
		self._pack.Set("dialogue.f.2", "어이, 수염 면상.
너 좀 봐... 썩고, 더럽고, 추악한 놈 같으니라고. 그래도 걱정 마. 널 죽이진 않을 거야.
		아직은 말이지");

		self._pack.Set("interaction.chat.1", "
지크를 보면 짜증이 나…
——OrangeCat橘猫

누군가는 항상 뭔가를 하는 데 앞장서야 하지 않겠어?
——Hikari

먀옹~
		——君");

		self._pack.Set("interaction.chat.2", "
일하는 중...
——Hongyao

커스텀 로직을 진지하게 공부하는 티파티의 새로운 멤버입니다.
——Ring

AVE 83.
		——Jagerente");

		self._pack.Set("ui.zeke_defeated", "지크 예거가 패배했습니다! 인류의 승리!");
	}
}

class RussianLanguagePack
{
	# @type Dict<string, string>
	_pack = Dict();

	# @return Dict<string, string>
	function Load()
	{
		return self._pack;
	}

	# @return string
	function Language()
	{
		return I18n.RussianLanguage;
	}

	function Init()
	{
		self._pack.Set("general.beast.lowercase", "звероподобный титан");
		self._pack.Set("general.beast.uppercase", "ЗВЕРОПОДОБНЫЙ ТИТАН");
		self._pack.Set("general.beast.titlecase", "Звероподобный Титан");
		self._pack.Set("general.beast.sentencecase", "Звероподобный титан");

		self._pack.Set("chat.start", "Убей своих соратников, останови Зика");
		self._pack.Set("chat.soldier_died", "Солдат {0} убит.");

		self._pack.Set("info.beast_type.pitcher", "Стрелок
		Использует метание в качестве основного метода атаки, обладает относительно низкой скоростью передвижения и минимальным запасом здоровья.");
		self._pack.Set("info.beast_type.warrior", "Воин
		Обладает как ближними, так и дальнобойными атаками, относительно высокой скоростью передвижения и наибольшим запасом здоровья.");
		self._pack.Set("info.beast_type.assassin", "Убийца
		В основном использует ближний бой, обладает очень высокой скоростью передвижения и относительно низким запасом здоровья.");
		self._pack.Set("info.special_events.stronger", "Соратники превратились в ещё более могущественных титанов!!");
		self._pack.Set("info.special_events.last_chance", "Припасы закончились, пересеките реку Рубикон!");

		self._pack.Set("ui.info.title", "Как играть");
		self._pack.Set("ui.info.rules", "Правила");
		self._pack.Set("ui.info.switch_weapon", "Сменить оружие");
		self._pack.Set("ui.info.beast_type", "Состояние звероподобного титана");
		self._pack.Set("ui.info.special_events", "Особые события");
		self._pack.Set("ui.info.levi_mode", "Режим Леви: ВКЛ");

		self._pack.Set("guide.mao", "OrangeCat橘猫");
		self._pack.Set("guide.1", "Добро пожаловать на карту {1}, созданную {0}!");
		self._pack.Set("guide.2", "На что обратить внимание при первой игре:");
		self._pack.Set("guide.3", "Как играть");
		self._pack.Set("guide.4", "Убейте титанов в отведённое время, и когда останется не больше 5 титанов, появится {0}.");
		self._pack.Set("guide.5", "Условие окончания игры: {0} умирает или умирают все игроки.");

		self._pack.Set("guide.recommendations.header", "Рекомендации");
		self._pack.Set("guide.recommendations.skill", "Навык - Spin1");
		self._pack.Set("guide.recommendations.weapon", "Оружие - Клинки или Громовые копья");
		self._pack.Set("guide.recommendations.difficulty", "Сложность - Аномальная");
		self._pack.Set("guide.recommendations.settings.endless", "Бесконечное возрождение - выкл");
		self._pack.Set("guide.recommendations.settings.invincible", "Время неуязвимости при появлении - 15с");

		self._pack.Set("guide.description.header", "Описание карты");
		self._pack.Set("guide.description.body", "Скорость атаки и скорость передвижения PT чрезвычайно высоки, а выносливость неограничена
При использовании Громового копья вы сможете получать больше газа
AHSS/APG запрещены
Навыки Танец/Эрен/Анни запрещены, ограниченное снабжение и ограниченное время битвы
Некоторые здания/точки снабжения могут быть разрушены
Игроки, набравшие больше определенного количества очков за убийства, в течение 20 секунд становятся целью всех титанов
		Когда режим Леви выключен, здоровье игрока фиксировано на уровне 100, и он не невосприимчив к атакам Звероподобного титана");

		self._pack.Set("guide.mode_settings.header", "Настройки игры");
		self._pack.Set("guide.mode_settings.1", "Количество различных титанов");
		self._pack.Set("guide.mode_settings.2", "Количество лезвий/снарядов Громового копья");
		self._pack.Set("guide.mode_settings.3", "Количество газа");
		self._pack.Set("guide.mode_settings.4", "Разрешено ли метание лезвий");
		self._pack.Set("guide.mode_settings.5", "Установить навык Spin1 всем игрокам, использующим клинки");
		self._pack.Set("guide.mode_settings.6", "Навыки Spin1/Spin2/Spin3 без перезарядки");
		self._pack.Set("guide.mode_settings.7", "Усилить навыки Spin1/Spin2/Spin3");
		self._pack.Set("guide.mode_settings.8", "Режим Леви: навык Spin без перезарядки
Автоматически фиксировать затылок титана
		Звероподобный титан не может вас ранить");
		self._pack.Set("guide.mode_settings.9", "Минимальный счет за убийства, при котором вы становитесь целью всех титанов");
		self._pack.Set("guide.mode_settings.10", "Ограниченное время (до появления Звероподобного титана)");
		self._pack.Set("guide.mode_settings.11", "Тип Звероподобного титана: Стрелок/Воин/Убийца");
		self._pack.Set("guide.mode_settings.12", "Сделать титанов сильнее");
		self._pack.Set("guide.mode_settings.13", "Выделять усиленных титанов");
		self._pack.Set("guide.mode_settings.14", "Без припасов пересечь реку Рубикон");
		self._pack.Set("guide.mode_settings.15", "Выделять игроков");
		self._pack.Set("guide.mode_settings.16", "Музыка игры");
		self._pack.Set("guide.mode_settings.17", "Здоровье PT");

		self._pack.Set("guide.staff.header", "КОМАНДА");
		self._pack.Set("guide.staff.yy", "天格 绅士君");
		self._pack.Set("guide.staff.xx", "Callis");
		self._pack.Set("guide.staff.hongyao", "Hongyao");
		self._pack.Set("guide.staff.kun", "君");
		self._pack.Set("guide.staff.levi", "Levi");
		self._pack.Set("guide.staff.hikari", "Hikari");
		self._pack.Set("guide.staff.ring", "Ring");
		self._pack.Set("guide.staff.han", "ㅎㄱ");
		self._pack.Set("guide.staff.jagerente", "Jagerente");

		self._pack.Set("guide.staff.yy.role", "Модель Звероподобного титана");
		self._pack.Set("guide.staff.xx.role", "Анимация Звероподобного титана");
		self._pack.Set("guide.staff.hongyao.role", "CL Звероподобного титана");
		self._pack.Set("guide.staff.kun_levi.role", "CL ассистены");
		self._pack.Set("guide.staff.hikari.role", "Локализация, оптимизация");
		self._pack.Set("guide.staff.ring.role", "CL Режима Леви");
		self._pack.Set("guide.staff.han.role", "Корейская локализация");
		self._pack.Set("guide.staff.jagerente.role", "Локализация, рефакторинг и оптимизация");

		self._pack.Set("guide.about.header", "О Tea Party");
		self._pack.Set("guide.about.contacts", "Контактная информация");
		self._pack.Set("guide.about.1", "茶话会 TeaParty — техническая гильдия из Китая.");
		self._pack.Set("guide.about.2", "Мы обсуждаем Custom Logic, ASO, Racing и другой контент игры AoTTG.");
		self._pack.Set("guide.about.3", "В последнее время мы работаем над созданием или оптимизацией пользовательского контента.");
		self._pack.Set("guide.about.4", "Мы отвечаем за внесение незначительных изменений и переводов в них");
		self._pack.Set("guide.about.5", "чтобы отличные пользовательские карты из Китая тоже могли появиться здесь!");
		self._pack.Set("guide.about.qq_group", "Группа QQ: 662494094");
		self._pack.Set("guide.about.discord", "Discord: 茶话会 TeaParty (https://discord.gg/RdhPSUAMSt)");

		self._pack.Set("ui.goal.kill_titans", "Необходимо убить {0} титанов, иначе Зик сбежит из леса");
		self._pack.Set("ui.goal.kill_beast", HTML.Size(HTML.Color("Звероподобный Титан", ColorEnum.Brown), 25) + " появился. Убей его!");
		self._pack.Set("ui.goal.kill_titans_time", "Необходимо убить {0} титанов, иначе Зик сбежит из леса | Осталось времени: {1}с");

		self._pack.Set("ui.lose", "Вот тебе и разница между обычным солдатом и Аккерманом...");
		self._pack.Set("ui.lose.2", "Больше некому остановить Зика...");

		self._pack.Set("ui.titans_target", "Цель титанов: {0}");

		self._pack.Set("dialogue.name.zeke", "Зик Йегер");
		self._pack.Set("dialogue.name.levi", "Леви Аккерман");

		self._pack.Set("dialogue.a.1", "ЙЕЕЕЕЕЕЕЕЕЕГХ!!!");
		self._pack.Set("dialogue.a.2", "Нет...");
		self._pack.Set("dialogue.a.3", "Прощай, Леви... Твои солдаты не виноваты. Они просто... выросли немного.");
		self._pack.Set("dialogue.a.4", "Ты ведь не станешь рубить их на куски за это, правда?");
		self._pack.Set("dialogue.a.5", "В вине была спинальная жидкость Зика…?! Когда он успел это провернуть…? Не было ни единого признака. Никто даже не оцепенел… Или всё это было ложью?");
		self._pack.Set("dialogue.a.6", "Чёрт побери! Они слишком быстрые… Это тоже проделки Зика?! Варис…!! Вы там живы… все вы…?");

		self._pack.Set("dialogue.b.1", "Как жаль… Мы так и не научились доверять друг другу.");
		self._pack.Set("dialogue.b.2", "Вся мощь мира вот-вот обрушится на этот остров. Ты даже не представляешь, что это значит.");
		self._pack.Set("dialogue.b.3", "Ты думал, у тебя есть сила, время, выбор… Но это были лишь наивные иллюзии.");
		self._pack.Set("dialogue.b.4", "Что ж… Ты бы всё равно не понял. Даже если бы я открыл тебе свои настоящие намерения.");
		self._pack.Set("dialogue.b.5", "Эрен, как только я покину этот лес — я буду с тобой в одно мгновение!");

		self._pack.Set("dialogue.c.ui.1", "{0} <color=#FF0000> прибыл на поле боя!!</color>
		Укрывайся за деревьями, чтобы избежать попадания камней!");
		self._pack.Set("dialogue.c.1", "ММММГХ!! ВПЕРЁД!!");
		self._pack.Set("dialogue.c.2", "Где ты, ЛЕВИ?! Где твои миленькие солдатики?! Не говори, что ты их всех перебил! Бедняжки!");
		self._pack.Set("dialogue.c.3", "Что?! Ветви…?!");
		self._pack.Set("dialogue.c.4", "Ты отчаянный, бородатый ублюдок. Тебе всего-то нужно было спокойно отдохнуть… Что заставило тебя поверить, будто ты сбежишь от меня?");
		self._pack.Set("dialogue.c.5", "Ты и правда думал, что я пощажу их только потому, что ты превратил их в титанов?");
		self._pack.Set("dialogue.c.6", "Ты даже не представляешь, сколько друзей нам пришлось уничтожить!!!");

		self._pack.Set("dialogue.d.chat", "Жертвенные соратники пристально смотрели на нас…");
		self._pack.Set("dialogue.d.1", "Это прощание, Леви.");
		self._pack.Set("dialogue.d.2", "Эрен, я скоро буду рядом!");

		self._pack.Set("dialogue.e.chat", "Ты всё равно никогда не сможешь быть им…");
		self._pack.Set("dialogue.e.1", "Похоже, этот парень за мной не угонится. Закопай себя здесь, Леви.");
		self._pack.Set("dialogue.e.2", "Великая цель Эрэна и моя… Никто её не остановит!");

		self._pack.Set("dialogue.f.chat", "Если ты не можешь ничего отпустить, ты не можешь ничего изменить.");
		self._pack.Set("dialogue.f.1", "НЕТТТТТТТТТТТТ!!!!");
		self._pack.Set("dialogue.f.2", "Эй, Бородач. Посмотри на себя… Ты воняешь, грязный, уродливый кусок дерьма. Но… Не волнуйся. Я не убью тебя. Пока что.");

		self._pack.Set("interaction.chat.1", "
Меня раздражает, когда я вижу Зика...
——OrangeCat橘猫

Кто-то всегда должен брать на себя инициативу, не так ли?
——Hikari

Миу~
		——君");

		self._pack.Set("interaction.chat.2", "
На работе...
——Hongyao

Новый участник TeaParty, который серьёзно изучает Custom Logic.
——Ring

AVE 83.
		——Jagerente");

		self._pack.Set("ui.zeke_defeated", "Zeke Jager was defeated! Humanity wins!");
	}
}

extension GameGuideUI
{
	function Initialize()
	{
		UI.CreatePopup("GameGuide", "游戏规则", 1000, 1000);

		monkey1Text = HTML.Size(I18n.Get("general.beast.uppercase"), 35);
		monkeyText = HTML.Color(monkey1Text, ColorEnum.Brown);
		MaoText = HTML.Color(I18n.Get("guide.mao"), ColorEnum.Orange);

		params = List();
		params.Add(MaoText);
		params.Add(monkeyText);
		text = String.FormatFromList(I18n.Get("guide.1"), params);
		text += String.Newline;
		text += I18n.Get("guide.2");
		text += String.Newline;
		text += String.Newline;
		headerText = HTML.Color(I18n.Get("guide.3"), ColorEnum.Orange);
		text += headerText;
		text += String.Newline;
		params = List();
		params.Add(monkeyText);
		text += String.FormatFromList(I18n.Get("guide.4"), params);
		text += String.Newline;
		text += String.FormatFromList(I18n.Get("guide.5"), params);
		text += String.Newline;
		text += String.Newline;

		headerText = HTML.Color(I18n.Get("guide.recommendations.header"), ColorEnum.Orange);
		text += headerText;
		text += String.Newline;
		text += I18n.Get("guide.recommendations.skill");
		text += String.Newline;
		text += I18n.Get("guide.recommendations.weapon");
		text += String.Newline;
		text += I18n.Get("guide.recommendations.difficulty");
		text += String.Newline;
		text += I18n.Get("guide.recommendations.settings.endless");
		text += String.Newline;
		text += I18n.Get("guide.recommendations.settings.invincible");
		text += String.Newline;
		text += String.Newline;
		text += String.Newline;

		headerText = HTML.Color(I18n.Get("guide.description.header"), ColorEnum.Orange);
		text += headerText;
		text += String.Newline;
		text += I18n.Get("guide.description.body");
		text += String.Newline;
		text += String.Newline;

		headerText = HTML.Color(I18n.Get("guide.mode_settings.header"), ColorEnum.Orange);
		text += headerText;
		text += String.Newline;
		text += "1." + I18n.Get("guide.mode_settings.1");
		text += String.Newline;
		text += "2." + I18n.Get("guide.mode_settings.2");
		text += String.Newline;
		text += "3." + I18n.Get("guide.mode_settings.3");
		text += String.Newline;
		text += "4." + I18n.Get("guide.mode_settings.4");
		text += String.Newline;
		text += "5." + I18n.Get("guide.mode_settings.5");
		text += String.Newline;
		text += "6." + I18n.Get("guide.mode_settings.6");
		text += String.Newline;
		text += "7." + I18n.Get("guide.mode_settings.7");
		text += String.Newline;
		text += "8." + I18n.Get("guide.mode_settings.8");
		text += String.Newline;
		text += "9." + I18n.Get("guide.mode_settings.9");
		text += String.Newline;
		text += "10." + I18n.Get("guide.mode_settings.10");
		text += String.Newline;
		text += "11." + I18n.Get("guide.mode_settings.11");
		text += String.Newline;
		text += "12." + I18n.Get("guide.mode_settings.12");
		text += String.Newline;
		text += "13." + I18n.Get("guide.mode_settings.13");
		text += String.Newline;
		text += "14." + I18n.Get("guide.mode_settings.14");
		text += String.Newline;
		text += "15." + I18n.Get("guide.mode_settings.15");
		text += String.Newline;
		text += "16." + I18n.Get("guide.mode_settings.16");
		text += String.Newline;
		text += "17." + I18n.Get("guide.mode_settings.17");
		text += String.Newline;
		text += String.Newline;

		headerText = HTML.Color(I18n.Get("guide.staff.header"), ColorEnum.Orange);
		yyText = HTML.Color(I18n.Get("guide.staff.yy"), ColorEnum.Blue);
		xxText = HTML.Color(I18n.Get("guide.staff.xx"), ColorEnum.Cyan);
		hyText = HTML.Color(I18n.Get("guide.staff.hongyao"), ColorEnum.Fuchsia);
		kunText = HTML.Color(I18n.Get("guide.staff.kun"), ColorEnum.Green);
		LeviText = HTML.Color(I18n.Get("guide.staff.levi"), ColorEnum.Yellow);
		hikariText = HTML.Color(I18n.Get("guide.staff.hikari"), ColorEnum.Red);
		RingText = HTML.Color(I18n.Get("guide.staff.ring"), ColorEnum.Brown);
		HanText = HTML.Color(I18n.Get("guide.staff.han"), ColorEnum.Red);
		JagerenteText = HTML.Color(I18n.Get("guide.staff.jagerente"), ColorEnum.Fuchsia);

		text += headerText;
		text += String.Newline;
		text += yyText+"  " + I18n.Get("guide.staff.yy.role");
		text += String.Newline;
		text += xxText + "  " + I18n.Get("guide.staff.xx.role");
		text += String.Newline;
		text += hyText + "  " + I18n.Get("guide.staff.hongyao.role");
		text += String.Newline;
		text += kunText + " & "+ LeviText + "  " + I18n.Get("guide.staff.kun_levi.role");
		text += String.Newline;
		text += hikariText + "  " + I18n.Get("guide.staff.hikari.role");
		text += String.Newline;
		text += RingText + "  " + I18n.Get("guide.staff.ring.role");
		text += String.Newline;
		text += HanText + "  " + I18n.Get("guide.staff.han.role");
		text += String.Newline;
		text += JagerenteText + "  " + I18n.Get("guide.staff.jagerente.role");
		text += String.Newline;
		text += String.Newline;
		text += String.Newline;
		headerText = HTML.Color(I18n.Get("guide.about.header"), ColorEnum.Fuchsia);
		joinText = HTML.Color(I18n.Get("guide.about.contacts"), ColorEnum.Cyan);
		text += headerText;
		text += String.Newline;
		text += I18n.Get("guide.about.1");
		text += String.Newline;
		text += I18n.Get("guide.about.2");
		text += String.Newline;
		text += I18n.Get("guide.about.3");
		text += String.Newline;
		text += I18n.Get("guide.about.4");
		text += String.Newline;
		text += I18n.Get("guide.about.5");
		text += String.Newline;
		text += String.Newline;
		text += joinText;
		text += String.Newline;
		text += I18n.Get("guide.about.qq_group");
		text += String.Newline;
		text += I18n.Get("guide.about.discord");
		text += String.Newline;
		text += String.Newline;

		UI.AddPopupLabel("GameGuide", text);
	}
}

extension SupplyStationSwitcher
{
	# @type List<MapObject>
	_supplyStations = null;

	function Initialize()
	{
		self._supplyStations = Map.FindMapObjectsByComponent("SupplyStation");
	}

	function Activate()
	{
		for (s in self._supplyStations)
		{
			s.SetComponentEnabled("SupplyStation", true);
		}
	}

	function Deactivate()
	{
		for (s in self._supplyStations)
		{
			s.SetComponentEnabled("SupplyStation", false);
		}
	}
}

