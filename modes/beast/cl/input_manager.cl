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
	# @type string
	SwitchWeapon = null;

	function InitKeybinds()
	{
		Input.SetKeyDefaultEnabled(KeyBindsEnum.INTERACTION_FUNCTION1, false);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.INTERACTION_FUNCTION3, false);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.INTERACTION_FUNCTION4, false);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.GENERAL_SKIPCUTSCENE, false);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.INTERACTION_ITEMMENU, false);

		self.Guide = KeyBindsEnum.INTERACTION_FUNCTION1;
		self.Interaction1 = KeyBindsEnum.INTERACTION_FUNCTION3;
		self.Interaction2 = KeyBindsEnum.INTERACTION_FUNCTION4;
		self.SkipCutscene = KeyBindsEnum.GENERAL_SKIPCUTSCENE;
		self.SwitchWeapon = KeyBindsEnum.INTERACTION_ITEMMENU;
	}

	function DisableInput()
	{
		self._SwitchInput(false);
	}

	function EnableInput()
	{
		self._SwitchInput(true);
	}

	function _SwitchInput(enabled)
	{
		Input.SetKeyDefaultEnabled(KeyBindsEnum.GENERAL_FORWARD, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.GENERAL_BACK, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.GENERAL_LEFT, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.GENERAL_RIGHT, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.HUMAN_JUMP, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.HUMAN_DODGE, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.HUMAN_HOOKLEFT, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.HUMAN_HOOKRIGHT, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.HUMAN_HOOKBOTH, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.HUMAN_ATTACKDEFAULT, enabled);
		Input.SetKeyDefaultEnabled(KeyBindsEnum.HUMAN_ATTACKSPECIAL, enabled);
	}
}
