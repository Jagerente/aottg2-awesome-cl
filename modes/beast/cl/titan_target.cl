# @import router
# @import messages
# @import titan_proxy

extension TitanTargetSwitcher
{
    MinDamage = 1000;

    # @param Human
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
                    for(t in Game.AITitans)
                    {
                        TitanProxy(t).Target(killer, 15);
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
