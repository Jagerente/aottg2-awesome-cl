# I18n - Internationalization

A simple localization module for registering and retrieving translated strings at runtime, with automatic fallback to a default language pack when a key is missing in the current game language.

## Features

- Register multiple LanguagePacks.
- Retrieve localized strings via `I18n.Get(key)`.
- Fallback to a default pack if a key is missing in the active UI language.

## Usage 

1. Implement a LanguagePack:

```cs
class LanguagePack
{
    # @return Dict
    function Load(){}

    # @return string
    function Language(){}
}
```

For example:

```cs
class EnglishLanguagePack
{
    _pack = Dict();

    function Init()
    {
        self._pack.Set("foo", "English string 1");
        self._pack.Set("bar", "English string 2");
        self._pack.Set("baz", "English string 3");
        sekf._pack.Set("keyThatOnlyExistsInEnglishPack", "This key only exists in English pack");
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
        sekf._pack.Set("keyThatOnlyExistsInChinesePack", "This key only exists in Chinese pack");
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
```

2. Register your packs

```cs
class Main
{
    function OnGameStart()
    {
        I18n.RegisterLanguagePack(EnglishLanguagePack());
        I18n.RegisterLanguagePack(ChineseLanguagePack());
    }

}
```

> The first registered pack becomes the default if you don’t call `I18n.SetDefaultLanguage()` explicitly.

3. Retrieve localized strings

```cs
# prints the localized value for "foo"
Game.Print(I18n.Get("foo"));

# fallbacks to default pack if missing in the current game language
Game.Print(I18n.Get("keyThatOnlyExistsInEnglishPack"));
```

- If a key is not found in the current game language, `I18n.Get()` will attempt to fetch it from the default pack.
- If still not found, it returns an error string.
