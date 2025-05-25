# @import builtin
component ZekeShifter
{
    Health = 1000;

    Damage = 1000;
    DamageText = "Beast Titan";
    
    MoveSpeed = 20.0;
    RotateSpeed = 5.0;
    
    ThrowCooldown = 4.0;
    ActionCooldown = 2.0;
    
    TimeToTypeSwitch = 10.0;
    TimeToTypeSwitchRandomOffset = 5.0;
    
    BeastTypePitcherEnabled = true;
    BeastTypePitcherEnabledTooltip = "Long-range attack, low health";
    BeastTypeWarriorEnabled = true;
    BeastTypeWarriorEnabledTooltip = "It has both melee and long-range capabilities, high health";
    BeastTypeAssassinEnabled = true;
    BeastTypeAssassinEnabledTooltip = "It mainly uses close combat as its attack method, low health.";

    ShowHitBoxes = false;

    # @type MapObject
    _rock = null;

    # @type RigidbodyBuiltin
    _rigidbody = null;
    _transform = null;

    # @type ZekeNapeHurtBox
    _napeHurtBox = null;

    # @type Transform
    _armLeftTransform = null;
    # @type Transform
    _armRightTransform = null;

    # @type ZekeHitBox
    _armLeftHitBox = null;
    # @type ZekeHitBox
    _armRightHitBox = null;
    
    # @type ZekeBombHitBox
    _bombHitBox = null;

    _onDieHandler = null;

    _hitBoxVisibility = "0";

    _initizalized = false;
    _enabled = false;
    
    _types = List();
    _currentType = "";

    # @type Human
    _target = null;
    # @type Vector3
    _turnDirection = null;

    _throwCDLeft = 0.0;
    _actionCDLeft = 0.0;
    _attackCDLeft = 0.0;
    _rockThrownCDLeft = 0.0;
    _typeSwitchCDLeft = 0.0;

    _dieOnce = false;

    function Initialize()
    {
        self._transform = self.MapObject.Transform;
        self._rigidbody = self.MapObject.GetComponent("Rigidbody");

        if (self.ShowHitBoxes)
        {
            self._hitBoxVisibility = "1";
        }
        else
        {
            self._hitBoxVisibility = "0";
        }

        self._InitTypes();

        self._SwitchType(self._RandomType());

        self._AddNape();
        self._AddHitBox();
        self._AddRock();

        self._initizalized = true;
    }
    
    function RegisterOnDieHandler(handler)
    {
        self._onDieHandler = handler;
    }

    function Enable()
    {
        self.MapObject.Active = true;
        self._enabled = true;
    }

    function Disable()
    {
        self.MapObject.Active = false;
        self._enabled = false;
    }

    function TeleportTo(pos)
    {
        self.MapObject.Position = pos;
    }

    function FindTarget()
    {
        if (self._target != null && self._target.Health <= 0)
        {
            self._target = null;
        }

        if (self._target == null)
        {
            minDistance = 0;
            for (human in Game.Humans)
            {
                direction = human.Position - self.MapObject.Position;
                direction.Y = 0;
                distance = direction.Magnitude;
                if (self._target == null || distance < minDistance)
                {
                    self._target = human;
                    minDistance = distance;
                }
            }
        }
    }

    function Attack()
    {
        self.PlayAnimation(ZekeAnimation.Attack);
        self._actionCDLeft = self._transform.GetAnimationLength(ZekeAnimation.Attack);
        self._attackCDLeft = self._actionCDLeft;
    }

    function Move()
    {
        direction = self._target.Position - self.MapObject.Position;
        direction.Y = 0;
        direction = direction.Normalized;
        velocity = self._rigidbody.GetVelocity();
        velocity.X = 0;
        velocity.Z = 0;
        self._rigidbody.SetVelocity(direction * self.MoveSpeed + velocity);
    }

    function ThrowRock()
    {
        self.PlayAnimation(ZekeAnimation.Throw);
        self._actionCDLeft = self._transform.GetAnimationLength(ZekeAnimation.Throw);
        self._rockThrownCDLeft = self._actionCDLeft - 1;
    }

    function RockBomb()
    {
        if (self._target == null)
        {
            return;
        }
        start = self._rock.Position;
        end = self._target.Position;
        direction = end - start;
        distance = direction.Magnitude;
        direction = direction.Normalized;
        start += 10 * direction.Normalized;
        end += 50 * direction.Normalized;

        effectRotation = Quaternion.LookRotation(direction).Euler;
        Game.SpawnEffect("Boom1", self._rock.Position, effectRotation, 5.0);

        result = Physics.LineCast(start, end, "All");
        if (result != null)
        {
            end = result.Point;
        }

        Game.SpawnEffect("Boom1", (self._rock.Position + end) * 0.7, effectRotation, 5.0);
        Game.SpawnEffect("Boom1", (self._rock.Position + end) * 0.3, effectRotation, 5.0);

        Game.SpawnEffect("Boom3", end, direction, 10.0);
        Game.SpawnEffect("Boom2", end, direction, 10.0);
	    Game.SpawnEffect("Boom7", end, direction, 15.0);

        result2 = Physics.LineCast(end, end + 10 * Vector3.Down, "MapObjects");
        if (result2 != null)
        {
            Game.SpawnEffect("GroundShatter", result2.Point + Vector3.Up * 0.1, Vector3.Zero, 10.0);
        }

        Game.SpawnProjectile("Rock1", end + Vector3(-10, 10, 0), Vector3.Zero, Random.RandomVector3(Vector3(-20,5,0), Vector3(0,10,20)).Normalized * 100, Vector3(0, -10000, 0), 10.0, "Shifter",5.0);
        Game.SpawnProjectile("Rock1", end + Vector3(10, 10, 0), Vector3.Zero, Random.RandomVector3(Vector3(0,5,-20), Vector3(20,10,0)).Normalized * 100, Vector3(0, -10000, 0), 10.0, "Shifter", 5.0);
        Game.SpawnProjectile("Rock1", end + Vector3(0, 10, -10), Vector3.Zero, Random.RandomVector3(Vector3(-20,5,-20), Vector3(0,10,0)).Normalized * 100, Vector3(0, -10000, 0), 10.0, "Shifter", 5.0);
        Game.SpawnProjectile("Rock1", end + Vector3(0, 10, 10), Vector3.Zero, Random.RandomVector3(Vector3(0,5,0), Vector3(20,10,20)).Normalized * 100, Vector3(0, -10000, 0), 10.0, "Shifter", 5.0);

        self._bombHitBox.MapObject.Scale = Vector3(20,20,20);
        self._bombHitBox.MapObject.Position = end;
        self._bombHitBox.Bomb(0.2);
    }

    function _UpdateActions(t)
    {
        self.FindTarget();
        if (self._target == null)
        {
            return;
        }
        direction = self._target.Position - self.MapObject.Position;
        direction.Y = 0;
        distance = direction.Magnitude;
        isMove = true;
        angle = Vector3.SignedAngle(direction, self.MapObject.Forward, Vector3.Right);

        if (distance > 50)
        {
            self.Move();
            isMove = true;

            if (self._throwCDLeft <= 0)
            {
                if (Random.RandomFloat(0,1) < 0.7)
                {
                    self.ThrowRock();
                }
                self._throwCDLeft = self.ThrowCooldown;
            }
        }
        elif (Math.Abs(angle) > 30)
        {
            if (angle > 0)
            {
                self.PlayAnimation(ZekeAnimation.TurnRight);
		        self._actionCDLeft = self.ActionCooldown;
                # self._actionCDLeft = self._transform.GetAnimationLength(ZekeAnimation.TurnRight);
            }
            else
            {
                self.PlayAnimation(ZekeAnimation.TurnLeft);
		        self._actionCDLeft = self.ActionCooldown;
                # self._actionCDLeft = self._transform.GetAnimationLength(ZekeAnimation.TurnLeft);
            }
            self._turnDirection = direction.Normalized;
        }
        else
        {
            self.Attack();
        }
        
        if (isMove)
        {
            self.MapObject.Forward = Vector3.Lerp(self.MapObject.Forward, direction.Normalized, self.RotateSpeed * t);   
        }
        else
        {
            velocity = self._rigidbody.GetVelocity();
            velocity.X = 0;
            velocity.Z = 0;
            self._rigidbody.SetVelocity(velocity);
        }
    }

    function GetDamaged(character, damage)
    {
        if (damage < self.Health)
        {
            self.Health -= damage;
        }
        elif (!self._dieOnce)
        {
            self._dieOnce = true;

            self.Health = 0;
            self._rigidbody=null;
            self.MapObject.SetComponentEnabled("Rigidbody", false);
            
            Game.ShowKillFeedAll(character.Name, self.DamageText, damage, character.Weapon);
            self._transform.Rotation = self._transform.Rotation + Vector3(10,0,0);
            self.WaitAndDie(self._actionCDLeft);
		    self._actionCDLeft = 2.5;
            self.PlayAnimation(ZekeAnimation.Die);
            
            if (self._onDieHandler != null)
            {
                self._onDieHandler.Handle(character, damage);
            }
        }
    }

    coroutine WaitAndDie(delay)
    {
        t = Game.SpawnTitanAt("normal",self._transform.Position+Vector3(0,-200,0));
		t.PlaySound("Roar");
		t.Health=0;

        Game.SpawnEffect("Blood1", self._transform.Position+Vector3(0,80,0), Vector3.Zero, 10.0);
        Game.SpawnEffect("Blood2", self._transform.Position+Vector3(0,80,0), Vector3.Zero, 10.0);
        wait 0.5;
        Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
        Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
        Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
        Game.SpawnEffect("TitanDie2", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
        Game.SpawnEffect("TitanDie2", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
        Game.SpawnEffect("TitanDie2", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);

        wait 1.4;
        Game.SpawnEffect("Boom7", self._transform.Position+Vector3(0,25,0), Vector3.Zero, 50.0);
        self.PlayAnimation(ZekeAnimation.Die3);
        wait 1.0;
        self._transform.Position =self._transform.Position+ Vector3(0,0,0);
	
        Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,12,0), Vector3.Zero, 15.0);
        Game.SpawnEffect("TitanDie2", self._transform.Position+Vector3(0,15,0), Vector3.Zero, 15.0);
        wait 1.5;
        Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,12,0), Vector3.Zero, 15.0);
        Game.SpawnEffect("TitanDie1", self._transform.Position+Vector3(0,12,0), Vector3.Zero, 15.0);
        self.MapObject.Active = false;
    }

    function PlayAnimation(animation)
    {
        self._transform.PlayAnimation(animation);
        self.NetworkView.SendMessageOthers("a" + animation);
    }

    function OnFrame()
    {
        if (
            !self._initizalized 
            || !self._enabled 
            || self.Health <= 0
        )
        {
            return;
        }

        if (self.NetworkView.Owner == Network.MyPlayer)
        {
            self._UpdateCD(Time.FrameTime);
            if (self._actionCDLeft <= 0)
            {
                self._UpdateActions(Time.FrameTime);
            }
    
            if (self._target != null && self._rockThrownCDLeft > 0)
            {
                direction = (self._target.Position - self.MapObject.Position);
                direction.Y = 0;
                direction = direction.Normalized;
                self.MapObject.Forward = Vector3.Lerp(self.MapObject.Forward, direction, self.RotateSpeed * Time.FrameTime);
            }
    
            if (self._turnDirection != null && self._actionCDLeft > 0)
            {
                if (self.MapObject.Forward != self._turnDirection)
                {
                    self.MapObject.Forward = Vector3.Lerp(self.MapObject.Forward, self._turnDirection, self.RotateSpeed * Time.FrameTime);
                }
                else
                {
                    self._turnDirection = null;
                }
            }
            else
            {
                self._turnDirection = null;
            }
        }

        if (self._actionCDLeft <= 0)
        {
            velocity = self._rigidbody.GetVelocity();
            velocity.Y = 0;
            if (velocity.Magnitude > 5)
            {
                self._transform.PlayAnimation(ZekeAnimation.Move, 0.2);
            }
            else
            {
                self._transform.PlayAnimation(ZekeAnimation.Idle, 0.2);
            }
        }

        self._rock.Transform.SetRenderersEnabled(self._rockThrownCDLeft > 0);
    }

    function OnSecond()
    {
        if (
            !self._initizalized 
            || !self._enabled 
            || self.NetworkView.Owner != Network.MyPlayer
            || self.Health <= 0
        )
        {
            return;
        }

        self._UpdateTypeSwitch(1.0);
    }

    function OnNetworkMessage(sender, message)
    {
        if (String.StartsWith(message, "a"))
        {
            self._transform.PlayAnimation(String.Substring(message, 1));
        }
        elif (String.StartsWith(message, "d"))
        {
            Split = String.Split(String.Substring(message, 1), " ");
            viewID = Convert.ToInt(Split.Get(0));
            damage = Convert.ToInt(Split.Get(1));
            character = Game.FindCharacterByViewID(viewID);
            self.GetDamaged(character, damage);
        }
    }

    function SendNetworkStream()
    {
        self.NetworkView.SendStream(self.Health);
        self.NetworkView.SendStream(self._actionCDLeft);
        self.NetworkView.SendStream(self._rockThrownCDLeft);
	    self.NetworkView.SendStream(self.MapObject.Active);
    }

    function OnNetworkStream()
    {
        self.Health = self.NetworkView.ReceiveStream();
        self._actionCDLeft = self.NetworkView.ReceiveStream();
        self._rockThrownCDLeft = self.NetworkView.ReceiveStream();
	    self.MapObject.Active = self.NetworkView.ReceiveStream();
    }

    function _AddNape()
    {
        neck = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/neck");
        napeNew = Map.CreateMapObjectRaw("Scene,Geometry/Sphere1,0,0,1,0," + self._hitBoxVisibility + ",0,NapeCollider,0,0,0,0,0,0,6,3,3,Region,Hitboxes,Default,Transparent|0/255/0/111|Misc/None|1/1|0/0,ZekeNapeHurtBox");
        napeNew.Parent = neck;
        self._napeHurtBox = napeNew.GetComponent("ZekeNapeHurtBox");
        self._napeHurtBox.SetShifter(self);

        napeNew.LocalPosition = Vector3(0,0,-0.09);
        napeNew.LocalRotation = Vector3.Zero;
        napeNew.Forward = neck.Forward;
    }

    function _AddHitBox()
    {
        self._armLeftTransform = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/shoulder.L/upper_arm.L/forearm.L/hand.L");
        armNew = Map.CreateMapObjectRaw("Scene,Geometry/Cube1,0,0,1,0," + self._hitBoxVisibility + ",0,ArmCollider,0,0,0,0,0,0,12,60,12,Region,Humans,Default,Transparent|255/0/0/111|Misc/None|1/1|0/0,ZekeHitBox");
        armNew.Parent = self._armLeftTransform;
        armNew.Forward = self._armLeftTransform.Forward;
        armNew.LocalPosition = Vector3.Zero;
        armNew.LocalRotation = Vector3.Zero;
        self._armLeftHitBox = armNew.GetComponent("ZekeHitBox");
        self._armLeftHitBox.SetShifter(self);
        self._armLeftHitBox.Damage = self.Damage;
        self._armLeftHitBox.DamageText = self.DamageText;

        self._armRightTransform = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/shoulder.R/upper_arm.R/forearm.R/hand.R");
        armNew = Map.CreateMapObjectRaw("Scene,Geometry/Cube1,0,0,1,0," + self._hitBoxVisibility + ",0,ArmCollider,0,0,0,0,0,0,12,60,12,Region,Humans,Default,Transparent|255/0/0/111|Misc/None|1/1|0/0,ZekeHitBox");
        armNew.Parent = self._armRightTransform;
        armNew.Forward = self._armRightTransform.Forward;
        armNew.LocalPosition = Vector3.Zero;
        armNew.LocalRotation = Vector3.Zero;
        self._armRightHitBox = armNew.GetComponent("ZekeHitBox");
        self._armRightHitBox.SetShifter(self);
        self._armRightHitBox.Damage = self.Damage;
        self._armRightHitBox.DamageText = self.DamageText;
    }

    function _AddRock()
    {
        self._rock = Map.CreateMapObjectRaw("Scene,Decor/Rubble1,0,0,1,0,1,0,Rock1,0,0,0,0,0,0,1,1,1,None,Humans,Default,DefaultNoTint|255/255/255/255,");
        self._rock.Parent = self._armRightTransform;
        self._rock.Forward = self._armRightTransform.Forward;
        self._rock.LocalPosition = Vector3(0,0.09,0.04);
        self._rock.LocalRotation = Vector3.Zero;
        self._bombHitBox = Map.CreateMapObjectRaw("Scene,Geometry/Sphere1,0,0,1,0," + self._hitBoxVisibility + ",0,Rock1HitBox,0,0,0,0,0,0,5,5,5,Region,Characters,Default,Transparent|255/0/0/111|Misc/None|1/1|0/0,ZekeBombHitBox").GetComponent("ZekeBombHitBox");
        self._bombHitBox.SetShifter(self);
        self._bombHitBox.Damage = self.Damage;
        self._bombHitBox.DamageText = self.DamageText;

    }

    function _RandomType()
    {
        return self._types.Get(
            Random.RandomInt(0, self._types.Count - 1)
        );
    }

    function _InitTypes()
    {
        self._typeSwitchCDLeft = self.TimeToTypeSwitch;

        if (
            !self.BeastTypeAssassinEnabled 
            && !self.BeastTypePitcherEnabled 
            && !self.BeastTypeWarriorEnabled
        )
        {
            self.BeastTypeAssassinEnabled = true;
            self.BeastTypePitcherEnabled = false;
            self.BeastTypeWarriorEnabled = false;
        }

        if (self.BeastTypeAssassinEnabled)
        {
            self._types.Add("Assassin");
        }
        if (self.BeastTypePitcherEnabled)
        {
            self._types.Add("Pitcher");
        }
        if (self.BeastTypeWarriorEnabled)
        {
            self._types.Add("Warrior");
        }
    }

    function _SwitchType(type)
    {
        if(type == "Pitcher")
        {
            ZekeAnimation.Move="Amarture_VER2|run.walk";
            self.MoveSpeed = 20;
            self.ThrowCooldown = 4;
            self.Health = 2000;
            self.ActionCooldown = 2;
        }
        elif(type == "Warrior")
        {
            ZekeAnimation.Move="Amarture_VER2|run.abnormal.1";
            self.MoveSpeed = 100;
            self.ThrowCooldown = 6;
            self.Health = 3000;
            self.ActionCooldown=1.5;
        }
        elif(type == "Assassin")
        {
            ZekeAnimation.Move="Amarture_VER2|run.abnormal.3";
            self.MoveSpeed = 120;
            self.ThrowCooldown = 8;
            self.Health = 2500;
            self.ActionCooldown = 1.0;
        }

        self._currentType = type;
    }

    function _UpdateCD(t)
    {
        if (self._actionCDLeft > 0)
        {
            self._actionCDLeft -= t;
        }
        if (self._attackCDLeft > 0)
        {
            self._attackCDLeft -= t;
        }
        if (self._rockThrownCDLeft > 0)
        {
            self._rockThrownCDLeft -= t;
            if (self._rockThrownCDLeft <= 0)
            {
                self.RockBomb();
            }
        }
        if (self._throwCDLeft > 0)
        {
            self._throwCDLeft -= t;
        }
    }

    function _UpdateTypeSwitch(t)
    {
        self._typeSwitchCDLeft -= t;

        if (self._typeSwitchCDLeft <= 0)
        {
            self._SwitchType(self._RandomType());
            offset = Random.RandomFloat(self.TimeToTypeSwitchRandomOffset * -1.0, self.TimeToTypeSwitchRandomOffset);
            self._typeSwitchCDLeft = self.TimeToTypeSwitch + offset;
        }
    }
}

