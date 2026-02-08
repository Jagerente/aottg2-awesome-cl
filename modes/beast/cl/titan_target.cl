# @import game_state
# @import router
# @import messages
# @import titan_proxy

extension TitanTargetSwitcher
{
	MinDamage = 1000;

	# @type Human
	_currentTarget = null;

	function OnCharacterDamaged(victim, killer, killerName, damage)
	{
		if (victim.Type == "Titan")
		{
			if (damage >= self.MinDamage && self._currentTarget != killer)
			{
				self._currentTarget = killer;

				killer.AddOutline(Color(255,0,0), "OutlineVisible");

				if(Network.IsMasterClient)
				{
					for(t in GameState.Titans)
					{
						t.Target(killer, 15);
					}

					params = List();
					params.Add(killer.Name);

					Dispatcher.SendAll(SetLocalizedLabelMessage.New(
						"MiddleCenter",
						"ui.titans_target",
						params,
						6.0
					));
				}
			}
		}
	}
}
