class Main
{
    function OnGameStart()
    {
        I18n.RegisterLanguagePack(EnglishLanguagePack());
        I18n.RegisterLanguagePack(ChineseLanguagePack());

        Game.Print("Your language: " + UI.GetLanguage());

        Game.Print(I18n.Get("foo"));
        Game.Print(I18n.Get("bar"));
        Game.Print(I18n.Get("baz"));
        
        Game.Print(I18n.Get("keyThatOnlyExistsInEnglishPack"));
        Game.Print(I18n.Get("keyThatOnlyExistsInChinesePack"));

        I18n.SetDefaultLanguage(I18n.ChineseLanguage);

        Game.Print(I18n.Get("keyThatOnlyExistsInEnglishPack"));
        Game.Print(I18n.Get("keyThatOnlyExistsInChinesePack"));
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

    _languages = Dict();
    _defaultLanguage = null;

    # @param key string
    function Get(key)
    {
        pack = self._LoadLanguagePack();
        localized = pack.Get(key, null);
        if (localized != null)
        {
            return localized;
        }

        defaultPack = self._languages.Get(self._defaultLanguage);
        localized = defaultPack.Get(key, null);
        if (localized != null)
        {
            return localized;
        }

        return "[ERR] Localized string not found: " + key;
    }

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

    # @return Dict
    function _LoadLanguagePack()
    {
        return self._languages.Get(UI.GetLanguage(), self._languages.Get(self._defaultLanguage));
    }
}

# This is for typing purposes. Pretend it's some kind of "interface"
class LanguagePack
{
    # @return Dict
    function Load(){}

    # @return string
    function Language(){}
}

class EnglishLanguagePack
{
    _pack = Dict();

    function Init()
    {
        self._pack.Set("foo", "English string 1");
        self._pack.Set("bar", "English string 2");
        self._pack.Set("baz", "English string 3");
        self._pack.Set("keyThatOnlyExistsInEnglishPack", "This key only exists in English pack");
    }

    # @return Dict
    function Load(){
        return self._pack;
    }

    # @return string
    function Language(){
        return I18n.EnglishLanguage;
    }
}

class ChineseLanguagePack
{
    _pack = Dict();

    function Init()
    {
        self._pack.Set("foo", "示例文本一");
        self._pack.Set("bar", "示例文本二");
        self._pack.Set("baz", "示例文本三");
        self._pack.Set("keyThatOnlyExistsInChinesePack", "This key only exists in Chinese pack");
    }

    # @return Dict
    function Load(){
        return self._pack;
    }

    # @return string
    function Language(){
        return I18n.ChineseLanguage;
    }
}