component ZekeNapeHurtBox
{
    # @type ZekeShifter
    _shifter = null;
    _getDamagedCoolDown = 0.0;
    
    # @param shifter ZekeShifter
    function SetShifter(shifter)
    {
        self._shifter = shifter;
        return self;
    }

    function OnTick()
    {
        if (self._getDamagedCoolDown > 0)
        {
            self._getDamagedCoolDown -= Time.TickTime;
        }
    }

    function OnGetHit(character, name, damage, type, hitPosition)
    {
        if (self._getDamagedCoolDown > 0)
        {
            return;
        }
        self._shifter.NetworkView.SendMessage(self._shifter.NetworkView.Owner, "d" + character.ViewID + " " + Convert.ToInt(damage));
        self._getDamagedCoolDown = 0.02;
        if (character.IsMainCharacter)
        {
            Game.ShowKillScore(damage);
        }
    }

}

component ZekeHitBox
{
    Damage = 1000;
    DamageText = "Beast Titan";

    # @type ZekeShifter
    _shifter = null;
    
    function SetShifter(shifter)
    {
        self._shifter = shifter;
        return self;
    }

    function OnCollisionEnter(other)
    {
        if (self._shifter._attackCDLeft <= 0)
        {
            return;
        }
        if (other.Type != "Human")
        {
            return;
        }

        # @type Human
        human = other;

        human.GetDamaged(self.DamageText, self.Damage);
    }
}

