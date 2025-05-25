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
