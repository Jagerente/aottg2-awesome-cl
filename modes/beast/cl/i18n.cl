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
		return self._languages.Get(Locale.CurrentLanguage, self._languages.Get(self._defaultLanguage));
	}
}

class LanguagePack
{
	# @return Dict<string, string>
	function Load(){}

	# @return string
	function Language(){}
}