component ZekeBombHitBox
{
    Damage = 1000;
    DamageText = "Beast Titan";

    # @type ZekeShifter
    _shifter = null;
    _bombCoolDown = 0.0;
    _hitTargets = Dict();
    
    function SetShifter(shifter)
    {
        self._shifter = shifter;
        return self;
    }

    function OnTick()
    {
        if (self._bombCoolDown > 0)
        {
            self._bombCoolDown -= Time.TickTime;
            if (self._bombCoolDown <= 0)
            {
                self._hitTargets.Clear();
                self.MapObject.Scale = Vector3.Zero;
                self.MapObject.LocalPosition = Vector3.Zero;
            }
        }
    }

    function OnCollisionStay(other)
    {
        if (self._bombCoolDown <= 0)
        {
            return;
        }
        if (other.Type != "Human")
        {
            return;
        }

        # @type Human
        human = other;

        if (self._hitTargets.Contains(human.ViewID))
        {
            return;
        }
        human.GetDamaged(self.DamageText, self.Damage);
        self._hitTargets.Set(human.ViewID, 0);
    }

    function Bomb(time)
    {
        self._bombCoolDown = time;
    }
}

extension ZekeAnimation
{
    Idle = "Amarture_VER2|idle";
    TurnLeft = "Amarture_VER2|turnaround.L";
    TurnRight = "Amarture_VER2|turnaround.R";
    Move = "Amarture_VER2|run.walk";
    Attack = "Amarture_VER2|attack.comboPunch";
    Die = "Amarture_VER2|die.front";
    Throw = "Amarture_VER2|attack.throw";
	Die3= "Amarture_VER2|crawler.die";
}
