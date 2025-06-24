# -----------------------------------------
# Extension Utils for Hit FX
#

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

    function DamageHitSoundFX(player, damage, type, armor)
    {
        # @type Human
        human = player.Character;
        if (human == null)
        {
            Game.Debug("HitUtilFX : DamageHitFX player does not have character (null)");
            return;
        }
        if (human.Type != "Human")
        {
            Game.Debug("HitUtilFX : DamageHitFX player character is not human");
            return;
        }
        if (type == WeaponEnum.BLADES)
        {
            if (damage > armor)
            {
                if (damage < 500)
                {
                    human.StopSound(PlayerSoundEnum.NAPEHIT);
                    human.PlaySound(PlayerSoundEnum.NAPEHIT);
                }
                elif (damage < 1000)
                {
                    sound = self.GetRandom(type, 1);
                    human.StopSound(sound);
                    human.PlaySound(sound);
                }
                elif (damage < 2000)
                {
                    sound = self.GetRandom(type, 2);
                    human.StopSound(sound);
                    human.PlaySound(sound);
                }
                elif (damage < 3000)
                {
                    sound = self.GetRandom(type, 3);
                    human.StopSound(sound);
                    human.PlaySound(sound);
                }
                else
                {
                    sound = self.GetRandom(type, 4);
                    human.StopSound(sound);
                    human.PlaySound(sound);
                }
            }
            else
            {
                human.StopSound(PlayerSoundEnum.BLADEBREAK);
                human.PlaySound(PlayerSoundEnum.BLADEBREAK);
            }
            return;
        }
        elif (type == WeaponEnum.AHSS)
        {
            if (damage < 1000 || damage < armor)
            {
                human.StopSound(PlayerSoundEnum.NAPEHIT);
                human.PlaySound(PlayerSoundEnum.NAPEHIT);
            }
            elif (damage < 2000)
            {
                sound = self.GetRandom(type, 1);
                human.StopSound(sound);
                human.PlaySound(sound);
            }
            else
            {
                sound = self.GetRandom(type, 2);
                human.StopSound(sound);
                human.PlaySound(sound);
            }
            return;
        }
        elif (type == WeaponEnum.APG)
        {
            human.StopSound(PlayerSoundEnum.NAPEHIT);   
            human.PlaySound(PlayerSoundEnum.NAPEHIT);            
            return;
        }
    }

    # Get Random Variation of a Hit Sound Selection

    function GetRandom(weapon, type)
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
		sound = weapon+"Nape"+Convert.ToString(type)+"Var"+Convert.ToString(rand);

        return sound; 
    }
}
