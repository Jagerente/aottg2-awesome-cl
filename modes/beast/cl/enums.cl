extension SpecialEnumCD
{
	_cooldowns = Dict();

	function Init()
	{
		self._cooldowns.Set(SpecialEnum.AHSSTwinShot, 1.0);
		self._cooldowns.Set(SpecialEnum.Annie, 60.0);
		self._cooldowns.Set(SpecialEnum.BladeThrow, 1.0);
		self._cooldowns.Set(SpecialEnum.Carry, 2.0);
		self._cooldowns.Set(SpecialEnum.Confuse, 30.0);
		self._cooldowns.Set(SpecialEnum.Dance, 2.0);
		self._cooldowns.Set(SpecialEnum.Distract, 5.0);
		self._cooldowns.Set(SpecialEnum.DownStrike, 5.0);
		self._cooldowns.Set(SpecialEnum.Eren, 60.0);
		self._cooldowns.Set(SpecialEnum.Escape, 0);
		self._cooldowns.Set(SpecialEnum.Potato, 20.0);
		self._cooldowns.Set(SpecialEnum.Smell, 60.0);
		self._cooldowns.Set(SpecialEnum.SmokeBomb, 15.0);
		self._cooldowns.Set(SpecialEnum.Spin1, 5.0);
		self._cooldowns.Set(SpecialEnum.Spin2, 5.0);
		self._cooldowns.Set(SpecialEnum.Spin3, 3.5);
		self._cooldowns.Set(SpecialEnum.Stock, 0);
		self._cooldowns.Set(SpecialEnum.Supply, 300.0);
		self._cooldowns.Set(SpecialEnum.Switchback, 2.0);
	}

	function GetCooldown(special)
	{
		return self._cooldowns.Get(special);
	}
}

extension ColorEnum
{
	Orange  = "FFA500";
	Blue    = "0000FF";
	Cyan    = "00FFFF";
	Fuchsia = "FF00FF";
	Green   = "008000";
	Yellow  = "FFFF00";
	Red     = "FF0000";
	Brown   = "A52A2A";
}
