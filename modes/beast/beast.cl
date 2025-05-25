/*主函数*/
class Main
{

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

	/*猩猩点灯*/
    	_spawenTitansdelay1 = null;
    	_spawenTitansdelay2 = null;
    	_spawenTitansdelay3 = null;
	_spawenTitansdelay4 = null;
	_spawenTitansdelay5 = null;

	/*AnniHp=8000;*/
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
	Spin123PlusTooltip="Whether to strengthen Spin1/Spin2/Spin3
(If you keep hold the Right Mouse Button,You won't stop!)";
	TrueLevi=false;
	TrueLeviTooltip="Levi Mode
Spin no CD
Automatically lock the back of the Titan's neck
The Beast Titan can't hurt you
(Caution:After this mode is enabled, the Master Client player needs to remain alive 
And the default skill is Spin1. Otherwise, the Titans would not appear)";
	_TrueLeviNum=null;
	TrueLeviDamage=1000;
	TrueLeviDamageTooltip="When the Levi mode is enabled, the player's ATK";
        attackTitanScoremin= 1000;
	attackTitanScoreminTooltip="The minimum kill score to be targeted by all the titans
(Caution:When the Levi mode is enabled, this setting is invalid)";

	TheBeastTitanType = "Pitcher";
	TheBeastTitanTypeTooltip= "Beast Titan Type
1.Pitcher: Long-range attack, low health.
2.Warrior: It has both melee and long-range capabilities, high health.
3.Assassin: It mainly uses close combat as its attack method, low health. ";
    	TheBeastTitanTypeDropbox = "Pitcher, Warrior, Assassin";

 	EndTime=300.0;
	EndTimeTooltip="Limited Time Until Beast titan appeared
(Caution:When the Levi mode is enabled, this setting is invalid)";
	TitanStronger=false;
	TitanStrongerTooltip = "Make the Titans stronger";
	TitanStrongerLine=false;
	TitanStrongerLineTooltip = "Whether to highlight the stronger titans
(Caution:When the Levi mode is enabled, this setting is invalid)";
	LastChance=false;
	LastChanceTooltip = "Without supplies, cross the Rubicon River!";
	RedLine=true;
	RedLineTooltip = "Whether to highlight the players";
	/*
	BasicMusic=true;
	BasicMusicTooltip = "是否开启游戏自带bgm(默认开启)";
	SpecialMusic=false;
	SpecialMusicTooltip = "是否开启进击的巨人原版bgm(默认关闭)";
	*/
	/*
	BGM = "砍猴混剪BGM";
	BGMDropbox = "砍猴混剪BGM, Battle, 无";
	*/

	BgmSet = "BGM1-BGM2";
	BgmSetDropbox = "BGM1-BGM2, BGM3-BGM4, BGM5-BGM6, Battle, None";
	_Bgm2=true;

	PlayerTitanHealth=500;
	PlayerTitanHealthTooltip = "The Health of the PT";

	_type=null;
	_type2=null;

	
	/*
 	attackTitanScoremax= 3000;
 	attackTitanScoremaxTooltip = "巨人攻击的分数最大值";
	*/ 	/*被盯上的人类id*/
	targetId = null;
       /*人物数据*/
	allPlayersData = Dict();
	_playerData = List();
	_LastTime=null;
	_TheBeastTitanSpeed = null;
	_ThrowSpeed=null;
	_ActionCoolDown=null;
	_roartitan4=null;
	_zeketime=null;
	

	/*计时*/	
	_time=0;
	_bbb=true;

	/*剧情类开关*/
	_a=true;
	_b=true;
	_c=true;
	_d=true;
	_e=true;

	/*生成巨人开关*/
	_titanboom=true;

	/*猴子投石开关*/
	_rockboom=false;

	/*游戏开始时运行的逻辑*/
	function OnGameStart()
	{
	Game.Print("




-- - Kill your companions,Stop Zeke -- -





");

	 self.PrintStartMessages();

        UI.CreatePopup("GameGuide", "游戏规则", 1000, 1000);
        self.SetGameGuideContent();

	if(Main.BgmSet=="None")
	{
	Game.SetPlaylist("None");
	}
	if(Main.BgmSet=="Battle")
	{
	Game.SetPlaylist("Battle");
	}

	if(Main.LastChance==true)
	{
		mapsx1 = Map.FindMapObjectsByName("补给");
		for(i in Range(0, mapsx1.Count, 1))
		{
            	mapsx1.Get(i).Position = Vector3( -46, -9978,  464);
		}
	}

	if(Main.BgmSet=="BGM1-BGM2")
	{
	Game.SetPlaylist("None");
	BGM=Map.FindMapObjectByName("1");
        BGM.Active = true;
	}

	if(Main.BgmSet=="BGM3-BGM4")
	{
	Game.SetPlaylist("None");
	/*
	BGM=Map.FindMapObjectByName("2");
        BGM.Active = true;
	*/
	}
	

	
	if(Main.BgmSet=="BGM5-BGM6")
	{
	Game.SetPlaylist("None");
	BGM=Map.FindMapObjectByName("3");
        BGM.Active = true;
	}


	self._spawenTitansdelay1 = SpawenTitansdelay1();
	self._spawenTitansdelay2 = SpawenTitansdelay2();
	self._spawenTitansdelay3 = SpawenTitansdelay3();
	self._spawenTitansdelay4 = SpawenTitansdelay4();
	self._spawenTitansdelay5 = SpawenTitansdelay5();

        
		

                Main._time=0;
		Main._bbb=true;
		
		/*
		
		if(Network.IsMasterClient)
                {
			
			Game.SpawnTitans("Abnormal",Main._AbnormalTitanNum);
			Game.SpawnTitans("Junper",Main.JunperTitanNum);
			Game.SpawnTitans("Crawler",Main.CrawlerTitanNum);
			Game.SpawnTitans("Punk",Main.PunkTitanNum);
			Game.SpawnTitans("Thrower",Main.ThrowerTitanNum);
		}
		*/
	}

    function PrintStartMessages()
    {
		if(Main.TheBeastTitanType == "Pitcher")
		{
			Main._type="Pitcher
Using throwing as the main attack method, it has a relatively slow movement speed and the least health.";
		}
		if(Main.TheBeastTitanType == "Warrior")
		{
			Main._type="Warrior
It has both melee and long-range capabilities, with a relatively fast movement speed and the highest health points.";
		}
		if(Main.TheBeastTitanType == "Assassin")
		{
			Main._type="Assassin
It mainly uses close combat as its attack method, has extremely fast movement speed and relatively low health points.";
		}
		if(Main.TitanStronger == true&&Main.LastChance==false)
		{
		Main._type2="
<color=#FF0000>The companions has transformed into an even more powerful titans!!</color>";
		}
		if(Main.TitanStronger == false&&Main.LastChance==false&&Main.TrueLevi==false)
		{
		Main._type2="None";
		}
		if(Main.LastChance==true&&Main.TitanStronger == false)
		{
		Main._type2="
<color=#FF0000>Without supplies, cross the Rubicon River!</color>";
		}
		if(Main.LastChance==true&&Main.TitanStronger ==true)
		{
		Main._type2="<color=#FF0000>
The companions has transformed into an even more powerful titans!!
Without supplies, cross the Rubicon River!</color>";
		}
				



        text = UI.WrapStyleTag("|>  How to play ", "color", "orange");
        text += String.Newline;
        text += UI.WrapStyleTag("|>  F1:", "color", "orange") + " Check out the Rules";
	text += String.Newline;
        text += UI.WrapStyleTag("|>  Beast Titan Type: ", "color", "orange") + Main._type;
        text += String.Newline;
	text += UI.WrapStyleTag("|>  Special Events: ", "color", "orange")+ Main._type2;
        text += String.Newline;

	if(Main.TrueLevi==true)
	{
	text += UI.WrapStyleTag("Levi Mode-ON", "color", "red");
        text += String.Newline;
	}
        UI.SetLabel("TopLeft",text);
    }

    function SetGameGuideContent()
    {
	monkey1Text = UI.WrapStyleTag("BEAST TITAN", "size", "35");
	monkeyText = UI.WrapStyleTag("BEAST TITAN", "color", "brown");
	MaoText = UI.WrapStyleTag("OrangeCat橘猫", "color", "orange");
	/*CatText = UI.WrapStyleTag("<#FF6800>橘猫</color>");*/
        text = "Welcome to " + MaoText + "'s " + monkeyText + " map!";
        text += String.Newline;
        text += "Here's what to look out for when you first play:";
        text += String.Newline;
        text += String.Newline;
        headerText = UI.WrapStyleTag("How To Play", "color", "orange");     
        text += headerText;
        text += String.Newline;
        text += "Kill the titans within the time limit, and when there are no more than 5 titans left, " + monkeyText + " will appear.";
        text += String.Newline;
        text += "Then, the game end condition is: " + monkeyText + " dies, or all players die.";
	text += String.Newline;
        text += String.Newline;

        headerText = UI.WrapStyleTag("Recommend", "color", "orange");
        text += headerText;
        text += String.Newline;
	text += "Skill-Spin1";
	text += String.Newline;
	text += "Weapon-Only Blade or Thunderspear";
        text += String.Newline;
        text += "Difficulty-Abnormal";
	text += String.Newline;
        text += "Endless Respawn-off";
        text += String.Newline;
        text += "Spawn invincible time-15s";
	text += String.Newline;
        text += String.Newline;
        text += String.Newline;

        headerText = UI.WrapStyleTag("Description of the Map", "color", "orange");
        text += headerText;
        text += String.Newline;
        text += "The attack speed and movement speed of PT are extremely fast, and it has unlimited stamina
When you use the Thunderspear, you will be able to obtain more gas
Ban AHSS/APG
Ban Dance/Eren/Annie skill,Limited supply and limited battle time
Some building/supply sites can be destroyed
Players who score more than a certain number of kill points will become the target of all titans within 20 seconds
When Levi Mode is OFF, the player's health points are fixed at 100, and they are not immune to the attacks of the Beast Titan";
        text += String.Newline;
        text += String.Newline;

        headerText = UI.WrapStyleTag("Mode setting", "color", "orange");
        text += headerText;
        text += String.Newline;
        text += "1.The number of various titans";
        text += String.Newline;
        text += "2.Number of blades/Thunderspear bullets";
        text += String.Newline;
        text += "3.Gas quantity";
        text += String.Newline;
        text += "4.Whether ThrowBlade is allowed";
	text += String.Newline;
        text += "5.Set the skills of all players using blades to spin1";
        text += String.Newline;
        text += "6.Spin1/Spin2/Spin3 skill no CD";
        text += String.Newline;
        text += "7.Whether to strengthen Spin1/Spin2/Spin3";
        text += String.Newline;
	text += "8.Levi Mode: Spin no CD
Automatically lock the back of the Titan's neck
The Beast Titan can't hurt you";
        text += String.Newline;
        text += "9.The minimum kill score to be targeted by all the titans";
	text += String.Newline;
	text += "10.Limited Time(Until Beast titan appeared)";
	text += String.Newline;
        text += "11.Beast titan Type:Pitcher/Warrior/Assassin";
	text += String.Newline;
	text += "12.Make the Titans stronger";
	text += String.Newline;
	text += "13.Whether to highlight the stronger titans";
	text += String.Newline;
	text += "14.Without supplies, cross the Rubicon River";
	text += String.Newline;
	text += "15.Whether to highlight the players";
	text += String.Newline;
	text += "16.Game Music";
	text += String.Newline;
	text += "17.The Health of the PT";
	text += String.Newline;
        text += String.Newline;

        headerText = UI.WrapStyleTag("STAFF", "color", "orange");
	yyText = UI.WrapStyleTag("天格 绅士君", "color", "blue");
        xxText = UI.WrapStyleTag("Callis", "color", "cyan");
        hyText = UI.WrapStyleTag("Hongyao", "color", "fuchsia");
        kunText = UI.WrapStyleTag("君", "color", "green");
	LeviText = UI.WrapStyleTag("Levi", "color", "yellow");
        hikariText = UI.WrapStyleTag("Hikari", "color", "red");
	RingText = UI.WrapStyleTag("Ring", "color", "brown");

        text += headerText;
	text += String.Newline;
	text += yyText+"  Beast titan model";
        text += String.Newline;
        text += xxText + "  Beast titan animation";
        text += String.Newline;
        text += hyText + "  Beast titan logic";
        text += String.Newline;
        text += kunText + " and "+LeviText+ "  Custom logic consultant";
        text += String.Newline;
        text += hikariText + "  Optimizer&Translator";
	 text += String.Newline;
        text += RingText + "  Levi Mode logic";
        text += String.Newline;
        text += String.Newline;
        text += String.Newline;
        headerText = UI.WrapStyleTag("About the Tea party", "color", "fuchsia");
        joinText = UI.WrapStyleTag("Contact information", "color", "Cyan");
        text += headerText;
        text += String.Newline;
        text += "茶话会TeaParty, is a technical guild from China.";
        text += String.Newline;
        text += "we will discuss about Custom Logic, ASO, Racing and other AOTTG game content.";
        text += String.Newline;
        text += "we've been working on creating or optimizing some Custom contents recently.";
        text += String.Newline;
        text += "We are responsible for making some minor changes and translations to them";
        text += String.Newline;
        text += "so that excellent custom maps from China can also appear here!";
        text += String.Newline;
        text += String.Newline;
        text += joinText;
        text += String.Newline;
        text += "QQ group: 662494094";
        text += String.Newline;
        text += "Discord: 茶话会TeaParty (https://discord.gg/RdhPSUAMSt)";
        text += String.Newline;
        text += String.Newline;

        UI.AddPopupLabel("GameGuide",text);
    }

		/*如果收到了房主发的指令*/
	function OnNetworkMessage(oo,rr)
	{
            	if(rr=="Bgm")
		{ 

			Main.corBgm();
              	}

		if(rr=="aaa")
		{ 

			Main.corA();
              	}

		if(rr=="bbb")
		{ 
			Main.corB();
		}

	    	if(rr=="ccc")
		{ 
			Main.corC();
		}

		if(rr=="ddd")
		{ 
			Main.corD();
		}

		if(rr=="eee")
		{ 
			Main.corE();
		}
		if(rr=="fff")
		{ 
			Main.corF();
		}
		if(rr=="ggg")
		{ 
			Main.corG();
		}
		if(rr=="hhh")
		{ 
			Main.corH();
		}

	  }



	/*有对象创建时*/
	function OnCharacterSpawn(hel)
	{
		
		/*如果时人类*/
		if(hel.Type=="Human")
		{
			if(Main.TrueLevi==true)
			{
			hel.MaxHealth=2500;
			hel.Health=2500;
			hel.CustomDamageEnabled = true;
			hel.CustomDamage = Main.TrueLeviDamage;
			Main.attackTitanScoremin=2*Main.TrueLeviDamage;
			hel.SetWeapon("Blade");
			/*Network.MyPlayer.Character.SetSpecial("Spin1");*/
			}

			/*Network.MyPlayer.Character.Rotation+=Vector(0,25,0);*/
			hel.MaxBlade = Main.Bladenumber;
			hel.CurrentBlade = Main.Bladenumber;
			hel.MaxBladeDurability = 150;
			hel.CurrentBladeDurability= 150;
			hel.MaxGas=Main.Gass;
			hel.CurrentGas=Main.Gass;
			if(Main.RedLine==true)
			{
			hel.AddOutline(Color(60,0,0), "OutlineVisible");
			}
			hel.MaxHealth=100;
			hel.Health=100;
			
			

			if(hel.Weapon=="AHSS")
			{
			Network.MyPlayer.Character.SetWeapon("Blade");
			hel.MaxBladeDurability = 80;
			hel.CurrentBladeDurability= 80;
			hel.MaxGas=Main.Gass;
			hel.CurrentGas=Main.Gass;
			hel.MaxBlade = Main.Bladenumber;
			hel.CurrentBlade = Main.Bladenumber;
			hel.SetSpecial("Spin1");
			}

			if(hel.Weapon=="APG")
			{
			Network.MyPlayer.Character.SetWeapon("Thunderspear");
			hel.MaxAmmoTotal = Main.Thunderspearnumber;
			hel.CurrentAmmoLeft = Main.Thunderspearnumber;
			hel.MaxGas=Main.Gass/0.2;
			hel.CurrentGas=Main.Gass/0.2;
			hel.SetSpecial("Switchback");
			}

			if(hel.Weapon=="Thunderspear")
			{
			hel.MaxAmmoTotal = Main.Thunderspearnumber;
			hel.CurrentAmmoLeft = Main.Thunderspearnumber;
			hel.MaxGas=Main.Gass/0.2;
			hel.CurrentGas=Main.Gass/0.2;
			}

			
			
			if(Main.NoThrowBlade==true&&hel.CurrentSpecial=="BladeThrow"&&hel.Weapon=="Blade")
			{
				hel.SetSpecial("Spin1");	
			}
			
			if(hel.Weapon=="Blade"&&Main.JustSpin1==true)
			{
			hel.SetSpecial("Spin1");	
			}
			
			if(hel.CurrentSpecial=="Dance")
			{
				hel.SetSpecial("Spin1");
			}

			if(hel.CurrentSpecial=="Annie")
			{
				hel.SetSpecial("None");
			}

			if(hel.CurrentSpecial=="Eren")
			{
				hel.SetSpecial("None");
			}

		if(Main.Spin123NoCD==true)
		{
			if(hel.CurrentSpecial=="Spin3")
			{
			
				hel.SpecialCooldown=0.0;
			}
			
			if(hel.CurrentSpecial=="Spin1")
			{
			
				hel.SpecialCooldown=0.0;
			}

			if(hel.CurrentSpecial=="Spin2")
			{
			
				hel.SpecialCooldown=0.0;
			}
		}
			/*
			if(Main.TrueLevi==true&&Network.IsMasterClient)
			{
			Network.MyPlayer.Character.SetWeapon("Blade");
			Network.MyPlayer.Character.SetSpecial("Spin1");
			Network.MyPlayer.Character.MaxBlade = Main.Bladenumber;
			Network.MyPlayer.Character.CurrentBlade = Main.Bladenumber;
			Network.MyPlayer.Character.MaxBladeDurability = 150;
			Network.MyPlayer.Character.CurrentBladeDurability= 150;
			Network.MyPlayer.Character.MaxGas=Main.Gass;
			Network.MyPlayer.Character.CurrentGas=Main.Gass;
			}
			*/
		}	

			

		
		if(hel.Type=="Titan")
		{
			
			if(Main.TitanStronger==true)
			{
				if(Main.TitanStrongerLine==true)
				{
				hel.AddOutline(Color(150,60,0), "OutlineVisible");
				}
			hel.MaxStamina=9999999;
			hel.Stamina=9999999;
			hel.AttackWait=0.0;
			hel.RunSpeedBase=40;
			hel.TurnPause=0.5;
			hel.TurnSpeed=5;
			hel.AttackPause=0.1;
			hel.ActionPause=0.1;
			hel.AttackSpeedMultiplier=1.8;
			}
		self._spawenTitansdelay1.IdleRaor(hel);
		self._spawenTitansdelay2.IdleRaor(hel);
		self._spawenTitansdelay3.IdleRaor(hel);
		self._spawenTitansdelay4.IdleRaor(hel);
		self._spawenTitansdelay5.IdleRaor(hel);

		hel.DetectRange=9999;

			for(i in Range(0, Game.AITitans.Count, 1))
	 		{
			Game.AITitans.Get(i).Emote("Roar");
			}

			for(i in Range(0, Game.PlayerTitans.Count, 1))
	 		{
			Game.PlayerTitans.Get(i).MaxHealth=Main.PlayerTitanHealth;
			Game.PlayerTitans.Get(i).Health=Main.PlayerTitanHealth;
			Game.PlayerTitans.Get(i).MaxStamina=9999999;
			Game.PlayerTitans.Get(i).Stamina=9999999;
			Game.PlayerTitans.Get(i).AttackWait=0.0;
			Game.PlayerTitans.Get(i).RunSpeedBase=40;
			Game.PlayerTitans.Get(i).TurnPause=0.5;
			Game.PlayerTitans.Get(i).TurnSpeed=5;
			Game.PlayerTitans.Get(i).AttackPause=0.1;
			Game.PlayerTitans.Get(i).ActionPause=0.1;
			Game.PlayerTitans.Get(i).AttackSpeedMultiplier=1.8;
			}

			
		}
	}

	/*游戏循环执行的逻辑*/
	function OnTick()
	{
		
		if(Main.Spin123Plus==true&&Network.MyPlayer.Status == "Alive"&&Network.MyPlayer.CharacterType == "Human"&& Network.MyPlayer.Character.CurrentSpecial=="Spin1"&&Network.MyPlayer.Character != null&&Input.GetKeyHold("Human/AttackSpecial"))
		{
							
							Spin111=null;
							Spin111=Network.MyPlayer.Character;
							Spin111.ActivateSpecial(9999);	
		}
		
		if(Main.Spin123Plus==true&&Network.MyPlayer.Status == "Alive"&&Network.MyPlayer.CharacterType == "Human"&& Network.MyPlayer.Character.CurrentSpecial=="Spin2"&&Network.MyPlayer.Character != null&&Input.GetKeyHold("Human/AttackSpecial"))
		{
							
							Spin222=null;
							Spin222=Network.MyPlayer.Character;
							Spin222.ActivateSpecial(9999);	
		}
		
		if(Network.MyPlayer.Status == "Alive"&&Network.MyPlayer.CharacterType == "Human"&& Network.MyPlayer.Character.CurrentSpecial=="Spin3"&&Network.MyPlayer.Character != null&&Input.GetKeyHold("Human/AttackSpecial"))
		{
							
							Spin333=null;
							Spin333=Network.MyPlayer.Character;
							Spin333.ActivateSpecial(9999);	
		}

	if(Main.TrueLevi==true)
	{	

		  player = Network.MyPlayer;
        if (player == null || player.Status != "Alive")
            {return;}

        character = player.Character;
        if (character.Type != "Human" || character.Weapon != "Blade")
            {return;}
     
        if (/* character.CurrentSpecial == "Spin1" && */
            character.State == "SpecialAttack" && String.StartsWith(character.CurrentSpecial, "Spin")
            /* Time.time - _lastSpinTime > 1.0 */)  
        {
            character.SpecialCooldown = 0.0;
            targetTitan = self.FindNearestTitan(character.Position);
            if (targetTitan != null)
            {
                self.TeleportToNape(character, targetTitan);
                /* _lastSpinTime = Time.time; */
            }
        }
        /* 长按持续触发 */
        keyHold = Input.GetKeyHold("Human/AttackSpecial");   
        if (keyHold && String.StartsWith(character.CurrentSpecial, "Spin") && 
            character.State != "SpecialAttack")
        {
            character.ActivateSpecial();
        }
        #更新最近的巨人
        self.FindNearestTitan(character.Position);

	}

		/*
		if (Network.IsMasterClient)
		{
			for(i in Range(0, Game.Humans.Count, 1))
	 		{
	 		Game.Humans.Get(i).ActivateSpecial(99999);
			}
		}
		*/

		if(Main.Spin123Plus==true&&Network.MyPlayer.CharacterType == "Human"&& Network.MyPlayer.Status == "Alive"&&
Network.MyPlayer.Character.CurrentSpecial=="Spin1"&&Network.MyPlayer.Character.State=="SpecialAttack"&& Network.MyPlayer.Character != null)
		{
			Network.MyPlayer.Character.Rotation+=Vector3(0,250,0);		
		}
		
		/*
		#spin2当spin1用
		if(Network.MyPlayer.CharacterType == "Human"&&Network.MyPlayer.Status == "Alive"&& Network.MyPlayer.Character.CurrentSpecial=="Spin2"&&Network.MyPlayer.Character.State=="SpecialAttack"&& Network.MyPlayer.Character != null)
		{
			Network.MyPlayer.Character.Rotation+=Vector3(0,0,-15);
		}
		*/

		if(Main.Spin123Plus==true&&Network.MyPlayer.CharacterType == "Human"&&Network.MyPlayer.Status == "Alive"&& Network.MyPlayer.Character.CurrentSpecial=="Spin2"&&Network.MyPlayer.Character.State=="SpecialAttack"&& Network.MyPlayer.Character != null)
		{
			Network.MyPlayer.Character.Rotation+=Vector3(0,250,0);
		}

		if(Main.Spin123Plus==true&&Network.MyPlayer.CharacterType == "Human"&& Network.MyPlayer.Status == "Alive"&&
Network.MyPlayer.Character.CurrentSpecial=="Spin3"&&Network.MyPlayer.Character.State=="SpecialAttack"&& Network.MyPlayer.Character != null)
		{
			Network.MyPlayer.Character.Rotation+=Vector3(0,250,0);		
		}

		if(Main._bbb==true&&Network.IsMasterClient)
		{
		
		Main._time+=Time.TickTime;
		Main._LastTime=Main.EndTime-Main._time+4;

		/*UI.SetLabelForTimeAll("TopCenter",Game.Titans.Count+"头奇形种曾是同伴,请杀死他们"+",否则吉克将逃出森林  剩余时间:"+Main._time+"秒",100000000.0);*/
		}
		if(Main.TrueLevi==true&&Network.IsMasterClient)
		{
		Main._LastTime=999999990;
		}

		if(Main._titanboom)
		{
			if(Network.IsMasterClient&&Main._time>=3)
			{
			Main._titanboom=false;
			self._spawenTitansdelay1.SpTitans(self._spawenTitansdelay1._titansNum);
			self._spawenTitansdelay2.SpTitans(self._spawenTitansdelay2._titansNum);
			self._spawenTitansdelay3.SpTitans(self._spawenTitansdelay3._titansNum);
			self._spawenTitansdelay4.SpTitans(self._spawenTitansdelay4._titansNum);
			self._spawenTitansdelay5.SpTitans(self._spawenTitansdelay5._titansNum);


			/*创建各类巨人*/
			Game.SpawnTitans("Abnormal",Main._AbnormalTitanNum);
			}
		}
		monkey1Text = UI.WrapStyleTag("Beast titan", "size", "25");
		monkeyText = UI.WrapStyleTag(monkey1Text, "color", "brown");

		if(Game.Titans.Count>5&&Main.TrueLevi==true)
		{
		UI.SetLabelForTime("TopCenter",Game.Titans.Count+" titans need to be killed, or Zeke will escape the forest" ,1);
		}

		if(Game.Titans.Count<=5&&Main._rockboom==true&&Main.TrueLevi==true)
		{
		UI.SetLabelForTime("TopCenter",monkeyText+ " has appeared. Kill him!",1);
		}

		
		if(Game.Titans.Count>5&&Network.IsMasterClient&&Main.TrueLevi==false)
		{
		UI.SetLabelForTimeAll("TopCenter",Game.Titans.Count+" titans need to be killed"+", or Zeke will escape the forest | Time Left: "+Convert.ToInt(Main._LastTime)+"s",Main.EndTime);
		}
		monkey1Text = UI.WrapStyleTag("Beast titan", "size", "25");
		monkeyText = UI.WrapStyleTag(monkey1Text, "color", "brown");

		if(Game.Titans.Count<=5&&Network.IsMasterClient&&Main._rockboom==true&&Main.TrueLevi==false)
		{
		UI.SetLabelForTimeAll("TopCenter",monkeyText+ " has appeared. Kill him!",100000000.0);
		}

		if (Game.Humans.Count == 0&&Network.IsMasterClient&&Main._time>=15&&Main.TrueLevi==false)
		{
			UI.SetLabelForTimeAll("MiddleCenter","This is the gap between the ordinary soldier and Ackerman...",10.0);	
			/*Game.Print("牺牲的同伴在看着我们...");*/	   		
			Game.End(10.0);
		}
		/*
		if(Main._Bgm2)
		{
			if(Main._time>=0.5)
			{
				Main._Bgm2=false;

				if(Main.BgmSet=="BGM3-BGM4")
	{
	Game.SetPlaylist("None");
	BGM=Map.FindMapObjectByName("2");
        BGM.Active = true;
	}
			}
	
		}
		*/
		if(Network.IsMasterClient)
		{
			Network.SendMessageAll("Bgm");
		}

		if(Main._a) 
		{
			if(Game.Titans.Count>=15&&Network.IsMasterClient)
			{
			Main._a=false;
			Network.SendMessageAll("aaa");
			/*
			Game.SpawnEffect("ShifterThunder", Vector3(-20, -50, -50) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(60, -50, 220) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-125, -50, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(170, -50, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-180,  -50, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(225,  -50, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -50, -55) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -50, -200) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -50, -370) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -50, -490) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  75, -580) , Vector3(0.0, 0.0, 0.0), 3.0);
			Game.SpawnEffect("TitanSpawnEffect", Vector3(-12,  75, -580) , Vector3(0.0, 0.0, 0.0), 3.0);



			Game.SpawnEffect("ShifterThunder", Vector3(-20, -80, -50) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(60, -80, 220) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-125, -80, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(170, -80, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-180,  -80, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(225,  -80, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -80, -55) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -80, -200) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -80, -370) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -80, -490) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  75, -580) , Vector3(0.0, 0.0, 0.0), 40.0);
			
			
			Game.SpawnEffect("Boom7", Vector3(-120, -100, -50) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(60, -100, 220) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(-125, -100, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(170, -100, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(-180, -100, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(225, -100, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(-120, -100, -55) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			
			Game.SpawnEffect("Boom7", Vector3(-12, -100, -200) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 20.0);
			Game.SpawnEffect("Boom7", Vector3(-12, -100, -370) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 20.0);
			Game.SpawnEffect("Boom7", Vector3(-12, -100, -490) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 20.0);
			*/

			}
		}

		if(Main._b) 
		{
			if(Main._time>=Main.EndTime+4&&Network.IsMasterClient&&Game.Titans.Count>=6&&Main.TrueLevi==false)
			{
			Main._b=false;
			Main._d=false;
			Game.End(10.0);
			Network.SendMessageAll("eee");
			UI.SetLabelForTimeAll("MiddleCenter","There's no one left to stop Zeke...",10.0);
			/*Game.Print("你,终究不是他...");*/
			}
		}
	}

	function FindNearestTitan(position)
    {
	if(Main.TrueLevi==true)
	{
        nearest = null;
        minDist = Math.Infinity;
        for(TGtitan in Game.AITitans)
        {
            dist = Vector3.Distance(position, TGtitan.Position);
            TGtitan.RemoveOutline();
            if (dist < minDist)
            {
                minDist = dist;
                nearest = TGtitan;
            }
        }
	if(Game.Titans.Count!=0)
	{
        nearest.AddOutline(Color(255,255,255), "OutlineAll");
	}
        return nearest;
	
	}
    }

    function TeleportToNape(human, titan)
    {
	if(Main.TrueLevi==true)
	{

        message1 = "<color=#EB14FF><b>调试信息</b> 测试</color>";
        /*Game.Print(message1);*/
        /* 计算目标位置和方向*/
        napePos = titan.NapePosition - 0*titan.TargetDirection;
        /* 瞬移执行 */
        /*human.Position = napePos;  */
        /* 平移执行 */
        /*if(human.Position != napePos )
        {
            t = 5 / Vector3.Distance(human.Position, napePos);
            human.Position = Vector3.LerpUnclamped(human.Position, napePos, t);
        }*/
       /* 转向执行 */
       if(Vector3.Distance(human.Position, napePos)>5)
       {
            t = 3 / Vector3.Distance(human.Position, napePos);
            human.Position = Vector3.SlerpUnclamped(human.Position, napePos, t);
       }
       else
       {
           human.Position = napePos;
       }

	}
    }


	/*如果有对象死亡*/
	function OnCharacterDamaged(Vvv,kkk,killlna,damage)
	{
		
		if (Vvv.Type == "Titan"&&damage >=Main.attackTitanScoremin )
		{	
			titan=null;
			/*
			for(i in Range(0,Game.Titans.Count,1))
			{	
				titan=Game.Titans.Get(i);

				v3=titan.Position+kkk.Position;
				
				titan.MoveTo（kkk.Position,4,true);
			}
			*/
			kkk.AddOutline(Color(255,0,0), "OutlineVisible");	

			if(Network.IsMasterClient)
                     	{
				/*Main.corG(Vvv,kkk,killlna,damage);*/
				for(i in Range(0, Game.AITitans.Count, 1))
				{
         		 	Game.AITitans.Get(i).Target(kkk, 15);
				}
			/*Cutscene.ShowDialogueForTime("Titan14", "吉克", "哟~ "+damage+"分，这是莱纳说的那个人类士兵吗？不能让你活着" + kkk.Name+ "~
我的巨人们先干掉他！", 6.0);*/
			Network.SendMessageAll("mmm");

			UI.SetLabelForTimeAll("MiddleCenter","The titans' target: " + kkk.Name,6.0);
			}
			
			for(i in Range(0, Game.AITitans.Count, 1))
	 		{
			Game.AITitans.Get(i).Emote("Roar");
			}

		} 
		
		
		if (Vvv.Type == "Human" )
		{
			if(Main.TrueLevi==false)
			{
				Game.Print("Soldier "+Vvv.Name+" is dead.");
			}

			if (Game.Humans.Count == 0 )
			{
				
			if(Main._d)
			{
				Main._d=false;
				Main._b=false;
 				if(Network.IsMasterClient)
                     		{
				/*向着所有人发送指令*/			
				Network.SendMessageAll("ddd");
				UI.SetLabelForTimeAll("MiddleCenter","This is the gap between the ordinary soldier and Ackerman...",10.0);
		      		}	
				Game.End(10.0);

				for(i in Range(0, Game.Titans.Count, 1))
	 			{
				Game.Titans.Get(i).Emote("Laugh");
				}
			}

				
			}
		}			

		if (Vvv.Type == "Titan")
		{
			if (Game.Titans.Count==15)
			{
				if(Network.IsMasterClient)
                     		{
					/*向着所有人发送指令*/			
					Network.SendMessageAll("bbb");
					
				}
				/*
				 for (Titans in Game.AITitans)
        			{
            			Titans.Reveal(90.5);
        			}
				*/
			}
			
			if (Game.Titans.Count==5)
			{
				
				for (Titans in Game.AITitans)
        			{
            			Titans.Reveal(90.5);
        			}
				Main._rockboom=true;
			
				if(Network.IsMasterClient)
                     		{
					Main._zeketime=Time.TickTime;
					/*到两分半游戏不结束开关*/
					Main._b=false;
					/*向着所有人发送指令*/			
					Network.SendMessageAll("ccc");
					/*
					Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 3.0);
					Game.SpawnEffect("ShifterThunder", Vector3(-10, -100, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
					Game.SpawnEffect("Boom7",Vector3(-10, -95, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 4.0);
					Game.SpawnEffect("Boom2",Vector3(-10, -95, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 4.0);
					Game.SpawnEffect("Boom2",Vector3(-10, -95, -300) + Vector3.Up * 150.0, Vector3(90.0, 90.0, 0.0), 4.0);
					Game.SpawnEffect("Boom2",Vector3(-10, -95, -300) + Vector3.Up * 150.0, Vector3(45.0, 90.0, 0.0), 4.0);
					Game.SpawnEffect("Boom2",Vector3(-10, -95, -300) + Vector3.Up * 150.0, Vector3(-45.0, 90.0, 0.0), 4.0);
					Game.SpawnEffect("Boom7",Vector3(-10, -95, -300) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 4.0);
					*/
									
					mapshz1 = Map.FindMapObjectsByName("zekeshifter");
					/*mapshz1.AddOutline(Color(100,70,0), "OutlineVisible");*/
          				for(i in Range(0, mapshz1.Count, 1))
					{
            				mapshz1.Get(i).Position = Vector3( -10, 0, -300);	
					}
					
					for(i in Range(0, Game.AITitans.Count, 1))
	 				{
					Game.AITitans.Get(i).Emote("Roar");
					}
					
					
				}
			}
		}			
	}
	coroutine corBgm()
	{
	wait 0.5;
	if(Main.BgmSet=="BGM3-BGM4")
	{
	Game.SetPlaylist("None");
	BGM=Map.FindMapObjectByName("2");
        BGM.Active = true;
	}		 
	}
	
	coroutine corA()
	{
		Game.SpawnEffect("ShifterThunder", Vector3(-20, -50, -50) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(60, -50, 220) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-125, -50, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(170, -50, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-180,  -50, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(225,  -50, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -50, -55) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -50, -200) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -50, -370) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -50, -490) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 5.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  75, -580) , Vector3(0.0, 0.0, 0.0), 3.0);
			Game.SpawnEffect("TitanSpawnEffect", Vector3(-12,  75, -580) , Vector3(0.0, 0.0, 0.0), 3.0);



