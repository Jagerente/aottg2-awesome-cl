# @import html
# @import i18n
# @import enums

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
