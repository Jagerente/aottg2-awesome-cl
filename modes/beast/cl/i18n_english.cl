# @import i18n
# @import html
# @import enums
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
