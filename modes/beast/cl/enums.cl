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
