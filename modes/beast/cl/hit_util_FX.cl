# @import enums
extension HitUtilsFX
{
    function DamageVisualFX(napePosition, damage, armor)
    {
        Game.SpawnEffect(EffectNameEnum.CriticalHit, napePosition, Vector3.Zero, 6.0);
		if (damage > armor)
		{
			Game.SpawnEffect(EffectNameEnum.Blood1, napePosition, Vector3.Zero, 4.0);
		}
    }

    # @param human Human
    # @param damage int
    # @param type string
    # @param armor int
    function DamageHitSoundFX(human, damage, type, armor)
    {
        if (type == WeaponEnum.Blade)
        {
            self._HandleBladesSound(human, damage, armor);
            return;
        }
        elif (type == WeaponEnum.AHSS)
        {
            self._HandleAHSSSound(human, damage, armor);
            return;
        }
        elif (type == WeaponEnum.APG)
        {          
            self._HandleAPGSound(human, damage, armor);
            return;
        }
    }

    function _HandleBladesSound(human, damage, armor)
	{
        if (damage <= armor)
        {
            human.StopSound(HumanSoundEnum.BladeBreak);
            human.PlaySound(HumanSoundEnum.BladeBreak);
            
            return;
        }

        if (damage < 500)
        {
            sound = HumanSoundEnum.NapeHit;
        }
        elif (damage < 1000)
        {
            sound = self.GetRandom(WeaponEnum.Blade, 1);
        }
        elif (damage < 2000)
        {
            sound = self.GetRandom(WeaponEnum.Blade, 2);
        }
        elif (damage < 3000)
        {
            sound = self.GetRandom(WeaponEnum.Blade, 3);
        }       
        else
        {
            sound = self.GetRandom(WeaponEnum.Blade, 4);
        }

        human.StopSound(sound);
        human.PlaySound(sound);
    }

    function _HandleAHSSSound(human, damage, armor)
	{
        if (damage < 1000 || damage < armor)
        {
            sound = HumanSoundEnum.NapeHit;
        }
        elif (damage < 2000)
        {
            sound = self.GetRandom(WeaponEnum.AHSS, 1);
        }
        else
        {
            sound = self.GetRandom(WeaponEnum.AHSS, 2);
        }

        human.StopSound(sound);
        human.PlaySound(sound);
    }

    function _HandleAPGSound(human, damage, armor)
	{
        human.StopSound(HumanSoundEnum.NapeHit);   
        human.PlaySound(HumanSoundEnum.NapeHit);  
    }

    # @param weapon string
    # @param thresholdType int
    function GetRandom(weapon, thresholdType)
    {
        if (weapon == WeaponEnum.AHSS)
        {
            numVar = 2;
        }
        elif (weapon == WeaponEnum.Blade)
        {
            numVar = 3;
        }
        else
        {
            return;
        }
        rand = Random.RandomInt(1, numVar + 1);
		sound = weapon+"Nape"+Convert.ToString(thresholdType)+"Var"+Convert.ToString(rand);

        return sound; 
    }
}
