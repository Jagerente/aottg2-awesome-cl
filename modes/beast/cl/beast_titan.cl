# @import builtin
# @import router
# @import timer
# @import enums
# @import hit_util_FX
component ZekeShifter
{
	Health = 4000;
	Armor = 0;

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

	_isNapeProtected = false;

	# @type MapObject
	_rock = null;

	# @type RigidbodyBuiltin
	_rigidbody = null;

	# @type Transform
	_transform = null;

	# @type ZekeNapeHurtBox
	_napeHurtBox = null;

	# @type MapObject
	_napeProtection = null;

	# @type ZekeEyesHurtBox
	_eyesHurtBox = null;

	# @type Transform
	_armLeftTransform = null;
	# @type Transform
	_armRightTransform = null;

	# @type Transform
	_handLeftTransform = null;
	# @type Transform
	_handRightTransform = null;

	# @type ZekeHitBox
	_armLeftHitBox = null;
	# @type ZekeHitBox
	_armRightHitBox = null;

	# @type ZekeHitBox
	_handLeftHitBox = null;
	# @type ZekeHitBox
	_handRightHitBox = null;

	# @type ZekeBombHitBox
	_bombHitBox = null;

	_onDieHandler = null;

	_hitBoxVisibility = "0";

	_initialized = false;
	_enabled = false;

	_types = List();
	_currentType = "";

	# @type Human
	_target = null;
	# @type Vector3
	_turnDirection = null;

	# @type Timer
	_throwCDLeft = null;
	# @type Timer
	_actionCDLeft = null;
	# @type Timer
	_attackCDLeft = null;
	# @type Timer
	_rockThrownCDLeft = null;
	# @type Timer
	_typeSwitchCDLeft = null;
	# @type Timer
	_blindCDLeft = null;
	# @type Timer
	_idleCDLeft = null;

	_dieOnce = false;

	# @type Router
	_router = null;

	# @type string
	_currentAnimation = null;

	_currentAnimationTime = 0.0;
	_currentAttackState = 0;

	function Initialize()
	{
		self._throwCDLeft = Timer(0.0);
		self._actionCDLeft = Timer(0.0);
		self._attackCDLeft = Timer(0.0);
		self._rockThrownCDLeft = Timer(0.0);
		self._typeSwitchCDLeft = Timer(0.0);
		self._blindCDLeft = Timer(0.0);
		self._idleCDLeft = Timer(0.0);

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

		self._router = Router();

		self._router.RegisterHandler(BeastPlayAnimationMessage.TOPIC, BeastPlayAnimationMessageHandler(self));
		self._router.RegisterHandler(BeastGetDamageMessage.TOPIC, BeastGetDamageMessageHandler(self));
		self._router.RegisterHandler(BeastBlindMessage.TOPIC, BeastBlindMessageHandler(self));

		self._initialized = true;
	}

	function RegisterOnDieHandler(handler)
	{
		self._onDieHandler = handler;
	}

	function Idle(t)
	{
		self._idleCDLeft.Reset(t);
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

	function Blind()
	{
		if (!self._blindCDLeft.IsDone())
		{
			return;
		}

		duration = self._transform.GetAnimationLength(BeastAnimationEnum.Blind);
		self._actionCDLeft.Reset(duration);
		self._blindCDLeft.Reset(duration);
		self.PlayAnimation(BeastAnimationEnum.Blind);
	}

	function Roar()
	{
		self.PlayAnimation(BeastAnimationEnum.EmoteRoar);
		self._actionCDLeft.Reset(self._transform.GetAnimationLength(BeastAnimationEnum.EmoteRoar));
	}

	function Attack()
	{
		self.PlayAnimation(BeastAnimationEnum.Attack);
		duration = self._transform.GetAnimationLength(BeastAnimationEnum.Attack);
		self._actionCDLeft.Reset(duration);
		self._attackCDLeft.Reset(duration);
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
		self.PlayAnimation(BeastAnimationEnum.Throw);
		duration = self._transform.GetAnimationLength(BeastAnimationEnum.Throw);
		self._actionCDLeft.Reset(duration);
		self._rockThrownCDLeft.Reset(duration - 1);
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

			if (self._throwCDLeft.IsDone())
			{
				if (Random.RandomFloat(0,1) < 0.7)
				{
					self.ThrowRock();
				}
				self._throwCDLeft.Reset(self.ThrowCooldown);
			}
		}
		else
		{
			attackChosen = self._ChooseCloseRangeAttack();
			if (!attackChosen && Math.Abs(angle) > 30)
			{
				if (angle > 0)
				{
					self.PlayAnimation(BeastAnimationEnum.TurnRight);
					self._actionCDLeft.Reset(self._transform.GetAnimationLength(BeastAnimationEnum.TurnRight));
				}
				else
				{
					self.PlayAnimation(BeastAnimationEnum.TurnLeft);
					self._actionCDLeft.Reset(self._transform.GetAnimationLength(BeastAnimationEnum.TurnLeft));
				}
				self._turnDirection = direction.Normalized;
			}
			elif (!attackChosen)
			{
				self.Attack();
			}
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

	# @return bool
	function _ChooseCloseRangeAttack()
	{
		targetPos = self._target.Position;
		eyesPos = self._eyesHurtBox.MapObject.Position;
		napePos = self._napeHurtBox.MapObject.Position;

		distanceToEyes = (targetPos - eyesPos).Magnitude;
		distanceToNape = (targetPos - napePos).Magnitude;

		if (distanceToEyes < 15)
		{
			directionToTarget = (targetPos - self.MapObject.Position).Normalized;
			angleToTarget = Vector3.Angle(directionToTarget, self.MapObject.Forward);

			if (angleToTarget >= 70 && angleToTarget <= 85)
			{
				self.SlapFace();
				return true;
			}
		}

		if (distanceToNape < 10)
		{
			directionToTarget = (targetPos - self.MapObject.Position).Normalized;
			angleToTarget = Vector3.Angle(directionToTarget, self.MapObject.Forward * -1);

			if (angleToTarget >= 80 && angleToTarget <= 95)
			{
				self.SlapBack();
				return true;
			}
		}

		return false;
	}

	function SlapFace()
	{
		self.PlayAnimation(BeastAnimationEnum.AttackSlapFace);
		duration = self._transform.GetAnimationLength(BeastAnimationEnum.AttackSlapFace);
		self._actionCDLeft.Reset(duration);
		self._attackCDLeft.Reset(duration);
	}

	function SlapBack()
	{
		self.PlayAnimation(BeastAnimationEnum.AttackSlapBack);
		duration = self._transform.GetAnimationLength(BeastAnimationEnum.AttackSlapBack);
		self._actionCDLeft.Reset(duration);
		self._attackCDLeft.Reset(duration);
	}

	function SetNapeProtected(state)
	{
		self._isNapeProtected = state;
	}

	function GetDamaged(character, damage)
	{
		Game.ShowKillFeedAll(character.Name, self.DamageText, damage, character.Weapon);

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

			self._transform.Rotation = self._transform.Rotation + Vector3(10,0,0);
			self.WaitAndDie(self._actionCDLeft.GetTime());
			self._actionCDLeft.Reset(2.5);
			self.PlayAnimation(BeastAnimationEnum.Die);

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
		self.PlayAnimation(BeastAnimationEnum.Die3);
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
		self._currentAnimation = animation;
		self._currentAnimationTime = 0.0;
		self._currentAttackState = 0;
		self._transform.PlayAnimation(animation);

		Dispatcher.CSendOthers(self, BeastPlayAnimationMessage.New(animation));
	}

	function OnFrame()
	{
		if (!self._initialized || !self._enabled || self.Health <= 0)
		{
			return;
		}

		if (self.NetworkView.Owner == Network.MyPlayer)
		{
			if (self._currentAnimation != null)
			{
				self._currentAnimationTime += Time.FrameTime;

				if (self._currentAnimation == BeastAnimationEnum.AttackSlapFace)
				{
					if (self._currentAttackState == 0 && self._currentAnimationTime > 1.68)
					{
						Game.SpawnEffect(
							EffectEnum.BOOM3,
							self._eyesHurtBox.MapObject.Position,
							Vector3(270.0, 0.0, 0.0),
							8.0
						);

						self._currentAttackState = 1;
					}
				}
				elif (self._currentAnimation == BeastAnimationEnum.AttackSlapBack)
				{
					if (self._currentAttackState == 0 && self._currentAnimationTime > 1.68)
					{
						Game.SpawnEffect(
							EffectEnum.BOOM3,
							self._napeHurtBox.MapObject.Position,
							Vector3(270.0, 0.0, 0.0),
							6.0
						);

						self._currentAttackState = 1;
					}
				}
			}

			self._UpdateCD(Time.FrameTime);
			if (!self._idleCDLeft.IsDone())
			{
				return;
			}

			if (self._actionCDLeft.IsDone())
			{
				self._currentAttackState = 0;
				self._currentAnimation = null;
				self._currentAnimationTime = 0.0;

				self._UpdateActions(Time.FrameTime);
			}

			if (self._target != null && !self._rockThrownCDLeft.IsDone())
			{
				direction = (self._target.Position - self.MapObject.Position);
				direction.Y = 0;
				direction = direction.Normalized;
				self.MapObject.Forward = Vector3.Lerp(self.MapObject.Forward, direction, self.RotateSpeed * Time.FrameTime);
			}

			if (self._turnDirection != null && !self._actionCDLeft.IsDone())
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

		if (self._actionCDLeft.IsDone())
		{
			velocity = self._rigidbody.GetVelocity();
			velocity.Y = 0;
			if (velocity.Magnitude > 5)
			{
				if (self._currentType == "Warrior")
				{
					moveAnimation = "Amarture_VER2|run.abnormal.1";
				}
				elif (self._currentType == "Assassin")
				{
					moveAnimation = "Amarture_VER2|run.abnormal.3";
				}
				else
				{
					moveAnimation = "Amarture_VER2|run.walk";
				}

				self._transform.PlayAnimation(moveAnimation, 0.2);
			}
			else
			{
				self._transform.PlayAnimation(BeastAnimationEnum.Idle, 0.2);
			}
		}

		self._rock.Transform.SetRenderersEnabled(!self._rockThrownCDLeft.IsDone());
	}

	function OnSecond()
	{
		if (!self._initialized || !self._enabled || self.Health <= 0)
		{
			return;
		}

		self._napeProtection.Active = self._isNapeProtected;

		if (self.NetworkView.Owner != Network.MyPlayer)
		{
			return;
		}

		self._UpdateTypeSwitch(1.0);
	}

	function OnNetworkMessage(sender, message)
	{
		self._router.Route(sender, message);
	}

	function SendNetworkStream()
	{
		self.NetworkView.SendStream(self.Health);
		self.NetworkView.SendStream(self._actionCDLeft.GetTime());
		self.NetworkView.SendStream(self._rockThrownCDLeft.GetTime());
		self.NetworkView.SendStream(self.MapObject.Active);
		self.NetworkView.SendStream(self._currentType);
		self.NetworkView.SendStream(self._isNapeProtected);
	}

	function OnNetworkStream()
	{
		self.Health = self.NetworkView.ReceiveStream();
		self._actionCDLeft.Reset(self.NetworkView.ReceiveStream());
		self._rockThrownCDLeft.Reset(self.NetworkView.ReceiveStream());
		self.MapObject.Active = self.NetworkView.ReceiveStream();
		self._currentType = self.NetworkView.ReceiveStream();
		self._isNapeProtected = self.NetworkView.ReceiveStream();
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

		head = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/neck/head");
		eyesHurtBox = Map.CreateMapObjectRaw("Scene,Geometry/Sphere1,0,0,1,0," + self._hitBoxVisibility + ",0,EyesCollider,0,0,0,0,0,0,6,3,3,Region,Hitboxes,Default,Transparent|0/0/255/111|Misc/None|1/1|0/0,ZekeEyesHurtBox");
		eyesHurtBox.Parent = head;
		self._eyesHurtBox = eyesHurtBox.GetComponent("ZekeEyesHurtBox");
		self._eyesHurtBox.SetShifter(self);

		eyesHurtBox.Forward = head.Forward;
		eyesHurtBox.LocalPosition = Vector3.Zero + Vector3(0, 0.1, 0.1);

		self._napeProtection = Map.CreateMapObjectRaw("Scene,Nature/Boulder8,0,0,0,1,1,0,Boulder8,-9.484284,-117.1338,-303.9696,0,0,0,1.743053,4.320319,1.898688,Physical,Entities,Default,Basic|200/200/200/255|Misc/Crystal3|1/1|0/0");
		self._napeProtection.Parent = neck;
		self._napeProtection.LocalPosition = Vector3(0, -0.065, -0.07);
		self._napeProtection.LocalRotation = Vector3(0.034, 0.018, 0);
		self._napeProtection.Forward = neck.Forward;
		self._napeProtection.Active = false;
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

		self._handLeftTransform = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/shoulder.L/upper_arm.L/forearm.L/hand.L");
		handNew = Map.CreateMapObjectRaw("Scene,Geometry/Cube1,0,0,1,0," + self._hitBoxVisibility + ",0,ArmCollider,0,0,0,0,0,0,20,20,20,Region,Humans,Default,Transparent|255/100/100/111|Misc/None|1/1|0/0,ZekeHitBox");
		handNew.Parent = self._handLeftTransform;
		handNew.Forward = self._handLeftTransform.Forward;
		handNew.LocalPosition = Vector3(0,0.1,0.1);
		handNew.LocalRotation = Vector3.Zero;
		self._handLeftHitBox = handNew.GetComponent("ZekeHitBox");
		self._handLeftHitBox.SetShifter(self);
		self._handLeftHitBox.Damage = self.Damage;
		self._handLeftHitBox.DamageText = self.DamageText;

		self._handRightTransform = self.MapObject.Transform.GetTransform("Amarture_VER2/Core/Controller.Body/hip/spine/chest/shoulder.R/upper_arm.R/forearm.R/hand.R");
		handNew = Map.CreateMapObjectRaw("Scene,Geometry/Cube1,0,0,1,0," + self._hitBoxVisibility + ",0,ArmCollider,0,0,0,0,0,0,20,20,20,Region,Humans,Default,Transparent|255/100/100/111|Misc/None|1/1|0/0,ZekeHitBox");
		handNew.Parent = self._handRightTransform;
		handNew.Forward = self._handRightTransform.Forward;
		handNew.LocalPosition = Vector3(0,0.1,0.1);
		handNew.LocalRotation = Vector3.Zero;
		self._handRightHitBox = handNew.GetComponent("ZekeHitBox");
		self._handRightHitBox.SetShifter(self);
		self._handRightHitBox.Damage = self.Damage;
		self._handRightHitBox.DamageText = self.DamageText;
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
		self._rock.Transform.SetRenderersEnabled(false);
	}

	function _RandomType()
	{
		return self._types.Get(
			Random.RandomInt(0, self._types.Count - 1)
		);
	}

	function _InitTypes()
	{
		self._typeSwitchCDLeft.Reset(self.TimeToTypeSwitch);

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
			BeastAnimationEnum.Move="Amarture_VER2|run.walk";
			self.MoveSpeed = 20;
			self.ThrowCooldown = 4;
			self.ActionCooldown = 2;
		}
		elif(type == "Warrior")
		{
			BeastAnimationEnum.Move="Amarture_VER2|run.abnormal.1";
			self.MoveSpeed = 100;
			self.ThrowCooldown = 6;
			self.ActionCooldown=1.5;
		}
		elif(type == "Assassin")
		{
			BeastAnimationEnum.Move="Amarture_VER2|run.abnormal.3";
			self.MoveSpeed = 120;
			self.ThrowCooldown = 8;
			self.ActionCooldown = 1.0;
		}

		self._currentType = type;
	}

	function _UpdateCD(t)
	{
		self._actionCDLeft.UpdateOn(t);
		self._attackCDLeft.UpdateOn(t);

		if (!self._rockThrownCDLeft.IsDone())
		{
			self._rockThrownCDLeft.UpdateOn(t);
			if (self._rockThrownCDLeft.IsDone())
			{
				self.RockBomb();
			}
		}

		self._throwCDLeft.UpdateOn(t);
		self._blindCDLeft.UpdateOn(t);
		self._idleCDLeft.UpdateOn(t);
	}

	function _UpdateTypeSwitch(t)
	{
		self._typeSwitchCDLeft.UpdateOn(t);

		if (self._typeSwitchCDLeft.IsDone())
		{
			self._SwitchType(self._RandomType());
			offset = Random.RandomFloat(self.TimeToTypeSwitchRandomOffset * -1.0, self.TimeToTypeSwitchRandomOffset);
			self._typeSwitchCDLeft.Reset(self.TimeToTypeSwitch + offset);
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

	# @param character Human
	function OnGetHit(character, name, damage, type, hitPosition)
	{
		if (self._getDamagedCoolDown > 0 || !character.IsMainCharacter)
		{
			return;
		}

		self._getDamagedCoolDown = 0.02;

		if (self._shifter._isNapeProtected && character.Weapon == WeaponEnum.BLADES)
		{
			character.CurrentBladeDurability = 0;
			character.PlaySound(PlayerSoundEnum.BLADEBREAK);
			return;
		}

		self._HandleDamageFX(character, damage, type);

		Dispatcher.CSend(self._shifter, self._shifter.NetworkView.Owner, BeastGetDamageMessage.New(character.ViewID, Convert.ToInt(damage)));
		Game.ShowKillScore(damage);
	}
	
	# @param human Human
	# @param damage int
	# @param type string
	function _HandleDamageFX(human, damage, type)
	{
		HitUtilsFX.DamageHitSoundFX(human, damage, type, self._shifter.Armor);
		HitUtilsFX.DamageVisualFX(self.MapObject.Position, damage, self._shifter.Armor);
	}
}

component ZekeEyesHurtBox
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

	# @param character Human
	function OnGetHit(character, name, damage, type, hitPosition)
	{
		if (self._getDamagedCoolDown > 0 || !character.IsMainCharacter)
		{
			return;
		}
		
		self._HandleDamageFX(character, damage, type);

		Dispatcher.CSend(self._shifter, self._shifter.NetworkView.Owner, BeastBlindMessage.New());

		self._getDamagedCoolDown = 5.0;
	}

	# @param human Human
	# @param damage int
	# @param type string
	function _HandleDamageFX(human, damage, type)
	{
		HitUtilsFX.DamageHitSoundFX(human, damage, type, self._shifter.Armor);
		HitUtilsFX.DamageVisualFX(self.MapObject.Position, damage, self._shifter.Armor);
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
		if (self._shifter._attackCDLeft.IsDone())
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

extension BeastAnimationEnum
{
	Idle = "Amarture_VER2|idle";
	Move = "Amarture_VER2|run.walk";
	TurnLeft = "Amarture_VER2|turnaround.L";
	TurnRight = "Amarture_VER2|turnaround.R";

	Jump = "Amarture_VER2|attack.jumper.0";
	Fall = "Amarture_VER2|attack.jumper.1";
	Land = "Amarture_VER2|attack.jumper.2";

	SitIdle = "Amarture_VER2|sit_idle";
	SitDown = "Amarture_VER2|sit_down";
	SitUp = "Amarture_VER2|sit_getup";
	SitFall = "Amarture_VER2|sit_hunt_down";
	SitBlind = "Amarture_VER2|sit_hit_eye";

	Stun = "Amarture_VER2|hit.eren.L";
	StunRight = "Amarture_VER2|hit.eren.R";

	Die = "Amarture_VER2|die.front";
	DieBack = "Amarture_VER2|die.back";
	DieGround = "Amarture_VER2|die.ground";
	DieSit = "Amarture_VER2|sit_die";
	Die3 = "Amarture_VER2|crawler.die";

	Throw = "Amarture_VER2|attack.throw";
	Attack = "Amarture_VER2|attack.comboPunch";
	AttackCombo = "Amarture_VER2|attack.combo";
	AttackSlam = "Amarture_VER2|attack.front.ground";
	AttackKick = "Amarture_VER2|attack.kick";
	AttackStomp = "Amarture_VER2|attack.stomp";
	AttackSwingL = "Amarture_VER2|attack.swing.l";
	AttackSwingR = "Amarture_VER2|attack.swing.r";
	AttackBiteF = "Amarture_VER2|bite";
	AttackSlapFace = "Amarture_VER2|attack.slap.face";
	AttackSlapBack = "Amarture_VER2|attack.slap.back";
	AttackRoar = "Amarture_VER2|attack.scream";
	AttackGrabCoreL = "Amarture_VER2|grab.core.L";
	AttackGrabCoreR = "Amarture_VER2|grab.core.R";

	CoverNape = "Amarture_VER2|idle.recovery";
	Blind = "Amarture_VER2|hit.eye";

	EmoteLaugh = "Amarture_VER2|laugh";
	EmoteNod = "Amarture_VER2|emote_titan_yes";
	EmoteShake = "Amarture_VER2|emote_titan_no";
	EmoteRoar = "Amarture_VER2|attack.scream";
}

extension BeastPlayAnimationMessage
{
	TOPIC = "beast.play_animation";

	KEY_ANIMATION = "animation";

	function New(animation)
	{
		msg = Dict();
		msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
		msg.Set(self.KEY_ANIMATION, animation);
		return msg;
	}
}

class BeastPlayAnimationMessageHandler
{
	# @type ZekeShifter
	_beast = null;

	# @param beast ZekeShifter
	function Init(beast)
	{
		self._beast = beast;
	}

	function Handle(sender, msg)
	{
		animation = msg.Get(BeastPlayAnimationMessage.KEY_ANIMATION);

		self._beast._transform.PlayAnimation(animation);
	}
}

extension BeastGetDamageMessage
{
	TOPIC = "beast.get_damage";

	KEY_VIEW_ID = "view_id";
	KEY_DAMAGE = "damage";

	function New(viewID, damage)
	{
		msg = Dict();
		msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
		msg.Set(self.KEY_VIEW_ID, viewID);
		msg.Set(self.KEY_DAMAGE, damage);
		return msg;
	}
}

class BeastGetDamageMessageHandler
{
	# @type ZekeShifter
	_beast = null;

	# @param beast ZekeShifter
	function Init(beast)
	{
		self._beast = beast;
	}

	function Handle(sender, msg)
	{
		viewID = msg.Get(BeastGetDamageMessage.KEY_VIEW_ID);
		damage = msg.Get(BeastGetDamageMessage.KEY_DAMAGE);
		character = Game.FindCharacterByViewID(viewID);

		self._beast.GetDamaged(character, damage);
	}
}

extension BeastBlindMessage
{
	TOPIC = "beast.blind";

	function New()
	{
		msg = Dict();
		msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
		return msg;
	}
}

class BeastBlindMessageHandler
{
	# @type ZekeShifter
	_beast = null;

	# @param beast ZekeShifter
	function Init(beast)
	{
		self._beast = beast;
	}

	function Handle(sender, msg)
	{
		self._beast.Blind();
	}
}
