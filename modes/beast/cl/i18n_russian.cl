# @import i18n
# @import html
# @import enums
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