			Game.SpawnEffect("ShifterThunder", Vector3(-20, -80, -50) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(60, -80, 220) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-125, -80, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(170, -80, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-180,  -80, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(225,  -80, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -80, -55) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -80, -200) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -80, -370) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  -80, -490) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 40.0);
			Game.SpawnEffect("ShifterThunder", Vector3(-12,  75, -580) , Vector3(0.0, 0.0, 0.0), 40.0);
			
			
			Game.SpawnEffect("Boom7", Vector3(-120, -100, -50) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(60, -100, 220) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(-125, -100, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(170, -100, -100) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(-180, -100, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(225, -100, 140) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			Game.SpawnEffect("Boom7", Vector3(-120, -100, -55) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 30.0);
			/*
			Game.SpawnEffect("Boom7", Vector3(-12, -100, -200) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 20.0);
			Game.SpawnEffect("Boom7", Vector3(-12, -100, -370) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 20.0);
			Game.SpawnEffect("Boom7", Vector3(-12, -100, -490) + Vector3.Up * 150.0, Vector3(0.0, 0.0, 0.0), 20.0);
			*/

		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "YEAAAAAAAAAAGH!!!",5.0);
		 wait 5.5;
		Cutscene.ShowDialogueForTime("Levi1", "Levi Ackerman", "No...",5.0);
		wait 5.5;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "Farewell, Levi... Your soldiers haven't done anything wrong. They've just grown a little bigger.",5.0);
		wait 5.5;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "You wouldn't say,slice them to pieces over that,would you?",5.0);
		wait 5.5;
		Cutscene.ShowDialogueForTime("Levi1", "Levi Ackerman", "Zeke's spinal fluid was in the wine...?!
When'd he start tainting it...? There was no sign of it. 
No one froze up...Or was that a lie?",5.0);
		wait 5.5;
		Cutscene.ShowDialogueForTime("Levi1", "Levi Ackerman", "Damn it! They're fast...Is that Zeke's doing,too?!
VARIS..!! Are you still...in there? All of you...",5.0);
		wait 5.5;
	}

	coroutine corB()
	{
	     	 wait 1.0;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "What a pity...
We never did learn to trust one another.",5.0);
		 wait 5.5;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "The entire world's forces are about to gather here on this island.
You have no idea...what that means.",5.0);
		wait 5.5;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "You thought you had Strength,Time,Choices. 
It was those foolish beliefs...",5.0);
		wait 5.5;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "Well. It's not as if you could ever understand. 
Even if I'd shared my true intentions...with all of you.",5.0);
		wait 5.5;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "Eren,Once I'm out of this forest,
I'll be by your side in no time!",5.0);
	}

	coroutine corC()
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
					
					

	monkey1Text = UI.WrapStyleTag("BEAST TITAN", "size", "25");
	monkeyText = UI.WrapStyleTag(monkey1Text, "color", "brown");
	UI.SetLabelForTimeAll("MiddleCenter",monkeyText+"<color=#FF0000> arrived on the battlefield!!</color>
You can hide behind trees in case you get hit by rocks!",10.0);        
	Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "MMMMGH!! GOOOOOOO!!",5.0);	
	wait 5.5;
	Cutscene.ShowDialogueForTime("Titan14", "Zeke Jager", "Where'd you go? LEVI!!!
Where'd your adorable little men go?! Don't tell me you killed them all!
The poor things!", 5.0);
	wait 5.5;
	Cutscene.ShowDialogueForTime("Titan14", "Zeke Jager", " What?! Branches...?!", 5.0);
	wait 5.5;
	Cutscene.ShowDialogueForTime("Levi1", "Levi Ackerman", "You're desperate,you bearded bastard.
All you had to do was sit back and read. Whatever made you believe...
...That you could get away from me...?",5.0);
        wait 5.5;
	Cutscene.ShowDialogueForTime("Levi1", "Levi Ackerman", "Did you really think I wouldn't be able to kill my comrades?
Just because you turned them into the titans...?",5.0);
        wait 5.5;
	Cutscene.ShowDialogueForTime("Levi1", "Levi Ackerman", "I guess you wouldn't know...
Just how many friends We've had to Kill-!!!",5.0);
	}

	/*人类死完剧情*/
	coroutine corD()
	{
		Game.Print("The sacrificed companions stared at us deeply...");
	     	 wait 1.0;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "This is goodbye,Levi.",4.0);
		 wait 4.5;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "Eren,I'll be there for you soon!",4.0);
		wait 4.5;
	}

	/*超时剧情*/
	coroutine corE()
	{
		Game.Print("You can never be him after all...");
	     	 wait 1.0;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "It seems that guy can't catch up with me.
Bury yourself here,Levi.",4.0);
		 wait 4.5;
		Cutscene.ShowDialogueForTime("Zeke1", "Zeke Jager", "The great cause of Eren and me... No one can stop it!",4.0);
		wait 4.5;
	}

	/*吉克被杀剧情*/
	coroutine corF()
	{
		Game.Print("何も捨てることができない人には、何も変えることはできない...");
	     	 wait 1.0;
		Cutscene.ShowDialogueForTime("Zeke2", "Zeke Jager", "NOOOOOOOOOOOOOOOO!!!!",4.0);
		 wait 4.5;
		Cutscene.ShowDialogueForTime("Levi1", "Levi Ackerman", "Hey,Beardy. Look at you...
you reeking,filthy,ugly piece of shit. Well...Don't worry. I won't kill you.
NOT YET.",5.0);
		wait 4.5;
	}

}

class SpawenTitansdelay1{
  _zekeshifterPosition = Vector3(-20, 110, 60);
  _position1 = Vector3();
  _position2 = Vector3();
  _distance = 50;
  _isRoar = false;
  _titansNum = 10;

  function Init(){
    self._position1 = self._zekeshifterPosition;
    self._position2 = self._zekeshifterPosition;
  }

  coroutine SpTitans(num){
	/*num=0;*/
	num=Main._AbnormalTitanNum;
    for(i in Range(0, Math.Floor(num / 2), 1)){
      self._position1.X = self._position1.X + self._distance;
      self._position2.X = self._position2.X - self._distance;
      SpawnEffectPositon1 = self._position1;
      SpawnEffectPositon1.Y = -50;
      SpawnEffectPositon2 = self._position2;
      SpawnEffectPositon2.Y = -50;
      Game.SpawnTitanAt("Abnormal", self._position1);
	  Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon1 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      Game.SpawnTitanAt("Abnormal", self._position2);
	Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon2 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      wait 0.25;
    }
  }

  function IdleRaor(titan)
{
	if(Main._time>=2&&Network.IsMasterClient)
	{
    	titan.Emote("Roar");
	/*titan.PlaySound("Roar");*/
    	titan.Idle(5.0);
	}
  }
}

class SpawenTitansdelay2{
  _zekeshifterPosition = Vector3(-20, 110, 220);
  _position1 = Vector3();
  _position2 = Vector3();
  _distance = 50;
  _isRoar = false;
  _titansNum = 10;

  function Init(){
    self._position1 = self._zekeshifterPosition;
    self._position2 = self._zekeshifterPosition;
  }

  coroutine SpTitans(num){
	num=Main.JumperTitanNum;
    for(i in Range(0, Math.Floor(num / 2), 1)){
      self._position1.X = self._position1.X + self._distance;
      self._position2.X = self._position2.X - self._distance;
      SpawnEffectPositon1 = self._position1;
      SpawnEffectPositon1.Y = -50;
      SpawnEffectPositon2 = self._position2;
      SpawnEffectPositon2.Y = -50;
      Game.SpawnTitanAt("Jumper", self._position1);
	  Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon1 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      Game.SpawnTitanAt("Jumper", self._position2);
	Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon2 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      wait 0.3;
    }
  }

  function IdleRaor(titan)
{
	if(Main._time>=3&&Network.IsMasterClient)
	{
    	titan.Emote("Roar");
	/*titan.PlaySound("Roar");*/
    	titan.Idle(5.0);
	}
  }
}

class SpawenTitansdelay3{
  _zekeshifterPosition = Vector3(-20, 110, -75);
  _position1 = Vector3();
  _position2 = Vector3();
  _distance = 50;
  _isRoar = false;
  _titansNum = 10;

  function Init(){
    self._position1 = self._zekeshifterPosition;
    self._position2 = self._zekeshifterPosition;
  }

  coroutine SpTitans(num){
	num=Main.CrawlerTitanNum;
    for(i in Range(0, Math.Floor(num / 2), 1)){
      self._position1.X = self._position1.X + self._distance;
      self._position2.X = self._position2.X - self._distance;
      SpawnEffectPositon1 = self._position1;
      SpawnEffectPositon1.Y = -50;
      SpawnEffectPositon2 = self._position2;
      SpawnEffectPositon2.Y = -50;
      Game.SpawnTitanAt("Crawler", self._position1);
	  Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon1 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      Game.SpawnTitanAt("Jumper", self._position2);
	Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon2 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      wait 0.35;
    }
  }

  function IdleRaor(titan)
{
	if(Main._time>=3&&Network.IsMasterClient)
	{
    	titan.Emote("Roar");
	/*titan.PlaySound("Roar");*/
    	titan.Idle(5.0);
	}
  }
}

class SpawenTitansdelay4{
  _zekeshifterPosition = Vector3(-20, 110, -205);
  _position1 = Vector3();
  _position2 = Vector3();
  _distance = 50;
  _isRoar = false;
  _titansNum = 10;

  function Init(){
    self._position1 = self._zekeshifterPosition;
    self._position2 = self._zekeshifterPosition;
  }

  coroutine SpTitans(num){
	num=Main.ThrowerTitanNum;
    for(i in Range(0, Math.Floor(num / 2), 1)){
      self._position1.X = self._position1.X + self._distance;
      self._position2.X = self._position2.X - self._distance;
      SpawnEffectPositon1 = self._position1;
      SpawnEffectPositon1.Y = -50;
      SpawnEffectPositon2 = self._position2;
      SpawnEffectPositon2.Y = -50;
      Game.SpawnTitanAt("Thrower", self._position1);
	  Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon1 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      Game.SpawnTitanAt("Thrower", self._position2);
	Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon2 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      wait 0.4;
    }
  }

  function IdleRaor(titan)
{
	if(Main._time>=3&&Network.IsMasterClient)
	{
    	titan.Emote("Roar");
	/*titan.PlaySound("Roar");*/
    	titan.Idle(5.0);
	}
  }
}

class SpawenTitansdelay5{
  _zekeshifterPosition = Vector3(-12, 110, -440);
  _position1 = Vector3();
  _position2 = Vector3();
  _distance = 25;
  _isRoar = false;
  _titansNum = 10;

  function Init(){
    self._position1 = self._zekeshifterPosition;
    self._position2 = self._zekeshifterPosition;
  }

  coroutine SpTitans(num){
	num=Main.PunkTitanNum;
    for(i in Range(0, Math.Floor(num / 2), 1)){
      self._position1.X = self._position1.X + self._distance;
      self._position2.X = self._position2.X - self._distance;
      SpawnEffectPositon1 = self._position1;
      SpawnEffectPositon1.Y = -50;
      SpawnEffectPositon2 = self._position2;
      SpawnEffectPositon2.Y = -50;
      Game.SpawnTitanAt("Punk", self._position1,180);
	  Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	Game.SpawnEffect("ShifterThunder", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 4.0);

	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon1 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon1 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      Game.SpawnTitanAt("Punk", self._position2,180);
	Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 1.0);
      Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 3.0);
	 Game.SpawnEffect("ShifterThunder", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 4.0);
	Game.SpawnEffect("TitanSpawnEffect", SpawnEffectPositon2 + Vector3.Up * 120.0+Vector3(0.0, 20.0, -15.0), Vector3(0.0, 0.0, 0.0), 2.0);
      Game.SpawnEffect("Boom7",SpawnEffectPositon2 + Vector3.Up * 150.0, Vector3(0.0, 20.0, 0.0), 4.0);
      wait 0.45;
    }
  }

  function IdleRaor(titan)
{
	if(Main._time>=3&&Network.IsMasterClient)
	{
    	titan.Emote("Roar");
	/*titan.PlaySound("Roar");*/
    	titan.Idle(5.0);
	}
  }
}


