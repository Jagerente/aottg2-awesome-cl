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
		Input.SetKeyDefaultEnabled(InputInteractionEnum.Function1, false);
		Input.SetKeyDefaultEnabled(InputInteractionEnum.Function3, false);
		Input.SetKeyDefaultEnabled(InputInteractionEnum.Function4, false);
		Input.SetKeyDefaultEnabled(InputGeneralEnum.SkipCutscene, false);
		Input.SetKeyDefaultEnabled(InputInteractionEnum.ItemMenu, false);

		self.Guide = InputInteractionEnum.Function1;
		self.Interaction1 = InputInteractionEnum.Function3;
		self.Interaction2 = InputInteractionEnum.Function4;
		self.SkipCutscene = InputGeneralEnum.SkipCutscene;
		self.SwitchWeapon = InputInteractionEnum.ItemMenu;
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
		Input.SetKeyDefaultEnabled(InputGeneralEnum.Forward, enabled);
		Input.SetKeyDefaultEnabled(InputGeneralEnum.Back, enabled);
		Input.SetKeyDefaultEnabled(InputGeneralEnum.Left, enabled);
		Input.SetKeyDefaultEnabled(InputGeneralEnum.Right, enabled);
		Input.SetKeyDefaultEnabled(InputHumanEnum.Jump, enabled);
		Input.SetKeyDefaultEnabled(InputHumanEnum.Dodge, enabled);
		Input.SetKeyDefaultEnabled(InputHumanEnum.HookLeft, enabled);
		Input.SetKeyDefaultEnabled(InputHumanEnum.HookRight, enabled);
		Input.SetKeyDefaultEnabled(InputHumanEnum.HookBoth, enabled);
		Input.SetKeyDefaultEnabled(InputHumanEnum.AttackDefault, enabled);
		Input.SetKeyDefaultEnabled(InputHumanEnum.AttackSpecial, enabled);
	}
}
