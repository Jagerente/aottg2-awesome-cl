# @import i18n
# @import html
# @import enums
class ChineseLanguagePack
{
	# @type Dict<string, string>
	_pack = Dict();
	_type = 0;

	# @return Dict<string, string>
	function Load()
	{
		return self._pack;
	}

	# @return string
	function Language()
	{
		if (self._type == 0)
		{
			return I18n.ChineseLanguage;
		}

		return I18n.TraditionalChineseLanguage;
	}

	function Init(t)
	{
		self._type = t;

		self._pack.Set("general.beast.lowercase", "兽之巨人");
		self._pack.Set("general.beast.uppercase", "兽之巨人");
		self._pack.Set("general.beast.titlecase", "兽之巨人");
		self._pack.Set("general.beast.sentencecase", "兽之巨人");

		self._pack.Set("chat.start", "杀死同伴，阻止吉克");
		self._pack.Set("chat.soldier_died", "同伴 {0} 已牺牲");

		self._pack.Set("info.beast_type.pitcher", "投手
		以投掷作为主要攻击手段,移速较慢");
		self._pack.Set("info.beast_type.warrior", "战士
		近战远程兼备,移速较快");
		self._pack.Set("info.beast_type.assassin", "刺客
		以近战为主要攻击手段,移速极快");
		self._pack.Set("info.special_events.stronger", "同伴已化身为更为强大的无垢巨人!!!");
		self._pack.Set("info.special_events.last_chance", "断绝补给,破釜沉舟!!!");

		self._pack.Set("ui.info.title", "游戏说明");
		self._pack.Set("ui.info.rules", "查看游戏规则");
		self._pack.Set("ui.info.switch_weapon", "切换武器(刀/雷枪)");
		self._pack.Set("ui.info.beast_type", "兽巨类型");
		self._pack.Set("ui.info.special_events", "特殊事件");
		self._pack.Set("ui.info.levi_mode", "兵长模式已开启!");

		self._pack.Set("guide.mao", "OrangeCat橘猫");
		self._pack.Set("guide.1", "欢迎游玩由 {0} 所开发的 {1} 地图!");
		self._pack.Set("guide.2", "以下是你初次游玩时，应当注意的:");
		self._pack.Set("guide.3", "游戏玩法");
		self._pack.Set("guide.4", "在限定时间内，巨人数量仅剩3头时， {0} 将会加入战斗!");
		self._pack.Set("guide.5", "之后，游戏重新计时，结束条件是：{0} 死亡/全体玩家阵亡/计时结束");

		self._pack.Set("guide.recommendations.header", "房主推荐设置");
		self._pack.Set("guide.recommendations.skill", "技能-Spin1");
		self._pack.Set("guide.recommendations.weapon", "武器-刀/雷枪");
		self._pack.Set("guide.recommendations.difficulty", "难度-奇行种");
		self._pack.Set("guide.recommendations.settings.endless", "复活-关闭");
		self._pack.Set("guide.recommendations.settings.invincible", "人类无敌时间-15秒");

		self._pack.Set("guide.description.header", "地图说明");
		self._pack.Set("guide.description.body", "玩家无垢巨人攻速移速极快，且无限体力
人类可自由切换刀/雷枪、无法使用AHSS/APG
禁用跳舞/Eren/Annie技能、有限/没有补给
部分建筑/补给点可破坏、自定义限时战役
击杀分数超过特定数值的玩家，将在20秒内成为全体无垢巨人的追击目标
		未开启兵长模式时，无法免疫兽巨攻击");

		self._pack.Set("guide.mode_settings.header", "房主可自定义内容");
		self._pack.Set("guide.mode_settings.1", "各类巨人数量(除普通巨人)");
		self._pack.Set("guide.mode_settings.2", "刀片/雷枪数量");
		self._pack.Set("guide.mode_settings.3", "气体量");
		self._pack.Set("guide.mode_settings.4", "是否禁止使用飞刀");
		self._pack.Set("guide.mode_settings.5", "是否全员刀兵技能设置为Spin1");
		self._pack.Set("guide.mode_settings.6", "Spin1/Spin2/Spin3 是否无CD");
		self._pack.Set("guide.mode_settings.7", "旋风斩是否更强(长按右键持续旋风斩)");
		self._pack.Set("guide.mode_settings.8", "兵长模式:旋风斩自锁无垢巨/兽巨后颈
		可自定义人类伤害且免疫兽之巨人攻击");
		self._pack.Set("guide.mode_settings.9", "成为巨人攻击目标的最低击杀分数");
		self._pack.Set("guide.mode_settings.10", "吉克逃出森林时间，即战役限制时间(吉克出现后时间重置)");
		self._pack.Set("guide.mode_settings.11", "兽巨类型:投手/战士/刺客");
		self._pack.Set("guide.mode_settings.12", "无垢巨人是否更加强大");
		self._pack.Set("guide.mode_settings.13", "是否开启更加强大的无垢巨人描边");
		self._pack.Set("guide.mode_settings.14", "是否断绝补给,破釜沉舟");
		self._pack.Set("guide.mode_settings.15", "是否开启士兵描边");
		self._pack.Set("guide.mode_settings.16", "是否选用进击的巨人原版bgm/游戏自带bgm/无");
		self._pack.Set("guide.mode_settings.17", "玩家无垢巨人血量");

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

		self._pack.Set("guide.staff.yy.role", "兽之巨人模型");
		self._pack.Set("guide.staff.xx.role", "兽之巨人模型动画");
		self._pack.Set("guide.staff.hongyao.role", "兽之巨人组件逻辑");
		self._pack.Set("guide.staff.kun_levi.role", "自定义逻辑顾问");
		self._pack.Set("guide.staff.hikari.role", "逻辑优化 & 英文版翻译");
		self._pack.Set("guide.staff.ring.role", "兵长模式逻辑");
		self._pack.Set("guide.staff.han.role", "韩语版翻译");
		self._pack.Set("guide.staff.jagerente.role", "多语言版本部署，代码重构 & 逻辑优化");

		self._pack.Set("guide.about.header", "关于茶话会");
		self._pack.Set("guide.about.contacts", "联系方式");
		self._pack.Set("guide.about.1", "茶话会TeaParty，是来自中国的技术型公会");
		self._pack.Set("guide.about.2", "我们会讨论诸如模组，ASO，竞速以及其他巨猎游戏内容");
		self._pack.Set("guide.about.3", "目前我们在负责模组开发、模组重置的工作");
		self._pack.Set("guide.about.4", "同样地，我们也会为来自海外的有趣地图进行汉化工作");
		self._pack.Set("guide.about.5", "如果你希望加入我们，不妨通过联系方式以进行申请吧!");
		self._pack.Set("guide.about.qq_group", "QQ公会群: 662494094");
		self._pack.Set("guide.about.discord", "Discord: 茶话会TeaParty (https://discord.gg/RdhPSUAMSt)");

		self._pack.Set("ui.goal.kill_titans", "{0} 头奇形种曾是同伴,请杀死他们,否则吉克将逃出森林");
		self._pack.Set("ui.goal.kill_beast", HTML.Size(HTML.Color("兽之巨人", ColorEnum.Brown), 25) + " 出现了,干掉它!");
		self._pack.Set("ui.goal.kill_titans_time", "{0} 头奇形种曾是同伴,请杀死他们,否则吉克将逃出森林 | 剩余时间: {1}秒");

		self._pack.Set("ui.lose", "这就是普通士兵和阿克曼的差距...");
		self._pack.Set("ui.lose.2", "已无人阻止吉克...");

		self._pack.Set("ui.titans_target", "巨人攻击目标: {0}");

		self._pack.Set("dialogue.name.zeke", "吉克·耶格尔");
		self._pack.Set("dialogue.name.levi", "利威尔·阿克曼");

		self._pack.Set("dialogue.a.1", "嗷呵啊啊啊啊啊啊啊——！！！！");
		self._pack.Set("dialogue.a.2", "呃?!");
		self._pack.Set("dialogue.a.3", "再见了,兵长...
你这么关心部下,
		他们只是变大了些许而已");
		self._pack.Set("dialogue.a.4", "你应该不会把无辜的部下砍死吧?");
		self._pack.Set("dialogue.a.5", "红酒里有吉克的脊髓液?
什么时候掺进去的?
也没有发生身体僵直的前兆。
		他骗了我们吗?");
		self._pack.Set("dialogue.a.6", "可恶!... 好快! 动作不是一般地敏捷！
这也是吉克干的吗?!！
巴里斯..!!
		你们还在那里边吗...?大家...");

		self._pack.Set("dialogue.b.1", "真可惜,我们没能相互信赖。");
		self._pack.Set("dialogue.b.2", "全世界的战力很快就会向这座小岛集结,
		你们根本不知道... 这意味着什么。");
		self._pack.Set("dialogue.b.3", "你们自认为有力量、有时间、有选择。
之所以会有这种误解...
		利威尔,都是因为你。");
		self._pack.Set("dialogue.b.4", "就算我说出自己的真实意图,
你们也无法理解。
		是吧,艾伦! 只有我们...才能相互理解。");
		self._pack.Set("dialogue.b.5", "只要离开这片森林,
		我很快就能到你身边了!");

		self._pack.Set("dialogue.c.ui.1", "{0} <color=#FF0000> 登场!!</color>
		隐藏在大树后面可躲避兽之巨人的投石!");
		self._pack.Set("dialogue.c.1", "唔哦?! 给我上!!!
		怎么搞的,怎么又是这样!!!");
		self._pack.Set("dialogue.c.2", "你在哪里,利威尔！
那里吗?! 你可爱的部下们去哪儿了?
		难道你全杀掉了吗?真可怜!");
		self._pack.Set("dialogue.c.3", "什么? 是树枝?");
		self._pack.Set("dialogue.c.4", "你真有够拼啊,胡子混蛋。
		你要做的明明就只有乖乖看书而已,是什么给了你能够逃离我手掌心的幻想呢?");
		self._pack.Set("dialogue.c.5", "你是不是以为我不会亲手杀死同伴,所以把我的部下变成巨人就能放心了?");
		self._pack.Set("dialogue.c.6", "你根本不知道,我们走到现在究竟杀死了多少同伴!");

		self._pack.Set("dialogue.d.chat", "牺牲的同伴深切地凝视着我们...");
		self._pack.Set("dialogue.d.1", "永别了,利威尔...");
		self._pack.Set("dialogue.d.2", "艾伦,哥哥很快就到你那里了!");

		self._pack.Set("dialogue.e.chat", "你终究不是他...");
		self._pack.Set("dialogue.e.1", "看样子你已经没法追上来了。
		与你的同伴们一起葬身于此吧,利威尔。");
		self._pack.Set("dialogue.e.2", "艾伦与我的崇高事业,没人能够阻止!");

		# self._pack.Set("dialogue.f.chat", "何も捨てることができない人には、何も変えることはできない...");
		self._pack.Set("dialogue.f.chat", "什么都无法舍弃的人,什么都改变不了...");
		self._pack.Set("dialogue.f.1", "不！！！！！！");
		self._pack.Set("dialogue.f.2", "唷,胡子混蛋。
你真是又臭又脏又丑啊,混球。
		我暂且不会在此解决你,尽管放心好了。");

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

		self._pack.Set("ui.zeke_defeated", "吉克战败,人类胜利");
	}
}