extension ZekeAnimation
{
    Idle = "Amarture_VER2|idle";
    TurnLeft = "Amarture_VER2|turnaround.L";
    TurnRight = "Amarture_VER2|turnaround.R";
    Move = "Amarture_VER2|run.walk";
    Attack = "Amarture_VER2|attack.comboPunch";
    Die = "Amarture_VER2|die.front";
    Throw = "Amarture_VER2|attack.throw";
	Die3= "Amarture_VER2|crawler.die";
}

component ZekeShifter
{
    Target = null;
    RotateSpeed = 5;
    Health = 1000;
    _actionCoolDown = 0.0;
    _rigidbody = null;
    _shifter = null;
    
    _attackCoolDown = 0.0;
    _turnDirection = null;

    _rock = null;
    _throwCoolDown = 0.0;
    _rockThrownCoolDown = 0.0;
    _bombHitBox = null;

    VisableBox = "0";

    function Init()
    {
	if(Main.TrueLevi==false)
	{
		Main._TrueLeviNum=1000;
	}

	if(Main.TrueLevi==true)
	{
		Main._TrueLeviNum=0;
	}
        self._shifter = self.MapObject.Transform;
        self._rigidbody = self.MapObject.GetComponent("Rigidbody");

	if(Main.TheBeastTitanType == "Pitcher")
	{
	ZekeAnimation.Move="Amarture_VER2|run.walk";
	Main._TheBeastTitanSpeed =20;
	Main._ThrowSpeed=4;
	self.Health = 2000;
	Main._ActionCoolDown=2;
	/*Game.Print("兽巨类型:Pitcher");*/
	}

	if(Main.TheBeastTitanType == "Warrior")
	{
	ZekeAnimation.Move="Amarture_VER2|run.abnormal.1";
	Main._TheBeastTitanSpeed =100;
	Main._ThrowSpeed=6;
	self.Health = 3000;
	Main._ActionCoolDown=1.5;
	/*Game.Print("兽巨类型:Warrior");*/
	}

	if(Main.TheBeastTitanType == "Assassin")
	{
	ZekeAnimation.Move="Amarture_VER2|run.abnormal.3";
	Main._TheBeastTitanSpeed =120;
	Main._ThrowSpeed=8;
	self.Health = 2500;
	Main._ActionCoolDown=1.0;
	/*Game.Print("兽巨类型:Assassin");*/
	}


        self.AddNape();
        self.AddHitBox();
        self.AddRock();
    }

    function AddNape()
    {
        neck = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/neck");
        napeNew = Map.CreateMapObjectRaw("Scene,Geometry/Sphere1,0,0,1,0," + self.VisableBox + ",0,NapeCollider,0,0,0,0,0,0,6,3,3,Region,Hitboxes,Default,Transparent|0/255/0/111|Misc/None|1/1|0/0,ZekeNapeHurtBox");
        napeNew.Parent = neck;
        napehurtbox = napeNew.GetComponent("ZekeNapeHurtBox");
        napehurtbox.SetShifter(self);
        napeNew.LocalPosition = Vector3(0,0,-0.09);
        napeNew.LocalRotation = Vector3.Zero;
        napeNew.Forward = neck.Forward;
        #Game.Print(napeNew.LocalPosition);
        #Game.Print(napeNew.LocalRotation);
    }

    function AddHitBox()
    {
        arm = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/shoulder.L/upper_arm.L/forearm.L/hand.L");
        armNew = Map.CreateMapObjectRaw("Scene,Geometry/Cube1,0,0,1,0," + self.VisableBox + ",0,ArmCollider,0,0,0,0,0,0,12,60,12,Region,Humans,Default,Transparent|255/0/0/111|Misc/None|1/1|0/0,ZekeHitBox");
        armNew.Parent = arm;
        armNew.Forward = arm.Forward;
        armNew.LocalPosition = Vector3.Zero;
        armNew.LocalRotation = Vector3.Zero;
        armHitBox = armNew.GetComponent("ZekeHitBox");
        armHitBox.SetShifter(self);

        arm = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/shoulder.R/upper_arm.R/forearm.R/hand.R");
        armNew = Map.CreateMapObjectRaw("Scene,Geometry/Cube1,0,0,1,0," + self.VisableBox + ",0,ArmCollider,0,0,0,0,0,0,12,60,12,Region,Humans,Default,Transparent|255/0/0/111|Misc/None|1/1|0/0,ZekeHitBox");
        armNew.Parent = arm;
        armNew.Forward = arm.Forward;
        armNew.LocalPosition = Vector3.Zero;
        armNew.LocalRotation = Vector3.Zero;
        armHitBox = armNew.GetComponent("ZekeHitBox");
        armHitBox.SetShifter(self);
    }

    function AddRock()
    {
        arm = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/shoulder.R/upper_arm.R/forearm.R/hand.R");
        rock = Map.CreateMapObjectRaw("Scene,Decor/Rubble1,0,0,1,0,1,0,Rock1,0,0,0,0,0,0,1,1,1,None,Humans,Default,DefaultNoTint|255/255/255/255,");
        rock.Parent = arm;
        rock.Forward = arm.Forward;
        rock.LocalPosition = Vector3(0,0.09,0.04);
        rock.LocalRotation = Vector3.Zero;
        self._rock = rock;
        self._bombHitBox = Map.CreateMapObjectRaw("Scene,Geometry/Sphere1,0,0,1,0," + self.VisableBox + ",0,Rock1HitBox,0,0,0,0,0,0,5,5,5,Region,Characters,Default,Transparent|255/0/0/111|Misc/None|1/1|0/0,ZekeBombHitBox").GetComponent("ZekeBombHitBox").SetShifter(self);
    }


    function FindTarget()
    {
        if (self.Target != null && self.Target.Health <= 0)
        {
            self.Target = null;
        }

        # self.Target = Game.Titans.Get(0);

        if (self.Target == null&&Game.Titans.Count<=5&&Main._rockboom==true)
        {
            minDistance = 0;
            for (human in Game.Humans)
            {
                direction = human.Position - self.MapObject.Position;
                direction.Y = 0;
                distance = direction.Magnitude;
                if (self.Target == null || distance < minDistance)
                {
                    self.Target = human;
                    minDistance = distance;
                }
            }
        }
    }

    function Attack()
    {
        self.PlayAnimation(ZekeAnimation.Attack);
        self._actionCoolDown = self._shifter.GetAnimationLength(ZekeAnimation.Attack);
        self._attackCoolDown = self._actionCoolDown;
    }

    function Move()
    {
        direction = self.Target.Position - self.MapObject.Position;
        direction.Y = 0;
        direction = direction.Normalized;
        velocity = self._rigidbody.GetVelocity();
        velocity.X = 0;
        velocity.Z = 0;
        self._rigidbody.SetVelocity(direction * Main._TheBeastTitanSpeed + velocity);
    }

    function ThrowRock()
    {
        self.PlayAnimation(ZekeAnimation.Throw);
        self._actionCoolDown = self._shifter.GetAnimationLength(ZekeAnimation.Throw);
        self._rockThrownCoolDown = self._actionCoolDown - 1;
    }

    function RockBomb()
    {
        if (self.Target == null)
        {
            return;
        }
        start = self._rock.Position;
        end = self.Target.Position;
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

    function _coolDownByFrame()
    {
        if (self._actionCoolDown > 0)
        {
            self._actionCoolDown -= Time.FrameTime;
        }
        if (self._attackCoolDown > 0)
        {
            self._attackCoolDown -= Time.FrameTime;
        }
        if (self._rockThrownCoolDown > 0)
        {
            self._rockThrownCoolDown -= Time.FrameTime;
            if (self._rockThrownCoolDown <= 0)
            {
                self.RockBomb();
            }
        }
        if (self._throwCoolDown > 0)
        {
            self._throwCoolDown -= Time.FrameTime;
        }
    }

    function DoAlive()
    {
        self.FindTarget();
        if (self.Target == null)
        {
            return;
        }
        direction = self.Target.Position - self.MapObject.Position;
        direction.Y = 0;
        distance = direction.Magnitude;
        isMove = true;
        angle = Vector3.SignedAngle(direction, self.MapObject.Forward, Vector3.Right);

        if (distance > 50)
        {
            self.Move();
            isMove = true;

            if (self._throwCoolDown <= 0)
            {
                if (Random.RandomFloat(0,1) < 0.7)
                {
                    self.ThrowRock();
                }
                self._throwCoolDown = Main._ThrowSpeed;
            }
        }
        elif (Math.Abs(angle) > 30)
        {
            if (angle > 0)
            {
                self.PlayAnimation(ZekeAnimation.TurnRight);
		self._actionCoolDown = Main._ActionCoolDown;
                /*self._actionCoolDown = self._shifter.GetAnimationLength(ZekeAnimation.TurnRight);*/
            }
            else
            {
                self.PlayAnimation(ZekeAnimation.TurnLeft);
		self._actionCoolDown = Main._ActionCoolDown;
                /*self._actionCoolDown = self._shifter.GetAnimationLength(ZekeAnimation.TurnLeft);*/
            }
            self._turnDirection = direction.Normalized;
        }
        else
        {
            self.Attack();
        }
        
        if (isMove)
        {
            self.MapObject.Forward = Vector3.Lerp(self.MapObject.Forward, direction.Normalized, self.RotateSpeed * Time.FrameTime);   
        }
        else
        {
            velocity = self._rigidbody.GetVelocity();
            velocity.X = 0;
            velocity.Z = 0;
            self._rigidbody.SetVelocity(velocity);
        }
    }

    function OnFrame()
    {
        if (self.NetworkView.Owner == Network.MyPlayer && self.Health > 0)
        {
            self._coolDownByFrame();
            if (self._actionCoolDown <= 0)
            {
                self.DoAlive();
            }

            if (self.Target != null && self._rockThrownCoolDown > 0)
            {
                direction = (self.Target.Position - self.MapObject.Position);
                direction.Y = 0;
                direction = direction.Normalized;
                self.MapObject.Forward = Vector3.Lerp(self.MapObject.Forward, direction, self.RotateSpeed * Time.FrameTime);
            }

            if (self._turnDirection != null && self._actionCoolDown > 0)
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

        if (self._actionCoolDown <= 0)
        {
            velocity = self._rigidbody.GetVelocity();
            velocity.Y = 0;
            if (velocity.Magnitude > 5)
            {
                self._shifter.PlayAnimation(ZekeAnimation.Move, 0.2);
            }
            else
            {
                self._shifter.PlayAnimation(ZekeAnimation.Idle, 0.2);
            }
        }

        self._rock.Transform.SetRenderersEnabled(self._rockThrownCoolDown > 0);

        if(Input.GetKeyDown("Interaction/Function1"))
        {
		 UI.ShowPopup("GameGuide");
	}

	
	
                            


	if(Network.IsMasterClient&&Input.GetKeyDown("Interaction/Function3"))
        {	    
		Game.PrintAll("
I get annoyed when I see Zeke...
								——OrangeCat橘猫

Someone always has to take the lead in doing something, doesn't they?
			       				——Hikari

Meow~
           					    ——君");	
		
        }

	if(Network.IsMasterClient&&Input.GetKeyDown("Interaction/Function4"))
        {
	        
		
		Game.PrintAll("
At work...
							    ——Hongyao

A new member of the tea party who is seriously studying custom logic.
           					    ——Ring");
		
        }


	
    }

    function GetDamaged(character, damage)
    {
        if (damage < self.Health)
        {
            self.Health -= damage;
        }
        else
        {
            self.Health = 0;
		self.AddNape=false;
		self.AddHitBox=false;
		self._rigidbody=null;
		self.MapObject.GetComponent("Rigidbody")=false;
		monkey1Text = UI.WrapStyleTag("Beast Titan", "size", "25");
		monkeyText = UI.WrapStyleTag(monkey1Text, "color", "brown");
            Game.ShowKillFeedAll(character.Name, monkeyText, damage, character.Weapon);
		self._actionCoolDown = 2.5;
            self.PlayAnimation(ZekeAnimation.Die);  
		self.AddNape=false;
	self._shifter.Rotation =self._shifter.Rotation+ Vector3(10,0,0);
            self.WaitAndDie(self._actionCoolDown);
		if(Main._e)
		{
				Main._d=false;
				Main._b=false;
				Main._e=false;
				self.AddNape=false;
				 self.AddHitBox=false;
				self._rigidbody=null;
		self.MapObject.GetComponent("Rigidbody")=false;
 				if(Network.IsMasterClient)
                     		{
				/*向着所有人发送指令*/			
				Network.SendMessageAll("fff");
				UI.SetLabelForTimeAll("MiddleCenter","Zeke Jager was defeated! Humanity wins!",10.0);
		      		}	
				Game.End(10.0);
				/*Game.Print("什么都无法舍弃的人,什么都改变不了...");*/
		}
        }
    }

    coroutine WaitAndDie(delay)
    {
	self.AddNape=false;
	 self.AddHitBox=false;
	self._rigidbody=null;
		self.MapObject.GetComponent("Rigidbody")=false;

       Main._roartitan4=Game.SpawnTitanAt("normal",self._shifter.Position+Vector3(0,-200,0));
		Main._roartitan4.PlaySound("Roar");
		Main._roartitan4.Health=0;
	Game.SpawnEffect("Blood1", self._shifter.Position+Vector3(0,80,0), Vector3.Zero, 10.0);
	Game.SpawnEffect("Blood2", self._shifter.Position+Vector3(0,80,0), Vector3.Zero, 10.0);
	wait 0.5;
        Game.SpawnEffect("TitanDie1", self._shifter.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
	Game.SpawnEffect("TitanDie1", self._shifter.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
	Game.SpawnEffect("TitanDie1", self._shifter.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
	 Game.SpawnEffect("TitanDie2", self._shifter.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
	 Game.SpawnEffect("TitanDie2", self._shifter.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
	Game.SpawnEffect("TitanDie2", self._shifter.Position+Vector3(0,15,0), Vector3.Zero, 15.0);

	 wait 1.4;
	Game.SpawnEffect("Boom7", self._shifter.Position+Vector3(0,25,0), Vector3.Zero, 50.0);
	self.PlayAnimation(ZekeAnimation.Die3);
	wait 1.0;
	self._shifter.Position =self._shifter.Position+ Vector3(0,0,0);
	
	Game.SpawnEffect("TitanDie1", self._shifter.Position+Vector3(0,12,0), Vector3.Zero, 15.0);
	Game.SpawnEffect("TitanDie2", self._shifter.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
	wait 1.5;
	Game.SpawnEffect("TitanDie1", self._shifter.Position+Vector3(0,12,0), Vector3.Zero, 15.0);
	Game.SpawnEffect("TitanDie1", self._shifter.Position+Vector3(0,12,0), Vector3.Zero, 15.0);
        self.MapObject.Active = false;

    }

    function PlayAnimation(animation)
    {
        self._shifter.PlayAnimation(animation);
        self.NetworkView.SendMessageOthers("a" + animation);
    }

    function OnNetworkMessage(sender, message)
    {
        if (String.StartsWith(message, "a"))
        {
            self._shifter.PlayAnimation(String.Substring(message, 1));
        }
        elif (String.StartsWith(message, "d"))
        {
            Split = String.Split(String.Substring(message, 1), " ");
            viewID = Convert.ToInt(Split.Get(0));
            damage = Convert.ToInt(Split.Get(1));
            character = Game.FindCharacterByViewID(viewID);
            self.GetDamaged(character, damage);
        }
    }

    function SendNetworkStream()
    {
        self.NetworkView.SendStream(self.Health);
        self.NetworkView.SendStream(self._actionCoolDown);
        self.NetworkView.SendStream(self._rockThrownCoolDown);
	self.NetworkView.SendStream(self.MapObject.Active);
    }

    function OnNetworkStream()
    {
        self.Health = self.NetworkView.ReceiveStream();
        self._actionCoolDown = self.NetworkView.ReceiveStream();
        self._rockThrownCoolDown = self.NetworkView.ReceiveStream();
	self.MapObject.Active = self.NetworkView.ReceiveStream();
    }
}

component ZekeNapeHurtBox
{
    _shifter = null;
    _getDamagedCoolDown = 0.0;
    
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
        self._shifter.NetworkView.SendMessage(self._shifter.NetworkView.Owner, "d" + character.ViewID + " " + Convert.ToInt(damage));
        self._getDamagedCoolDown = 0.02;
        if (character.IsMainCharacter)
        {
            Game.ShowKillScore(damage);
        }
    }

}

component ZekeHitBox
{
    _shifter = null;
    
    
    function SetShifter(shifter)
    {
        self._shifter = shifter;
        return self;
    }

    function OnCollisionEnter(other)
    {
        if (self._shifter._attackCoolDown <= 0)
        {
            return;
        }
        if (other.Type != "Human")
        {
            return;
        }
	monkey1Text = UI.WrapStyleTag("Beast Titan", "size", "25");
	monkeyText = UI.WrapStyleTag(monkey1Text, "color", "brown");
        other.GetDamaged(monkeyText , Main._TrueLeviNum);
    }
}

component ZekeBombHitBox
{
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
        if (self._hitTargets.Contains(other.ViewID))
        {
            return;
        }
	monkey1Text = UI.WrapStyleTag("Beast Titan", "size", "25");
	monkeyText = UI.WrapStyleTag(monkey1Text, "color", "brown");
        other.GetDamaged(monkeyText, Main._TrueLeviNum);
        self._hitTargets.Set(other.ViewID, 0);
    }

    function Bomb(time)
    {
        self._bombCoolDown = time;
    }
}
