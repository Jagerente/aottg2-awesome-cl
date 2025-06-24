# @import enums
extension HitUtilsFX
{

    function DamageVisualFX(napePosition, damage, armor)
    {
        Game.SpawnEffect(EffectEnum.CRITICALHIT, napePosition, Vector3.Zero, 6.0);
		if (damage > armor)
		{
			Game.SpawnEffect(EffectEnum.BLOOD1, napePosition, Vector3.Zero, 4.0);
		}
    }

    # @param human Human
    # @param damage int
    # @param type string
    # @param armor int
    function DamageHitSoundFX(human, damage, type, armor)
    {
        if (type == WeaponEnum.BLADES)
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
            human.StopSound(PlayerSoundEnum.BLADEBREAK);
            human.PlaySound(PlayerSoundEnum.BLADEBREAK);
            
            return;
        }

        if (damage < 500)
        {
            sound = PlayerSoundEnum.NAPEHIT;
        }
        elif (damage < 1000)
        {
            sound = self.GetRandom(WeaponEnum.BLADES, 1);
        }
        elif (damage < 2000)
        {
            sound = self.GetRandom(WeaponEnum.BLADES, 2);
        }
        elif (damage < 3000)
        {
            sound = self.GetRandom(WeaponEnum.BLADES, 3);
        }       
        else
        {
            sound = self.GetRandom(WeaponEnum.BLADES, 4);
        }

        human.StopSound(sound);
        human.PlaySound(sound);
    }

    function _HandleAHSSSound(human, damage, armor)
	{
        if (damage < 1000 || damage < armor)
        {
            sound = PlayerSoundEnum.NAPEHIT;
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
        human.StopSound(PlayerSoundEnum.NAPEHIT);   
        human.PlaySound(PlayerSoundEnum.NAPEHIT);  
    }

    # @param weapon string
    # @param thresholdType int
    function GetRandom(weapon, thresholdType)
    {
        if (weapon == WeaponEnum.AHSS)
        {
            numVar = 2;
        }
        elif (weapon == WeaponEnum.BLADES)
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