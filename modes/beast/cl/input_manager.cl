# @import enums

extension InputManager
{
    # @type string
    Guide = null;
    # @type string
    Interaction1 = null;
    # @type string
    Interaction2 = null;
    # @type string
    SkipCutscene = null;

    function InitKeybinds()
    {
        Input.SetKeyDefaultEnabled(KeyBindsEnum.INTERACTION_FUNCTION1, false);

        self.Guide = KeyBindsEnum.INTERACTION_FUNCTION1;
        self.Interaction1 = KeyBindsEnum.INTERACTION_FUNCTION3;
        self.Interaction2 = KeyBindsEnum.INTERACTION_FUNCTION4;
        self.SkipCutscene = KeyBindsEnum.GENERAL_SKIPCUTSCENE;
    }
}
