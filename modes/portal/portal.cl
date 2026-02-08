class Main {
    RespawnTime = 3.0;

    QualityLevel = 2;

    FOV = 90.0;

    GodMode = false;

    CustomSpeed = 55;
    CustomDodgeSpeed = 55;

    BunnyHop = true;

    AirMovementPreset = "Portal";
    AirMovementPresetDropbox = "Portal, Custom, None";
    AirMovementForceMultiplier = 3000;
    GravityMultiplier = 0;
    MaxAirSpeed = 1500;
    AirMovementForceType = "Force";
    AirMovementForceTypeDropbox = "Force, Impulse";
    
    SpringFactor = 500.0;
    DampingFactor = 25.0;

    _respawnTimer = Timer(0.0);
    _maxQualityLevel = 2;

    #######################
    ## CALLBACKS
    #######################
    function OnGameStart()
    {
        InputManager.InitKeybinds();
        I18n.RegisterLanguagePack(EnglishLanguagePack());
        I18n.RegisterLanguagePack(ChineseLanguagePack(0));
        I18n.RegisterLanguagePack(ChineseLanguagePack(1));
        I18n.RegisterLanguagePack(RussianLanguagePack());

        self._InitRouter();
        self._InitObjectPool();
        SoundManager.Initialize();

        ScoreboardManager.Initialize();

        self._respawnTimer = Timer(0.0);

        if (Network.IsMasterClient || String.Contains(Network.MyPlayer.Guild, "Aperture Science"))
        {
            Network.MyPlayer.SetCustomProperty("TELEPORT_ACCESS", 1);
            PlayerProxy.SetIsApertureScienceEmployee(true);
        } elif (Network.MyPlayer.GetCustomProperty("TELEPORT_ACCESS") == null)
        {
            Network.MyPlayer.SetCustomProperty("TELEPORT_ACCESS", 0);
        }

        SpeedRunManager.Initialize();

        PortalStorage.Initialize();

        TeleportGUI.Initialize();
        AdminPanelGUI.Initialize();
        SpeedRunGUI.Initialize();
    }

    function OnNetworkMessage(sender, message)
    {
        Router.Route(sender, message);
    }

    function OnCharacterSpawn(character)
    {
        if (character.Type != "Human")
        {
            return;
        }

        if (!character.IsAI && character.IsMine)
        {
            PortalStorage.Add(character.Player.ID);
        }
        if (character.IsMine)
        {
            InputManager.OnSpawn();
            PlayerProxy.OnSpawn();
        }
    }

    function OnCharacterDie(victim, killer, killerName)
    {
        if (!victim.IsAI && victim.IsMine)
        {
            PortalStorage.Remove(victim.Player.ID);
        }

        if (victim.IsMine)
        {
            InputManager.OnDie();
            PlayerProxy.OnDie();
            self._respawnTimer.Reset(self.RespawnTime);
            ResetManager.ResetAll();
            CutsceneManager.ResetAll();
        }
    }

    function OnSecond()
    {
        PlayerProxy.OnSecond();

        UIManager.OnSecond();
    }

    function OnTick()
    {
        CutsceneManager.OnTick();

        PlayerProxy.OnTick();

        if (Network.MyPlayer.Status == PlayerStatusEnum.Dead)
        {
            self._respawnTimer.UpdateOnTick();
            if (!self._respawnTimer.IsDone())
            {
                UI.SetLabelForTime(UILabelEnum.MiddleCenter, HTML.Color("Respawn in " + self._respawnTimer.String(2), ColorEnum.PastelOrange), 0.1);
            }
            else
            {
                Game.SpawnPlayer(Network.MyPlayer, false);
            }
        }

        SpeedRunManager.OnTick();

        UIManager.OnTick();
    }

    function OnFrame()
    {
        PlayerProxy.OnFrame();
        self._HandleInput();
    }

    function OnButtonClick(btn)
    {
        UIRouter.OnButtonClick(btn);
    }

    function _InitRouter()
    {
        Router.RegisterHandler(TeleportAccessMessage.TOPIC, TeleportAccessMessageHandler());
        # Router.RegisterHandler(SpeedRunResultsMessage.TOPIC, SpeedRunResultsMessageHandler());
    }

    function _InitObjectPool()
    {
        # laserTemplate = Map.FindMapObjectByName("Laser");
        # ObjectPoolManager.CreatePool(ObjectPoolManager.LASER, laserTemplate, self._maxLasers);
        # laserTemplate = Map.FindMapObjectByName("TurretLaser");
        # ObjectPoolManager.CreatePool(ObjectPoolManager.TURRET_LASER, laserTemplate, self._maxLasers);

        ObjectPoolManager.CreatePool(ObjectPoolManager.HARD_LIGHT_BRIDGE, CommonBuilder(Map.FindMapObjectByName("HardLightBridge")), 20);
        ObjectPoolManager.CreatePool(ObjectPoolManager.PORTALGUN_PROJECTILE, CommonBuilder(Map.FindMapObjectByName("PortalGunProjectile")), 5);
        ObjectPoolManager.CreatePool(ObjectPoolManager.PORTAL_GUN, CommonBuilder(Map.FindMapObjectByName("PortalGunObj")), 1);
    }

    function _HandleInput()
    {
        if (Input.GetKeyDown(InputManager.QualityPreset))
        {
            self.QualityLevel += 1;
            if (self.QualityLevel > self._maxQualityLevel)
            {
                self.QualityLevel = 0;
            }
        }
        elif (Input.GetKeyDown(InputManager.AdminPanelGUI))
        {
            if (!Network.IsMasterClient){return;}
            AdminPanelGUI.ShowUI();
        }
    }
}

#######################
# COMPONENTS
#######################

#######################
## Builtin
#######################

component IRigidbody
{
    Mass = 1.0;
    Gravity = Vector3(0.0, -20.0, 0.0);
    FreezeRotation = false;
    Interpolate = false;

    function Init(){}

    # @param velocity Vector3
    function SetVelocity(velocity){}

    # @param force Vector3
    function AddForce(force){}

    # @param force Vector3
    # @param mode string
    function AddForceWithMode(force, mode){}

    # @param force Vector3
    # @param point Vector3
    # @param mode string
    function AddForceWithModeAtPoint(force, point, mode){}

    # @param force Vector3
    # @param mode string
    function AddTorque(force, mode){}

    # @return Vector3
    function GetVelocity(){}

    # @return Vector3
    function GetAngularVelocity(){}
}

#######################
## BUTTONS
#######################

component Activatable
{
    Active = false;
    ResetGroup = "";
    _active = false;
    _once = false;

    function Initialize()
    {
        self._active = self.Active;

        if (!self._once && self.ResetGroup != "")
        {
            ResetManager.Add(self.ResetGroup, self);
            self._once = true;
        }
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function Activate()
    {
        self._active = true;
    }

    function Deactivate()
    {
        self._active = false;
    }

    function Toggle()
    {
        self._active = !self._active;
    }

    # @return bool
    function IsActive()
    {
        return self._active;
    }

    function Reset()
    {
        self.Initialize();
    }

    function OnDeactivate()
    {
        self.Reset();
    }
}

class DeactivatableCallback
{
    function OnDeactivate(){}
}

component ActiveControl
{
    ActivatableID = 0;
    QualityLevel = 0;
    Reverse = false;

    # @type Activatable
    _activatable = null;
    _activated = false;
    # @type List<string>
    _deactivatableList = List();

    function Initialize()
    {
        if (self.ActivatableID > 0)
        {
            obj = Map.FindMapObjectByID(self.ActivatableID);
            self._activatable = obj.GetComponent("Activatable");
            if (obj == null)
            {
                MCLogger.Error(
                    "Object ID: " + self.MapObject.ID
                    + String.Newline
                    + "Object Name: " + self.MapObject.Name
                    + "Failed to find Activatable with ID: " + self.ActivatableID
                );
            }
        }

        self._deactivatableList.Add("Activatable");
        self._deactivatableList.Add("CubeDispencer");
        self._deactivatableList.Add("WeightedButton");

        isActive = self._activatable == null || (self._activatable.IsActive() != self.Reverse);
        self.MapObject.Active = isActive;
        if (!isActive || self.QualityLevel > Main.QualityLevel)
        {
            self._Deactivate();
        }

        self._activated = isActive;
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function OnTick()
    {
        isActive = self._activatable == null || (self._activatable.IsActive() != self.Reverse);
        newActivated = isActive && Main.QualityLevel >= self.QualityLevel;
        if (self._activated == newActivated)
        {
            return;
        }

        self._activated = newActivated;

        self.MapObject.Active = self._activated;
        if (!self._activated)
        {
            self._Deactivate();
        }
        else
        {
            self._Activate();
        }
    }

    function _Activate()
    {
        self.MapObject.SetComponentsEnabled(true);
    }

    function _Deactivate()
    {
        self.MapObject.SetComponentsEnabled(false);
        self.MapObject.SetComponentEnabled("ActiveControl", true);

        for (k in self._deactivatableList)
        {
            # @type DeactivatableCallback
            comp = self.MapObject.GetComponent(k);
            if (comp != null)
            {
                comp.OnDeactivate();
            }
        }
    }
}

component WeightedButton
{
    ActivatableID = 0;
    # @type Activatable
    _activatable = null;
    _wasSoundPlayed = false;
    _deactivationTimer = Timer(0.0);
    _isActive = false;

    function Initialize()
    {
        if (self.ActivatableID != 0)
        {
            self._activatable = Map.FindMapObjectByID(self.ActivatableID).GetComponent("Activatable");
        }
        else
        {
            self._activatable = self.MapObject.GetComponent("Activatable");
        }
        self._deactivationTimer = Timer(0.0);
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    # @param obj any
    function OnCollisionStay(obj)
    {
        if ((obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine) ||
            (obj.Type == ObjectTypeEnum.MAP_OBJECT &&
            (
                obj.Name == "WeightedStorageCube"
                || obj.Name == "WeightedCompanionCube"
                || obj.Name == "DiscouragementRedirectionCube"
            )))
        {
            if (!self._isActive)
            {
                self._activatable.Activate();
                self._isActive = true;

                if (!self._wasSoundPlayed)
                {
                    SoundManager.Play(HumanSoundEnum.Checkpoint);
                    self._wasSoundPlayed = true;
                }
            }
            self._deactivationTimer.Reset(0.15);
        }
    }

    # @param obj any
    function OnCollisionExit(obj)
    {
        if ((obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine) ||
            (obj.Type == ObjectTypeEnum.MAP_OBJECT &&
            (
                obj.Name == "WeightedStorageCube"
                || obj.Name == "WeightedCompanionCube"
                || obj.Name == "DiscouragementRedirectionCube"
            )))
        {
            self._deactivationTimer.Reset(0.15);
        }
    }

    function OnTick()
    {
        self._deactivationTimer.UpdateOnTick();

        if (self._deactivationTimer.IsDone() && self._isActive)
        {
            self._activatable.Deactivate();
            self._isActive = false;

            if (self._wasSoundPlayed)
            {
                SoundManager.Play(HumanSoundEnum.Checkpoint);
                self._wasSoundPlayed = false;
            }
        }
    }

    function IsActive()
    {
        return self._activatable.IsActive();
    }

    function OnDeactivate()
    {
        self._activatable.OnDeactivate();
    }
}

component RegionButton
{
    DeactivateDelay = 0.0;
    Reverse = false;
    MyHuman = true;
    MyCamera = false;
    ResetGroup = "";
    MapObjects = "";
    Components = "";
    Once = false;
    _once = false;
    _activateOnce = false;
    # @type Activatable
    _activatable = null;
    _moDict = Dict();
    _cDict = Dict();
    # @type Timer
    _timer = null;

    function Initialize()
    {
        self._timer = Timer(0.0);

        self._activatable = self.MapObject.GetComponent("Activatable");
        if (self.MapObjects != "")
        {
            for (n in String.Split(self.MapObjects, "_"))
            {
                self._moDict.Set(n, true);
            }
        }

        if (self.Components != "")
        {
            for (n in String.Split(self.Components, "_"))
            {
                self._cDict.Set(n, true);
            }
        }

        if (!self._once && self.ResetGroup != "")
        {
            ResetManager.Add(self.ResetGroup, self);
            self._once = true;
        }
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    # @param obj any
    function OnCollisionEnter(obj)
    {
        if (self.Once && !self._activateOnce && self.MyHuman && obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            self._activatable.Activate();
            self._timer.Reset(self.DeactivateDelay);
            self._activateOnce = true;
        }
    }

    # @param obj any
    function OnCollisionStay(obj)
    {
        if (self.Once){return;}

        if (obj.Type == ObjectTypeEnum.HUMAN)
        {
            if (!obj.IsMine || !self.MyHuman)
            {
                return;
            }
            else
            {
                self._timer.Reset(self.DeactivateDelay + 0.25);
                return;
            }
        }

        if (obj.Type != ObjectTypeEnum.MAP_OBJECT)
        {
            return;
        }

        mapObject = obj;

        if (self.MapObjects != "" && self._moDict.Contains(mapObject.Name))
        {
            self._timer.Reset(self.DeactivateDelay + 0.25);
            return;
        }

        if (self.Components != "")
        {
            for (k in self._cDict.Keys)
            {
                if (mapObject.GetComponent(k) != null)
                {
                    self._timer.Reset(self.DeactivateDelay + 0.25);
                    return;
                }
            }
        }
    }

    # @param obj any
    function OnCollisionExit(obj)
    {
        if (self.Once){return;}

        if (obj.Type == ObjectTypeEnum.HUMAN)
        {
            if (!obj.IsMine || !self.MyHuman)
            {
                return;
            }
            else
            {
                self._timer.Reset(self.DeactivateDelay);
                return;
            }
        }
        if (obj.Type != ObjectTypeEnum.MAP_OBJECT)
        {
            return;
        }

        # @type MapObject
        mapObject = obj;

        if (self.MapObjects != "" && self._moDict.Contains(mapObject.Name))
        {
            self._timer.Reset(self.DeactivateDelay);
            return;
        }

        if (self.Components != "")
        {
            for (k in self._cDict.Keys)
            {
                if (mapObject.GetComponent(k) != null)
                {
                    self._timer.Reset(self.DeactivateDelay);
                    return;
                }
            }
        }
    }

    function OnSecond()
    {
        if (self.MyCamera && self.MapObject.InBounds(Camera.Position))
        {
            self._timer.Reset(self.DeactivateDelay + 1.15);
        }
    }

    function OnTick()
    {
        self._timer.UpdateOnTick();
        if (self.Once){
            if (self._activatable.IsActive() && self.DeactivateDelay > 0.0)
            {
                if (self._timer.IsDone())
                {
                    self._activatable.Deactivate();
                }
            }
            return;
        }

        if (self._timer.IsDone())
        {
            if (self.Reverse)
            {
                self._activatable.Activate();
            }
            else
            {
                self._activatable.Deactivate();
            }
        }
        else
        {
            if (self.Reverse)
            {
                self._activatable.Deactivate();
            }
            else
            {
                self._activatable.Activate();
            }
        }
    }

    function IsActive()
    {
        return self._activatable.IsActive();
    }

    function Reset()
    {
        self._activateOnce = false;
        self._timer.Reset(0.0);
    }
}

component Button
{
    ActivatableID = 0;
    ActivatableIDTooltip = "Leave 0 to use the Activatable component from the same object.";

    GroupID = "";
    GroupIDTooltip = "Buttons in the same group cannot all be active simultaneously. Activating one will deactivate the others.";

    ActiveTime = -1.0;
    ActiveTimeTooltip = "The duration (in seconds) the button remains active before deactivating. If less than or equal to 0, it will not deactivate automatically.";

    CD = -1.0;
    CDTooltip = "The cooldown duration (in seconds) before the button can be activated again. If less than or equal to 0, it will not have a cooldown. This should typically be equal to or greater than ActiveTime.";

    # @type Timer
    _cdTimer = Timer(0.0);
    # @type Timer
    _timer = Timer(0.0);
    # @type Activatable
    _activatable = null;

    function Initialize()
    {
        self._cdTimer = Timer(0.0);
        self._timer = Timer(0.0);

        if (self.ActivatableID == 0 || self.ActivatableID == self.MapObject.ID)
        {
            self._activatable = self.MapObject.GetComponent("Activatable");
        }
        else
        {
            self._activatable = Map.FindMapObjectByID(self.ActivatableID).GetComponent("Activatable");
        }

        if (self.GroupID != "")
        {
            ButtonGroupStorage.Add(self.GroupID, self);
        }
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function OnTick()
    {
        if (self.ActiveTime <= 0)
        {
            return;
        }

        self._cdTimer.UpdateOnTick();
        self._timer.UpdateOnTick();
        if (self._timer.IsDone())
        {
            self._activatable.Deactivate();
        }
    }

    function Activate()
    {
        if (self.IsActive() || !self._cdTimer.IsDone())
        {
            return;
        }

        if (self.GroupID != "")
        {
            for (a in ButtonGroupStorage.GetList(self.GroupID))
            {
                if (a != self)
                {
                    a.Deactivate();
                }
            }
        }

        self._activatable.Activate();
        SoundManager.Play(HumanSoundEnum.Checkpoint);

        self._timer.Reset(self.ActiveTime);
        self._cdTimer.Reset(self.CD);
    }

    function Deactivate()
    {
        self._activatable.Deactivate();
    }

    function IsActive()
    {
        return self._activatable.IsActive();
    }
}

component MultiButton
{
    ButtonIDs = "";
    Any = false;
    # @type Activatable
    _activatable = null;
    # @type List<Activatable>
    _activatablesRefs = List();

    function OnGameStart()
    {
        self._activatable = self.MapObject.GetComponent("Activatable");
        for (id in String.Split(self.ButtonIDs, "_"))
        {
            obj = Map.FindMapObjectByID(Convert.ToInt(id));
            activatable = obj.GetComponent("Activatable");
            self._activatablesRefs.Add(activatable);
        }
    }

    function OnTick()
    {
        count = 0;
        for (a in self._activatablesRefs)
        {
            if (a.IsActive())
            {
                count += 1;
            }
        }

        if (count >= self._activatablesRefs.Count || (self.Any && count > 0))
        {
            self._activatable.Activate();
        }
        else
        {
            self._activatable.Deactivate();
        }
    }

    function IsActive()
    {
        return self._activatable.IsActive();
    }
}

#######################
## MISC
#######################

component SoundPlayer
{
    ActivatableID = 0;
    ActivateSound = "";
    DeactivateSound = "";
    # @type Activatable
    _activatable = null;
    _activated = false;

    function Initialize()
    {
        obj = Map.FindMapObjectByID(self.ActivatableID);
        if (obj != null)
        {
            self._activatable = obj.GetComponent("Activatable");
        }
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function OnTick()
    {
        if (self._activatable == null)
        {
            return;
        }

        if (self._activatable.IsActive())
        {
            if (!self._activated)
            {
                self._activated = true;
                if (self.ActivateSound != "")
                {
                    SoundManager.Play(self.ActivateSound);
                }
            }
        }
        else
        {
            if (self._activated)
            {
                self._activated = false;
                if (self.DeactivateSound != "")
                {
                    SoundManager.Play(self.DeactivateSound);
                }
            }
        }
    }
}

component CutscenePlayer
{
    CutsceneID = "";
    Full = false;

    # @type any
    function OnCollisionEnter(obj)
    {
        if (!CutsceneManager.GetCanPlay(self.CutsceneID))
        {
            return;
        }

        if (obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            CutsceneManager.Start(self.CutsceneID, self.Full);
        }
    }

    # @type any
    function OnCollisionStay(obj)
    {
        if (!CutsceneManager.GetCanPlay(self.CutsceneID))
        {
            return;
        }

        if (obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            CutsceneManager.Start(self.CutsceneID, self.Full);
        }
    }
}

component MovementLocker
{
    Lock = true;
    Time = 3.0;

    # @type any
    function OnCollisionEnter(obj)
    {
        if (obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            if (self.Lock)
            {
                PlayerProxy.LockMovementFor(self.Time);
            }
            else
            {
                PlayerProxy.UnlockMovement();
            }
        }
    }
}

component Slider
{
    ButtonID = 0;
    Reverse = false;
    SlideVector = Vector3(0, 0, 0);
    RotationVector = Vector3(0, 0, 0);
    AnimationDuration = 0.25;
    ChangeRotation = false;

    _initPos = Vector3(0, 0, 0);
    _initRot = Vector3(0, 0, 0);

    # @type Activatable
    _activatable = null;
    # @type Timer
    _animationTimer = null;

    _isAnimating = false;
    _currentStartPos = Vector3(0, 0, 0);
    _currentEndPos = Vector3(0, 0, 0);
    _currentStartRot = Vector3(0, 0, 0);
    _currentEndRot = Vector3(0, 0, 0);

    _lastDirectionOpening = false;
    _currentProgress = 0.0;

    function OnGameStart()
    {
        self._initPos = self.MapObject.Position;
        self._initRot = self.MapObject.Rotation;

        if (self.ButtonID == 0 || self.ButtonID == self.MapObject.ID)
        {
            self._activatable = self.MapObject.GetComponent("Activatable");
        }
        else
        {
            self._activatable = Map.FindMapObjectByID(self.ButtonID).GetComponent("Activatable");
        }

        self._animationTimer = Timer(0.0);
        self._isAnimating = false;
        self._lastDirectionOpening = false;
        self._currentProgress = 0.0;
        self._currentStartPos = self._initPos;
        self._currentEndPos = self._initPos;
        self._currentStartRot = self._initRot;
        self._currentEndRot = self._initRot;
    }

    function OnTick()
    {
        if (self._activatable == null)
        {
            return;
        }

        if ((self._activatable.IsActive() != self.Reverse) != self._lastDirectionOpening)
        {
            self.startAnimation(self._activatable.IsActive() != self.Reverse);
        }

        if (self._isAnimating)
        {
            self._UpdateAnimation();
        }
    }

    function startAnimation(opening)
    {
        if (self._isAnimating)
        {
            if (self._lastDirectionOpening != opening)
            {
                if (opening)
                {
                    self._animationTimer.Reset(self.AnimationDuration - (self.AnimationDuration * (1 - self._currentProgress)));
                }
                else
                {
                    self._animationTimer.Reset(self.AnimationDuration * self._currentProgress);
                }
            }
            else
            {
                self._animationTimer.Reset(self.AnimationDuration);
            }
        }
        else
        {
            self._animationTimer.Reset(self.AnimationDuration);
        }

        if (opening)
        {
            self._currentStartPos = self._initPos;
            self._currentEndPos = self._initPos + self.SlideVector;
            if (self.ChangeRotation)
            {
                self._currentStartRot = self._initRot;
                self._currentEndRot = self._initRot + self.RotationVector;
            }
        }
        else
        {
            self._currentStartPos = self._initPos + self.SlideVector;
            self._currentEndPos = self._initPos;
            if (self.ChangeRotation)
            {
                self._currentStartRot = self._initRot + self.RotationVector;
                self._currentEndRot = self._initRot;
            }
        }

        self._isAnimating = true;
        self._lastDirectionOpening = opening;
    }

    function _UpdateAnimation()
    {
        if (self._animationTimer.IsDone())
        {
            self.MapObject.Position = self._currentEndPos;
            if (self.ChangeRotation)
            {
                self.MapObject.Rotation = self._currentEndRot;
            }
            self._isAnimating = false;

            self._currentProgress = 0.0;
            if (self._lastDirectionOpening)
            {
                self._currentProgress = 1.0;
            }

            return;
        }

        self._animationTimer.UpdateOnTick();
        progress = 1.0 - (self._animationTimer.GetTime() / self.AnimationDuration);

        self.MapObject.Position = Vector3.Lerp(self._currentStartPos, self._currentEndPos, progress);
        if (self.ChangeRotation)
        {
            self.MapObject.Rotation = Vector3.Lerp(self._currentStartRot, self._currentEndRot, progress);
        }

        self._currentProgress = progress;
    }
}

component Elevator
{
    ButtonID = 0;
    Destination = Vector3(0, 0, 0);
    AnimationDuration = 0.25;
    StopDuration = 1.0;
    ElevatorType = "TwoWay";
    ElevatorTypeDropbox = "TwoWay,OneWay";
    ResetGroup = "";
    ReturnOnDeactivate = true;

    STATE_STOPPED = 0;
    STATE_MOVING = 1;

    # @type Activatable
    _activatable = null;
    # @type Timer
    _animationTimer = null;
    # @type Timer
    _stopTimer = null;

    _isMovingToB = true;
    _state = null;
    _initPos = null;
    _targetPos = null;
    _relativePositions = Dict();
    _progress = 0.0;
    _lastActive = false;

    function OnGameStart()
    {
        if (self.ButtonID == 0 || self.ButtonID == self.MapObject.ID)
        {
            self._activatable = self.MapObject.GetComponent("Activatable");
        }
        else
        {
            self._activatable = Map.FindMapObjectByID(self.ButtonID).GetComponent("Activatable");
        }

        self._lastActive = self._activatable.IsActive();
        self._state = self.STATE_STOPPED;
        self._initPos = self.MapObject.Position;
        self._animationTimer = Timer(0.0);
        self._stopTimer = Timer(0.0);
        ResetManager.Add(self.ResetGroup, self);
    }

    function Reset()
    {
        self.MapObject.Position = self._initPos;
        self._state = self.STATE_STOPPED;
        self._animationTimer = Timer(0.0);
        self._stopTimer = Timer(0.0);
        self._isMovingToB = true;
        self._relativePositions.Clear();
        self._progress = 0.0;
        self._lastActive = self._activatable.IsActive();
    }

    function OnTick()
    {
        if (self.ElevatorType == "TwoWay")
        {
            if (self._activatable.IsActive())
            {
                if (self._state == self.STATE_STOPPED)
                {
                    self._stopTimer.UpdateOnTick();

                    if (self._stopTimer.IsDone())
                    {
                        self._animationTimer.Reset(self.AnimationDuration);
                        self._state = self.STATE_MOVING;

                        if (self._isMovingToB)
                        {
                            self._targetPos = self.Destination;
                        }
                        else
                        {
                            self._targetPos = self._initPos;
                        }
                    }
                }
                elif (self._state == self.STATE_MOVING)
                {
                    if (self._isMovingToB)
                    {
                        self.animateElevator(self._initPos, self.Destination);
                    }
                    else
                    {
                        self.animateElevator(self.Destination, self._initPos);
                    }
                }
            }
            elif (self.ReturnOnDeactivate)
            {
                if (self._state == self.STATE_STOPPED)
                {
                    if (self.MapObject.Position == self._initPos)
                    {
                        return;
                    }

                    self._animationTimer.Reset(self.AnimationDuration);
                    self._state = self.STATE_MOVING;
                    self._targetPos = self._initPos;
                }
                elif (self._state == self.STATE_MOVING)
                {
                    self.animateElevator(self.MapObject.Position, self._initPos);

                    if (self.MapObject.Position == self._initPos)
                    {
                        self._state = self.STATE_STOPPED;
                    }
                }
            }
        }
        elif (self.ElevatorType == "OneWay")
        {
            if (self._activatable.IsActive())
            {
                if (self._state == self.STATE_STOPPED)
                {
                    if (self.MapObject.Position == self.Destination)
                    {
                        return;
                    }

                    self._animationTimer.Reset(self.AnimationDuration);
                    self._state = self.STATE_MOVING;
                    self._targetPos = self.Destination;
                }
                elif (self._state == self.STATE_MOVING)
                {
                    if (self._lastActive != self._activatable.IsActive())
                    {
                        self._animationTimer.Reset(self.AnimationDuration - (self.AnimationDuration * (1 - self._progress)));
                    }
                    self.animateElevator(self._initPos, self.Destination);

                    if (self.MapObject.Position == self.Destination)
                    {
                        self._state = self.STATE_STOPPED;
                    }
                }
            }
            elif (self.ReturnOnDeactivate)
            {
                if (self._state == self.STATE_STOPPED)
                {
                    if (self.MapObject.Position == self._initPos)
                    {
                        return;
                    }

                    self._animationTimer.Reset(self.AnimationDuration);
                    self._state = self.STATE_MOVING;
                    self._targetPos = self._initPos;
                }
                elif (self._state == self.STATE_MOVING)
                {
                    if (self._lastActive != self._activatable.IsActive())
                    {
                        self._animationTimer.Reset(self.AnimationDuration * self._progress);
                    }
                    self.animateElevator(self.Destination, self._initPos);

                    if (self.MapObject.Position == self._initPos)
                    {
                        self._state = self.STATE_STOPPED;
                    }
                }
            }
        }

        self._lastActive = self._activatable.IsActive();
    }

    # @type any
    function OnCollisionStay(obj)
    {
        if (obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            # @type Human
            human = obj;
            currentAnimation = human.CurrentAnimation;
            if (
                currentAnimation == HumanAnimationEnum.IdleAHSSF
                || currentAnimation == HumanAnimationEnum.IdleAHSSM
                || currentAnimation == HumanAnimationEnum.IdleF
                || currentAnimation == HumanAnimationEnum.IdleM
                || currentAnimation == HumanAnimationEnum.IdleTSF
                || currentAnimation == HumanAnimationEnum.IdleTSM
                || currentAnimation == HumanAnimationEnum.Land
            )
            {
                if (!self._relativePositions.Contains(human))
                {
                    self._relativePositions.Set(human, human.Position - self.MapObject.Position);
                }
                relativePos = self._relativePositions.Get(human);
                human.Position = self.MapObject.Position + relativePos;
            }
            else
            {
                self._relativePositions.Set(human, human.Position - self.MapObject.Position);
            }
        }
        elif (obj.Type == ObjectTypeEnum.MAP_OBJECT)
        {
            # @type MapObject
            mapObject = obj;
            comp = mapObject.GetComponent("Movable");
            if (!comp.IsCarried())
            {
                if (!self._relativePositions.Contains(mapObject))
                {
                    self._relativePositions.Set(mapObject, mapObject.Position - self.MapObject.Position);
                }
                relativePos = self._relativePositions.Get(mapObject);
                mapObject.Position = self.MapObject.Position + relativePos;
            }
        }
    }

    function OnCollisionExit(obj)
    {
        if (self._relativePositions.Contains(obj))
        {
            self._relativePositions.Remove(obj);
        }
    }

    function animateElevator(startPos, endPos)
    {
        if (!self._animationTimer.IsDone())
        {
            self._animationTimer.UpdateOnTick();
            self._progress = 1.0 - (self._animationTimer.GetTime() / self.AnimationDuration);
            self.MapObject.Position = Vector3.Lerp(startPos, endPos, self._progress);
        }
        else
        {
            self.MapObject.Position = endPos;
            self._state = self.STATE_STOPPED;

            if (self.ElevatorType == "TwoWay")
            {
                self._stopTimer.Reset(self.StopDuration);
                self._isMovingToB = !self._isMovingToB;
            }
        }
    }
}

component Follower
{
    Follow = true;

    function OnTick()
    {
        if (!self.Follow)
        {
            return;
        }

        vec = Camera.Position - self.MapObject.Position;
        direction = vec.Normalized;
        yaw = Math.Atan2(direction.Z, direction.X);
        pitch = Math.Asin(direction.Y);
        self.MapObject.Rotation = Vector3(0.0, yaw * -1, pitch);
    }
}

component Movable
{
    ResetGroup = "";
    LockForward = false;
    LockBackward = false;
    LockPositionID = 0;

    _pickupDistance = 3.0;
    _pickupThreshold = 0.1;
    _springFactor = 200.0;
    _dampingFactor = 20.0;

    _carrier = null;
    _initPos = null;
    _initRot = null;
    _initLockPosRef = null;
    # @type RigidbodyBuiltin
    _rb = null;
    _initGravity = null;
    _once = false;
    _lockPos = null;
    # @type RigidBodyAccelerationTracker
    _accelerationTracker = null;

    function Initialize()
    {
        self._initPos = self.MapObject.Position;
        self._initRot = self.MapObject.Rotation;
        # TODO: Rigidbody. Example of successfull access
        self._rb = self.MapObject.Rigidbody;
        self._accelerationTracker = RigidBodyAccelerationTracker(self._rb);
        self._initGravity = self._rb.Gravity;
        if (self.LockPositionID > 0)
        {
            self._initLockPosRef = Map.FindMapObjectByID(self.LockPositionID);
            self._lockPos = self._initLockPosRef.Position;
        }
        if (!self._once && self.ResetGroup != "")
        {
            ResetManager.Add(self.ResetGroup, self);
            self._once = true;
        }
    }

    function Reset()
    {
        if (self._carrier != null)
        {
            self._carrier = null;
            PlayerProxy._carrying = null;
        }
        self.MapObject.Position = self._initPos;
        self.MapObject.Rotation = self._initRot;
        self._rb.Velocity = Vector3.Zero;
        self._rb.Gravity = self._initGravity;
        if (self._initLockPosRef != null)
        {
            self._lockPos = self._initLockPosRef.Position;
        }
        self.MapObject.SetCollideWith(CollideWithEnum.All);
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function OnTick()
    {
        if (!self.MapObject.Active)
        {
            return;
        }

        self._accelerationTracker.OnTick();

        if (self._carrier != null && self._lockPos == null)
        {
            self._rb.Gravity = Vector3.Zero;
            targetPos = self._carrier.Position + Vector3.Up + (Camera.Forward * self._pickupDistance);
            currentPos = self.MapObject.Position;
            distance = Vector3.Distance(currentPos, targetPos);
            if (distance > 25.0)
            {
                self.TeleportToCarrier();
            }
            elif (distance > self._pickupThreshold)
            {
                direction = targetPos - currentPos;
                currentVelocity = self._rb.Velocity;
                force = direction * Main.SpringFactor - currentVelocity * Main.DampingFactor;
                self._rb.AddForce(force, ForceModeEnum.Acceleration);
            }

            if (self.LockForward)
            {
                direction = Camera.Forward;
                direction.Y = 0;
                magnitude = Math.Sqrt(direction.X * direction.X + direction.Z * direction.Z);
                if (magnitude > 0)
                {
                    direction = direction / magnitude;
                    self.MapObject.Forward = direction;
                }
            }
            elif (self.LockBackward)
            {
                direction = Camera.Forward * -1;
                direction.Y = 0;
                magnitude = Math.Sqrt(direction.X * direction.X + direction.Z * direction.Z);
                if (magnitude > 0)
                {
                    direction = direction / magnitude;
                    self.MapObject.Forward = direction;
                }
            }
        }
        elif (self._lockPos != null)
        {
            self._rb.Gravity = Vector3.Zero;
            self._rb.Velocity = Vector3.Zero;
            self.MapObject.Position = self._lockPos;
        }
    }

    function Pickup(c)
    {
        self.MapObject.SetCollideWith(CollideWithEnum.MapObjects);
        self._rb.Gravity = Vector3.Zero;
        self._rb.Velocity = Vector3.Zero;
        self._carrier = c;
        # self.TeleportToCarrier();
    }
    
    function Drop()
    {
        self.MapObject.SetCollideWith(CollideWithEnum.All);
        self._rb.Gravity = self._initGravity;
        self._rb.Velocity = self._rb.Velocity + self._carrier.Velocity;
        self._carrier = null;
    }

    function IsCarried()
    {
        return self._carrier != null;
    }

    function LockPos(v)
    {
        if (self._carrier != null)
        {
            PlayerProxy._carrying = null;
            self._carrier = null;
        }
        self._rb.Velocity = Vector3.Zero;
        self._rb.Gravity = Vector3(0.0);
        self._lockPos = v;
    }

    function UnlockPos()
    {
        self._lockPos = null;
        self._rb.Gravity = self._initGravity;
        self._rb.Velocity = Vector3.Zero;
    }

    function CanPickup()
    {
        return self._carrier == null && self._lockPos == null;
    }

    function IsLocked()
    {
        return self._lockPos != null;
    }

    function TeleportToCarrier()
    {
        if (self._carrier == null)
        {
            return;
        }

        self.MapObject.Position = self._carrier.Position + Vector3.Up + (Camera.Forward * 0.5);
    }

    # @return float
    function GetTrackedAcceleration()
    {
        return self._accelerationTracker.GetAcceleration();
    }
}

component Controllable
{
    ResetGroup = "";

    _iPos = null;
    _iRot = null;

    _startPosition = Vector3(0, 0, 0);
    _targetPosition = Vector3(0, 0, 0);
    _moveTime = 0.0;
    _elapsedTime = 0.0;
    _isMoving = false;

    _isRotating = false;
    _rotationSpeed = 0.0;

    _once = false;

    function Initialize()
    {
        self._iPos = self.MapObject.Position;
        self._iRot = self.MapObject.Rotation;

        if (!self._once && self.ResetGroup != "")
        {
            ResetManager.Add(self.ResetGroup, self);
            self._once = true;
        }
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function Reset()
    {
        self.MapObject.Position = self._iPos;
        self.MapObject.Rotation = self._iRot;
    }

    # @param pos Vector3
    # @param t float
    function MoveTo(pos, t)
    {
        self._startPosition = self.MapObject.Position;
        self._targetPosition = pos;
        self._moveTime = t;
        self._elapsedTime = 0.0;
        self._isMoving = true;
    }

    function StartRotating(speed)
    {
        self._rotationSpeed = speed;
        self._isRotating = true;
    }

    function StopRotating()
    {
        self._isRotating = false;
    }

    function OnTick()
    {
        if (self._isMoving)
        {
            self._elapsedTime += Time.TickTime;
            t = Math.Clamp(self._elapsedTime / self._moveTime, 0.0, 1.0);
            self.MapObject.Position = Vector3.Lerp(
                self._startPosition,
                self._targetPosition,
                t
            );

            if (t >= 1.0)
            {
                self._isMoving = false;
            }
        }

        if (self._isRotating)
        {
            self.MapObject.Rotation = self.MapObject.Rotation * Time.TickTime * self._rotationSpeed;
        }
    }
}

component EasterEgg
{
    Name = "";
    _once = false;

    function OnGameStart()
    {
        EasterEggManager.Register(self.Name);
    }

    # @param obj any
    function OnCollisionEnter(obj)
    {
        if (self._once || obj.Type != ObjectTypeEnum.HUMAN || !obj.IsMine)
        {
            return;
        }
        EasterEggManager.SetFound(self.Name);
        SoundManager.Play(HumanSoundEnum.BladeNape1Var1);
        self._once = true;
    }
}

component ObjLogger
{
    function OnSecond()
    {
        MCLogger.Debug(self.MapObject.Position);
    }
}

component TileAnimator
{
    XSpeed = 0.03;
    YSpeed = 0.03;
    RandomMode = false;
    MinChangeTime = 5.0;
    MaxChangeTime = 10.0;
    MinX = -0.03;
    MaxX = 0.03;
    MinY = -0.03;
    MaxY = 0.03;

    _timeToNextChange = 0.0;

    function OnTick()
    {
        if (!self.MapObject.Active)
        {
            return;
        }

        if (self.RandomMode)
        {
            if (self._timeToNextChange <= 0.0)
            {
                self.XSpeed = Random.RandomFloat(self.MinX, self.MaxX);
                self.YSpeed = Random.RandomFloat(self.MinY, self.MaxY);
                self._timeToNextChange = Random.RandomFloat(self.MinChangeTime, self.MaxChangeTime);
            }
            else
            {
                self._timeToNextChange -= Time.TickTime;
            }
        }

        if (self.XSpeed != 0.0)
        {
            res = self.MapObject.TextureOffsetX + Time.TickTime * self.XSpeed;
            if (res > 1.0)
            {
                res = res - 1.0;
            }
            if (res < 0.0)
            {
                res = res + 1.0;
            }
            self.MapObject.TextureOffsetX = res;
        }

        if (self.YSpeed != 0.0)
        {
            res = self.MapObject.TextureOffsetY + Time.TickTime * self.YSpeed;
            if (res > 1.0)
            {
                res = res - 1.0;
            }
            if (res < 0.0)
            {
                res = res + 1.0;
            }
            self.MapObject.TextureOffsetY = res;
        }
    }
}

component SpeedRunCheck
{
    Name = "";
    Group = "";
    Type = "Start";
    TypeDropbox = "Start,Segment,Stop";
    _once = false;

    function OnGameStart()
    {
        if (self.Type != "Stop")
        {
            SpeedRunManager.RegisterSegment(self.Group, self.Name);
        }
        SpeedRunManager.RegisterComponent(self);
        if (self.Type == "Start")
        {
            SpeedRunManager.RegisterSpawnPoint(self.Group, self.MapObject.Position);
        }
    }

    # @param obj any
    function OnCollisionEnter(obj)
    {
        if (
            self._once || !PlayerProxy.SpeedRunMode || SpeedRunManager.SpeedRunFinished
            || (!PlayerProxy.SpeedRunMode && (SpeedRunManager._activeGroup == "" || SpeedRunManager._activeGroup != self.Group)))
        {
            return;
        }

        if (!obj.IsCharacter || !obj.IsMine)
        {
            return;
        }

        if (self.Type == "Start")
        {
            SpeedRunManager.StartSpeedrun(self.Group, self.Name);
        }
        elif (self.Type == "Segment")
        {
            SpeedRunManager.StartSegment(self.Name);
        }
        elif (self.Type == "Stop")
        {
            SpeedRunManager.StopSpeedrun();
        }

        self._once = true;
    }

    function Reset()
    {
        self._once = false;
    }
}

component SmartTeleport
{
    ActivatableID = 0;
    ObjectID = 0;
    ObjectName = "";
    StopVelocity = true;
    _tpPos = null;
    _forward = null;
    # @type Activatable
    _activatable = null;

    function OnGameStart()
    {
        if (self.ObjectID > 0)
        {
            obj = Map.FindMapObjectByID(self.ObjectID);
            if (obj != null)
            {
                self._tpPos = obj.Position;
                self._forward = obj.Forward;
            }
        }
        elif (self.ObjectName != "")
        {
            obj = Map.FindMapObjectByName(self.ObjectName);
            if (obj != null)
            {
                self._tpPos = obj.Position;
                self._forward = obj.Forward;
            }
        }

        if (self.ActivatableID > 0)
        {
            obj = Map.FindMapObjectByID(self.ActivatableID);
            self._activatable = obj.GetComponent("Activatable");
        }
    }

    # @param obj any
    function OnCollisionStay(obj)
    {
        if (obj.Type != ObjectTypeEnum.HUMAN || !obj.IsMine)
        {
            return;
        }

        if (self._tpPos == null)
        {
            return;
        }

        if (self._activatable != null && !self._activatable.IsActive())
        {
            return;
        }

        PlayerProxy.ResetPortals(true);
        carr = PlayerProxy.GetCarrying();
        if (carr != null)
        {
            PlayerProxy.DropCarrying();
            carr.Reset();
        }

        obj.Position = self._tpPos;
        Camera.LookAt(Camera.Position + self._forward * 15.0);
        if (self.StopVelocity)
        {
            vel = Vector3(0.0);
            obj.Velocity = vel;
            PlayerProxy.SetVelocityFor(vel, 0.1);
            PlayerProxy.LockMovementFor(0.05);
        }
    }
}

component CheckpointRegion
{
    Name = "";

    # @param obj any
    function OnCollisionEnter(obj)
    {
        if (obj.Type == "Human" && obj.IsMine)
        {
            obj.Player.SpawnPoint = self.MapObject.Position;
            ScoreboardManager.UpdateChamber(self.Name);
        }
    }
}

#######################
## CORE
#######################

component Portal
{
    UID = 0;
    Type = "Orange";
    TypeDropbox = "Orange,Blue";

    CD = 0.3;
    CDTooltip = "Cooldown before the related portal becomes active for teleportation after using this portal.";

    _enabled = false;
    # @type Portal
    _related = null;

    _timer = Timer(0.0);
    _playerSoundTimer = Timer(0.0);
    _companionSoundTimer = Timer(0.0);

    # @type Timer
    _animationTimer = Timer(0.0);
    _animationDuration = 0.15;

    # @type Vector3
    _originalScale = Vector3(1.0, 1.0, 1.0);

    function Initialize()
    {
        # @type MapObject
        parent = self.MapObject.Parent;
        self._originalScale = parent.Scale;
        self._animationTimer.Reset(0.0);
    }

    # @param obj any
    function OnCollisionStay(obj)
    {
        if (self._related == null || !self._related._enabled)
        {
            return;
        }

        if (!self._timer.IsDone())
        {
            return;
        }

        if (obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            self._HandleHumanCollision(obj);
        }
        elif (obj.Type == ObjectTypeEnum.MAP_OBJECT)
        {
            self._HandleMapObjectCollision(obj);
        }
    }

    # function OnCollisionEnter(obj)
    # {
    #     if (self._related == null || !self._related._enabled)
    #     {
    #         return;
    #     }

    #     if (!self._timer.IsDone())
    #     {
    #         return;
    #     }

    #     elif (obj.Type == ObjectTypeEnum.MAP_OBJECT)
    #     {
    #         self._HandleMapObjectCollision(obj);
    #     }
    # }

    function OnTick()
    {
        # @type MapObject
        parent = self.MapObject.Parent;
        parent.Active = self._enabled;
        if (!self._enabled)
        {
            return;
        }

        self._timer.UpdateOnTick();
        self._playerSoundTimer.UpdateOnTick();
        self._companionSoundTimer.UpdateOnTick();
    }

    function OnFrame()
    {
        if (!self._animationTimer.IsDone())
        {
            self._animationTimer.UpdateOnFrame();
            self._UpdateAnimation();
        }
    }

    function SetRelated(p)
    {
        self._related = p;
    }

    function IsEnabled()
    {
        return self._enabled;
    }

    function Enable()
    {
        self._enabled = true;
    }

    function Disable()
    {
        self._enabled = false;
    }

    function Animate()
    {
        self._animationTimer.Reset(self._animationDuration);
    }

    # @param dir Vector3
    # @return Vector3
    function CalculateRelatedDirection(dir)
    {
        localDirX = Vector3.Dot(dir, self.MapObject.Right);
        localDirY = Vector3.Dot(dir, self.MapObject.Up);
        localDirZ = Vector3.Dot(dir, self.MapObject.Forward);

        localDirX = localDirX * -1;
        localDirZ = localDirZ * -1;

        newDirection = (self._related.MapObject.Right * localDirX)
                    + (self._related.MapObject.Up * localDirY)
                    + (self._related.MapObject.Forward * localDirZ);

        return newDirection.Normalized;
    }

    # @param pos Vector3
    # @return Vector3
    function CalculateRelatedPosition(pos)
    {
        localHitPoint = pos - self.MapObject.Position;

        localX = Vector3.Dot(localHitPoint, self.MapObject.Right);
        localY = Vector3.Dot(localHitPoint, self.MapObject.Up);

        localX = localX * -1;

        return self._related.MapObject.Position
            + (self._related.MapObject.Right * localX)
            + (self._related.MapObject.Up * localY);
    }

    function _HandleHumanCollision(humanObj)
    {
        self._ResetRelatedTimer();

        newPos = self._related.MapObject.Position + (self._related.MapObject.Forward * 1);
        self._TeleportObject(humanObj, newPos);

        if (PlayerProxy.GetCarrying() != null)
        {
            PlayerProxy.GetCarrying().TeleportToCarrier();
        }

        Camera.LookAt(Camera.Position + self.CalculateRelatedDirection(Camera.Forward));

        accel = PlayerAccelerationTracker.GetAcceleration();
        vel = self._related.MapObject.Forward * accel;
        if (
            PlayerProxy.GetCharacter().CurrentAnimation != HumanAnimationEnum.Run
            && PlayerProxy.GetCharacter().CurrentAnimation != HumanAnimationEnum.RunTS
            && PlayerProxy.GetCharacter().CurrentAnimation != HumanAnimationEnum.RunBuffed
        )
        {
            self._ApplyVelocity(humanObj, vel, 0.1);
        }
        else
        {
            humanObj.Velocity = vel;
        }

        self._PlaySoundOnce(self._playerSoundTimer, HumanSoundEnum.Checkpoint);
    }

    # @param mapObj MapObject
    function _HandleMapObjectCollision(mapObj)
    {
        # TODO: Rigidbody bug. Example of successfull access
        # TODO: UPD: Not successfull
        rb = mapObj.Rigidbody;

        # # @type IRigidbody
        # rb = mapObj.GetComponent("Rigidbody");
        if (rb == null)
        {
            return;
        }

        comp = mapObj.GetComponent("Movable");
        if (comp != null && comp.IsCarried())
        {
            return;
        }

        self._ResetRelatedTimer();

        newPos = self._related.MapObject.Position + (self._related.MapObject.Forward * 1);
        accel = comp.GetTrackedAcceleration();
        if (accel < 5.0)
        {
            accel = 5.0;
        }

        vel = self._related.MapObject.Forward * accel;

        # rb.SetVelocity(vel);
        rb.Velocity = vel;

        mapObj.Position = newPos;

        self._PlaySoundOnce(self._companionSoundTimer, HumanSoundEnum.Checkpoint);
    }

    function _UpdateAnimation()
    {
        progress = 1.0 - (self._animationTimer.GetTime() / self._animationDuration);
        startScale = Vector3(0.0, 0.0, 0.0);
        # @type MapObject
        parent = self.MapObject.Parent;
        parent.Scale = Vector3.Lerp(startScale, self._originalScale, progress);
    }

    function _ResetRelatedTimer()
    {
        self._related._timer.Reset(self.CD);
    }

    function _TeleportObject(obj, newPos)
    {
        obj.Position = newPos;
    }

    # @param humanObj Human
    # @param velocity Vector3
    # @param secondsDelay float
    function _ApplyVelocity(humanObj, velocity, secondsDelay)
    {
        humanObj.Velocity = velocity;
        PlayerProxy.SetVelocityFor(velocity, secondsDelay);
    }

    # @param soundTimer Timer
    # @param sound string
    function _PlaySoundOnce(soundTimer, sound)
    {
        if (soundTimer.IsDone())
        {
            SoundManager.Play(sound);
            soundTimer.Reset(self.CD);
        }
    }
}

component PortalSurfaceable
{
    /*
        This component marks objects as valid surfaces for portal activation.
        It does not contain any logic itself but serves as a tag for identifying
        objects that can interact with the portal system.
    */
}

component TargetPassThrough
{
    All = true;
    AllTooltip = "Allow all ray types to pass through this object.";

    Portals = false;
    PortalsTooltip = "Allow portal-related rays to pass through this object.";

    Lasers = false;
    LasersTooltip = "Allow laser beams to pass through this object.";

    TurretLasers = false;
    TurretLasersTooltip = "Allow turret laser beams to pass through this object.";

    HardLightBridges = false;
    HardLightBridgesTooltip = "Allow hard light bridge rays to pass through this object.";

    /*
        This component allows rays to pass through the object.
        When ray hits an object with this component, the ray continues through it.
        It does not contain any logic itself but serves as a tag to identify
        objects that should not block ray casting.
    */
}

component LaserSource
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component. Set to 0 to use the Active field instead.";
    Active = false;
    ActiveTooltip = "Determines whether the component is active. Ignored if ActivatableID is set.";

    # @type List<LineRenderer>
    _activeLasers = List();
    # @type Activatable
    _activatable = null;

    _damage = 25;
    _damageDelay = 0.3;
    _damageDelayTimer = Timer(0.0);

    _maxLasers = 100;

    # @type List<ObjectSegment>
    _currentLaserPath = List();
    # @type List<ObjectSegment>
    _previousLaserPath = List();

    # @type Vector3
    _rayCastOffset = null;
    _maxDistance = 10000;
    _laserWidth = 0.1;
    _laserColor = Color(255, 0, 72, 155);

    _once = false;

    function Initialize()
    {
        if (self.ActivatableID > 0)
        {
            activatableObj = Map.FindMapObjectByID(self.ActivatableID);
            if (activatableObj != null)
            {
                self._activatable = activatableObj.GetComponent("Activatable");

                # @type ActiveControl
                lightObjAC = self.MapObject.GetChild("LaserSource_Light").GetComponent("ActiveControl");
                lightObjAC.ActivatableID = self.ActivatableID;
                lightObjAC.Initialize();
            }
        }

        self._damageDelayTimer = Timer(0.0);

        # self._rayCastOffset = self.MapObject.Up * 0.1;
        self._rayCastOffset = Vector3(0.0);
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function OnTick()
    {
        if ((self._activatable == null && !self.Active) || (self._activatable != null && !self._activatable.IsActive()))
        {
            if (!self._once)
            {
                self._DeactivateLasers(0);
                self._previousLaserPath.Clear();
                self._once = true;
            }
            return;
        }
        self._once = false;


        self._damageDelayTimer.UpdateOnTick();

        self._currentLaserPath = List();

        startPos = self.MapObject.Position + self.MapObject.Forward * self.MapObject.Scale.Z / 2;
        direction = self.MapObject.Forward;
        self._CastLaser(startPos, direction, 0);

        differenceIndex = self._GetFirstDifferenceIndex(self._currentLaserPath, self._previousLaserPath);

        if (differenceIndex == -1)
        {
            return;
        }

        self._DeactivateLasers(differenceIndex);
        self._UpdateLasers(differenceIndex);

        self._previousLaserPath = self._currentLaserPath;
    }

    function _DeactivateLasers(startIndex)
    {
        count = self._activeLasers.Count;
        if (count < 1)
        {
            return;
        }

        for (i in Range(count - 1, startIndex - 1, -1))
        {
            laser = self._activeLasers.Get(i);
            # ObjectPoolManager.ReturnObjectToPool(ObjectPoolManager.LASER, laser);
            ObjectPoolManager.ReturnLineRendererToPool(laser);
            self._activeLasers.RemoveAt(i);
        }
    }

    function _CastLaser(startPos, direction, depth)
    {
        if (depth >= self._maxLasers)
        {
            return;
        }

        laserSegment = ObjectSegment();
        laserSegment.StartPos = startPos;
        laserSegment.Direction = direction;

        res = Physics.LineCast(startPos + self._rayCastOffset, startPos + (direction * self._maxDistance) + self._rayCastOffset, CollideWithEnum.All);
        laserSegment.HitResult = res;
        self._currentLaserPath.Add(laserSegment);

        if (self._currentLaserPath.Count > 1)
        {
            prevSegment = self._currentLaserPath.Get(self._currentLaserPath.Count - 2);
            currentSegment = self._currentLaserPath.Get(self._currentLaserPath.Count - 1);

            if (self._CanMergeSegments(prevSegment, currentSegment))
            {
                prevSegment.HitResult = currentSegment.HitResult;

                self._currentLaserPath.RemoveAt(self._currentLaserPath.Count - 1);
                self._currentLaserPath.RemoveAt(self._currentLaserPath.Count - 1);
                self._currentLaserPath.Add(prevSegment);
            }
        }

        if (res != null)
        {
            if (res.IsMapObject)
            {
                # @type MapObject
                mapObject = res.Collider;
                passThrough = mapObject.GetComponent("TargetPassThrough");
                if (passThrough != null && (passThrough.All || passThrough.Lasers))
                {
                    if (mapObject.Name == "LaserReceiver" || mapObject.Name == "LaserReceiver2")
                    {
                        laserReceiver = mapObject.GetComponent("LaserReceiver");
                        laserReceiver.Trigger();
                    }
                    newStartPos = res.Point - self._rayCastOffset + (direction * 0.01);
                    self._CastLaser(newStartPos, direction, depth + 1);
                }
                elif (mapObject.Name == "Portal_BLUE_Visuals" || mapObject.Name == "Portal_ORANGE_Visuals")
                {
                    if (mapObject.Name == "Portal_BLUE_Visuals")
                    {
                        portalComp = mapObject.GetChild("Portal_BLUE").GetComponent("Portal");
                    }
                    else
                    {
                        portalComp = mapObject.GetChild("Portal_ORANGE").GetComponent("Portal");
                    }

                    if (portalComp != null && portalComp._related.IsEnabled() && portalComp._related != null)
                    {
                        newStartPos = portalComp.CalculateRelatedPosition(res.Point) - self._rayCastOffset;
                        newDirection = portalComp.CalculateRelatedDirection(direction);
                        self._CastLaser(newStartPos + newDirection * -0.1, newDirection, depth + 1);
                    }
                }
                elif (mapObject.Name == "DiscouragementRedirectionCube")
                {
                    self._CastLaser(mapObject.Position, mapObject.Forward, depth + 1);
                }
                elif (mapObject.Name == "LaserReceiver" || mapObject.Name == "LaserReceiver2")
                {
                    laserReceiver = mapObject.GetComponent("LaserReceiver");
                    laserReceiver.Trigger();
                }
                elif (mapObject.Name == "Turret")
                {
                    turretComp = mapObject.GetComponent("Turret");
                    if (self._damageDelayTimer.IsDone())
                    {
                        turretComp.SetOnFire();
                        SoundManager.Play(HumanSoundEnum.BladeBreak);
                        self._damageDelayTimer.Reset(self._damageDelay);
                    }
                }
            }
            elif (res.IsCharacter)
            {
                # @type Character
                char = res.Collider;
                if (char.IsMine)
                {
                    if (self._damageDelayTimer.IsDone())
                    {
                        PlayerProxy.GetDamaged("Laser", self._damage);
                        i = Random.RandomInt(0, 3);
                        if (i == 0){
                            sfx = HumanSoundEnum.Death1;
                        } elif (i == 1) {
                            sfx = HumanSoundEnum.Death5;
                        } elif (i == 2) {
                            sfx = HumanSoundEnum.LimbHit;
                        } else {
                            sfx = HumanSoundEnum.NapeHit;
                        }
                        SoundManager.Play(sfx);
                        self._damageDelayTimer.Reset(self._damageDelay);
                    }
                }
                newStartPos = res.Point - self._rayCastOffset + (direction * 0.01);
                self._CastLaser(newStartPos, direction, depth + 1);
            }
        }
    }

    function _CanMergeSegments(segmentA, segmentB)
    {
        if (self._IsPassThroughSegment(segmentA))
        {
            return true;
        }

        if (self._IsPortalSegment(segmentA))
        {
            return false;
        }

        return false;
    }

    function _IsPortalSegment(segment)
    {
        res = segment.HitResult;
        if (res != null && res.IsMapObject)
        {
            name = res.Collider.Name;
            if (name == "Portal_BLUE_Visuals" || name == "Portal_ORANGE_Visuals")
            {
                return true;
            }
        }
        return false;
    }

    function _IsPassThroughSegment(segment)
    {
        res = segment.HitResult;
        if (res != null)
        {
            if (res.IsCharacter)
            {
                return true;
            }
            elif (res.IsMapObject)
            {
                passThrough = res.Collider.GetComponent("TargetPassThrough");
                if (passThrough != null && (passThrough.All || passThrough.Lasers))
                {
                    return true;
                }
            }
        }
        return false;
    }

    function _UpdateLasers(startIndex)
    {
        for (i in Range(startIndex, self._currentLaserPath.Count, 1))
        {
            laserSegment = self._currentLaserPath.Get(i);
            # laser = ObjectPoolManager.GetObjectFromPool(ObjectPoolManager.LASER);
            laser = ObjectPoolManager.GetLineRendererFromPool();
            if (laser == null)
            {
                return;
            }

            laser.Enabled = true;
            laser.PositionCount = 2;
            laser.StartWidth = self._laserWidth;
            laser.EndWidth = self._laserWidth;
            laser.LineColor = self._laserColor;

            startPos = laserSegment.StartPos;
            direction = laserSegment.Direction;
            res = laserSegment.HitResult;

            if (res != null)
            {
                # distance = Vector3.Distance(startPos, res.Point);
                # laserRotation = self._CalculateRotation(direction);

                # laser.Scale = Vector3(laser.Scale.X, laser.Scale.Y, distance + 0.1);
                # laser.Position = startPos + direction * (distance / 2.0);
                # laser.Rotation = laserRotation;
                laser.SetPosition(0, startPos);
                laser.SetPosition(1, res.Point);
            }
            else
            {
                # laserRotation = self._CalculateRotation(direction);

                # laser.Scale = Vector3(laser.Scale.X, laser.Scale.Y, 10000);
                # laser.Position = startPos + direction * 5000 + self.MapObject.Up;
                # laser.Rotation = laserRotation;

                laser.SetPosition(0, startPos);
                laser.SetPosition(1, startPos + direction * self._maxDistance);
            }

            self._activeLasers.Add(laser);
        }
    }

    function _GetFirstDifferenceIndex(path1, path2)
    {
        minCount = Math.Min(path1.Count, path2.Count);

        for (i in Range(0, minCount, 1))
        {
            segment1 = path1.Get(i);
            segment2 = path2.Get(i);

            if (!self._VectorsAreEqual(segment1.StartPos, segment2.StartPos) || !self._VectorsAreEqual(segment1.Direction, segment2.Direction))
            {
                return i;
            }

            res1 = segment1.HitResult;
            res2 = segment2.HitResult;

            if ((res1 == null && res2 != null) || (res1 != null && res2 == null))
            {
                return i;
            }

            if (res1 != null && res2 != null)
            {
                if (!self._VectorsAreEqual(res1.Point, res2.Point) || res1.Collider != res2.Collider)
                {
                    return i;
                }
            }
        }

        if (path1.Count != path2.Count)
        {
            return minCount;
        }

        return -1;
    }

    function _VectorsAreEqual(vec1, vec2)
    {
        return Vector3.Distance(vec1, vec2) < 0.001;
    }

    function _CalculateRotation(direction)
    {
        yaw = Math.Atan2(direction.X, direction.Z);
        pitch = Math.Asin(direction.Y) * -1;
        return Vector3(pitch, yaw, 0);
    }
}

component LaserReceiver
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component that this component can activate. Leave empty to use the Activatable component from the same object.";

    # @type Activatable
    _activatable = null;
    # @type Timer
    _timer = null;
    _prevActive = false;
    # @type MapObject
    _redDot = null;

    function Initialize()
    {
        self._redDot = self.MapObject.GetChild("LaserSource_RedDot");
        lightObjAC = self.MapObject.GetChild("LaserReceiver_Light").GetComponent("ActiveControl");
        if (self.ActivatableID == 0 || self.ActivatableID == self.MapObject.ID)
        {
            self._activatable = self.MapObject.GetComponent("Activatable");
        }
        else
        {
            self._activatable = Map.FindMapObjectByID(self.ActivatableID).GetComponent("Activatable");
        }

        lightObjAC.ActivatableID = self._activatable.MapObject.ID;
        lightObjAC.Initialize();

        self._timer = Timer(0.0);
        self._prevActive = self._activatable.IsActive();
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function Trigger()
    {
        self._timer.Reset(0.15);
    }

    function OnTick()
    {
        self._timer.UpdateOnTick();

        if (self._timer.IsDone())
        {
            self._activatable.Deactivate();
            if (self._redDot != null)
            {
                self._redDot.Active = false;
            }
        }
        else
        {
            self._activatable.Activate();
            if (self._redDot != null)
            {
                self._redDot.Active = true;
            }
        }

        currentActive = self._activatable.IsActive();

        if (currentActive != self._prevActive)
        {
            SoundManager.Play(HumanSoundEnum.Checkpoint);
            self._prevActive = currentActive;
        }
    }

    function IsActive()
    {
        return self._activatable.IsActive();
    }
}

component LaunchPad
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component. Set to 0 to always be active.";

    Direction = Vector3(0, 1, 0);
    DirectionTooltip = "The direction of the launch force.";

    Force = 10.0;
    ForceTooltip = "The strength of the launch force applied.";

    WaitForStop = true;
    WaitForStopTooltip = "Determines if the launch pad should wait for the player to lose velocity magnitude before applying force.";

    LockMovementFor = 3.0;
    LockMovementForTooltip = "The duration (in seconds) during which movement is locked after the player is launched. This should be equal to or greater than the flight duration.";

    _launch = false;
    _obj = null;
    _vel = null;
    # @type Activatable
    _activatable = null;
    # @type MapObject
    _launchPadDot = null;
    _activatedColor = null;
    _deactivatedColor = null;

    function Initialize()
    {
        self._launch = false;
        # @type MapObject
        parent = self.MapObject.Parent;
        self._launchPadDot = parent.GetChild("LaunchPad_Dot");
        self._obj = null;
        self._vel = self.Direction.Normalized * self.Force;
        if (self.ActivatableID > 0)
        {
            self._activatable = Map.FindMapObjectByID(self.ActivatableID).GetComponent("Activatable");
        }

        self._activatedColor = Color(0, 255, 255);
        self._deactivatedColor = Color(255, 0, 0);
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    # @type any
    function OnCollisionEnter(obj)
    {
        if (self._activatable != null && !self._activatable.IsActive())
        {
            return;
        }

        if (obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            if (self.LockMovementFor > 0.0)
            {
                PlayerProxy.LockMovementFor(self.LockMovementFor);
            }

            self._obj = obj;
            self._launch = true;
        }
        elif (obj.Type == ObjectTypeEnum.MAP_OBJECT)
        {
            # @type MapObject
            mapObject = obj;
            # TODO: Rigidbody bug. Example of successfull access
            rb = mapObject.Rigidbody;
            if (rb != null)
            {
                m = mapObject.GetComponent("Movable");
                if (m != null && m.IsCarried())
                {
                    return;
                }
                mapObject.Position = Vector3(self.MapObject.Position.X, mapObject.Position.Y , self.MapObject.Position.Z);
                vel = self.Direction.Normalized * self.Force;
                rb.Velocity = vel;
                SoundManager.Play(HumanSoundEnum.Switchback);
            }
        }
    }

    function OnTick()
    {
        if (self._activatable != null && !self._activatable.IsActive())
        {
            self._launchPadDot.Color = self._deactivatedColor;
            return;
        }
        self._launchPadDot.Color = self._activatedColor;

        if (self._launch)
        {
            if (
                self.WaitForStop
                && self._obj != null
                && ((self._obj.CurrentAnimation != HumanAnimationEnum.IdleTSM
                && self._obj.CurrentAnimation != HumanAnimationEnum.IdleTSF)
                || self._obj.Velocity.Magnitude != 0.0)
            )
            {
                self._obj.Position = Vector3(self.MapObject.Position.X, self._obj.Position.Y, self.MapObject.Position.Z);
                self._obj.Velocity = Vector3(0.0);
                return;
            }
            if (self.LockMovementFor > 0.0)
            {
                PlayerProxy.LockMovementFor(self.LockMovementFor);
            }
            self._launch = false;
            self._obj.Position = self.MapObject.Position;
            self._obj.Velocity = self._vel;
            self._obj = null;
            SoundManager.Play(HumanSoundEnum.Switchback);
        }
    }
}

component HardLightBridgeSource
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component. Set to 0 to use the Active field instead.";

    Active = false;
    ActiveTooltip = "Determines whether the component is active. Ignored if ActivatableID is set.";

    # @type List<MapObject>
    _activeBridges = List();
    # @type Activatable
    _activatable = null;

    # @type Vector3
    _rayCastOffset = null;
    _maxBridges = 20;
    _maxDistance = 10000;

    # @type List<ObjectSegment>
    _currentBridgePath = List();
    # @type List<ObjectSegment>
    _previousBridgePath = List();

    _once = false;

    function Initialize()
    {
        if (self.ActivatableID > 0)
        {
            activatableObj = Map.FindMapObjectByID(self.ActivatableID);
            if (activatableObj != null)
            {
                self._activatable = activatableObj.GetComponent("Activatable");
            }
        }

        self._rayCastOffset = self.MapObject.Right * 0.25;
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function OnTick()
    {
        if (self._activatable != null && !self._activatable.IsActive() || self._activatable == null && !self.Active)
        {
            if (!self._once)
            {
                self.deactivateBridges(0);
                self._previousBridgePath.Clear();
                self._once = true;
            }
            return;
        }

        self._once = false;

        self._currentBridgePath = List();

        startPos = self.MapObject.Position + self.MapObject.Forward * self.MapObject.Scale.Z / 2 + self.MapObject.Up * -0.2 + self.MapObject.Forward * 0.3;
        direction = self.MapObject.Forward;
        self.castBridge(startPos, direction, 0);

        differenceIndex = self._GetFirstDifferenceIndex(self._currentBridgePath, self._previousBridgePath);

        if (differenceIndex == -1)
        {
            return;
        }

        self.deactivateBridges(differenceIndex);
        self.updateBridges(differenceIndex);

        self._previousBridgePath = self._currentBridgePath;
    }

    function deactivateBridges(startIndex)
    {
        count = self._activeBridges.Count;
        for (i in Range(count - 1, startIndex - 1, -1))
        {
            bridge = self._activeBridges.Get(i);
            ObjectPoolManager.ReturnObjectToPool(ObjectPoolManager.HARD_LIGHT_BRIDGE, bridge);
            self._activeBridges.RemoveAt(i);
        }
    }

    function castBridge(startPos, direction, depth)
    {
        if (depth >= self._maxBridges)
        {
            return;
        }

        bridgeSegment = ObjectSegment();
        bridgeSegment.StartPos = startPos;
        bridgeSegment.Direction = direction;

        res = Physics.LineCast(
            startPos + self._rayCastOffset,
            startPos + (direction * self._maxDistance) + self._rayCastOffset,
            CollideWithEnum.All
        );
        bridgeSegment.HitResult = res;
        self._currentBridgePath.Add(bridgeSegment);

        if (self._currentBridgePath.Count > 1)
        {
            prevSegment = self._currentBridgePath.Get(self._currentBridgePath.Count - 2);
            currentSegment = self._currentBridgePath.Get(self._currentBridgePath.Count - 1);

            if (self._CanMergeSegments(prevSegment, currentSegment))
            {
                prevSegment.HitResult = currentSegment.HitResult;

                self._currentBridgePath.RemoveAt(self._currentBridgePath.Count - 1);
                self._currentBridgePath.RemoveAt(self._currentBridgePath.Count - 1);
                self._currentBridgePath.Add(prevSegment);
            }
        }

        if (res != null)
        {
            if (res.IsCharacter)
            {
                newStartPos = res.Point - self._rayCastOffset + (direction * 0.01);
                self.castBridge(newStartPos, direction, depth + 1);
            }
            elif (res.IsMapObject)
            {
                # @type MapObject
                mapObject = res.Collider;
                passThrough = mapObject.GetComponent("TargetPassThrough");
                if (passThrough != null && (passThrough.All || passThrough.HardLightBridges))
                {
                    newStartPos = res.Point - self._rayCastOffset + (direction * 0.01);
                    self.castBridge(newStartPos, direction, depth + 1);
                }
                else
                {
                    if (mapObject.Name == "Portal_BLUE_Visuals" || mapObject.Name == "Portal_ORANGE_Visuals")
                    {
                        # @type Portal
                        portalComp = null;
                        if (mapObject.Name == "Portal_BLUE_Visuals")
                        {
                            portalComp = mapObject.GetChild("Portal_BLUE").GetComponent("Portal");
                        }
                        else
                        {
                            portalComp = mapObject.GetChild("Portal_ORANGE").GetComponent("Portal");
                        }

                        if (portalComp != null && portalComp._related != null && portalComp._related.IsEnabled())
                        {
                            newStartPos = portalComp.CalculateRelatedPosition(res.Point);
                            newDirection = portalComp.CalculateRelatedDirection(direction);
                            self.castBridge(newStartPos + newDirection * 0.5, newDirection, depth + 1);
                        }
                    }
                }
            }
        }
    }

    function _CanMergeSegments(segmentA, segmentB)
    {
        if (self._IsPassThroughSegment(segmentA))
        {
            return true;
        }

        if (self._IsPortalSegment(segmentA))
        {
            return false;
        }

        return true;
    }

    function _IsPortalSegment(segment)
    {
        res = segment.HitResult;
        if (res != null && res.IsMapObject)
        {
            # @type MapObject
            mapObject = res.Collider;
            name = res.Collider.Name;
            if (name == "Portal_BLUE_Visuals" || name == "Portal_ORANGE_Visuals")
            {
                return true;
            }
        }
        return false;
    }

    function _IsPassThroughSegment(segment)
    {
        res = segment.HitResult;
        if (res != null)
        {
            if (res.IsCharacter)
            {
                return true;
            }
            elif (res.IsMapObject)
            {
                passThrough = res.Collider.GetComponent("TargetPassThrough");
                if (passThrough != null && (passThrough.All || passThrough.HardLightBridges))
                {
                    return true;
                }
            }
        }
        return false;
    }

    function updateBridges(startIndex)
    {
        for (i in Range(startIndex, self._currentBridgePath.Count, 1))
        {
            bridgeSegment = self._currentBridgePath.Get(i);
            bridge = ObjectPoolManager.GetObjectFromPool(ObjectPoolManager.HARD_LIGHT_BRIDGE);
            if (bridge == null)
            {
                return;
            }

            startPos = bridgeSegment.StartPos;
            direction = bridgeSegment.Direction.Normalized;
            res = bridgeSegment.HitResult;

            distance = self._maxDistance;
            if (res != null)
            {
                difference = startPos - res.Point;
                distance = difference.Magnitude;
            }

            bridge.Scale = Vector3(bridge.Scale.X, bridge.Scale.Y, distance + 0.1);
            bridge.Position = startPos + direction * (distance / 2.0);

            parentOffset = Vector3(0, 0, -90);

            # qParent = Quaternion.FromEuler(parentOffset);
            # qAlign = Quaternion.FromToRotation(self.MapObject.Forward, direction);
            # qFinal = qParent * qAlign;

            # bridge.Rotation = qFinal.Euler;
            bridge.Rotation = self._CalculateRotationStable(direction);

            if (self.MapObject.Up != direction && self.MapObject.Up != (direction * -1))
            {
                bridge.Rotation = bridge.Rotation - parentOffset;
            }

            # 0 0 0
            # 0 0 1
            # 0 0 1
            # 0 0 270

            # 0 270 0
            # -1 0 0
            # 0 0 1
            # 90 0 0
            # Game.Print("PARENT ROTATION: " + self.MapObject.Rotation);
            # Game.Print("PARENT FORWARD: " + self.MapObject.Forward);
            # Game.Print("PARENT UP: " + self.MapObject.Up);
            # Game.Print("DIRECTION FORWARD: " + direction);
            # Game.Print("CHILD FINAL ROTATION: " + bridge.Rotation);

            self._activeBridges.Add(bridge);
        }
    }

    function _GetFirstDifferenceIndex(path1, path2)
    {
        minCount = Math.Min(path1.Count, path2.Count);

        for (i in Range(0, minCount, 1))
        {
            segment1 = path1.Get(i);
            segment2 = path2.Get(i);

            if (!self._VectorsAreEqual(segment1.StartPos, segment2.StartPos) || !self._VectorsAreEqual(segment1.Direction, segment2.Direction))
            {
                return i;
            }

            res1 = segment1.HitResult;
            res2 = segment2.HitResult;

            if ((res1 == null && res2 != null) || (res1 != null && res2 == null))
            {
                return i;
            }

            if (res1 != null && res2 != null)
            {
                if (!self._VectorsAreEqual(res1.Point, res2.Point) || res1.Collider != res2.Collider)
                {
                    return i;
                }
            }
        }

        if (path1.Count != path2.Count)
        {
            return minCount;
        }

        return -1;
    }

    function _VectorsAreEqual(vec1, vec2)
    {
        return Vector3.Distance(vec1, vec2) < 0.001;
    }

    function _CalculateRotation(direction)
    {
        yaw = Math.Atan2(direction.X, direction.Z);
        pitch = Math.Asin(direction.Y) * -1;
        return Vector3(pitch, yaw, 0);
    }

    function _CalculateRotationStable(direction)
    {
        dir = direction.Normalized;
        currentUp = self.MapObject.Up;
        q = Quaternion.LookRotation(dir, currentUp);
        return q.Euler;
    }
}

component Turret
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component. Set to 0 to use the Active field instead.";

    Active = false;
    ActiveTooltip = "Determines whether the component is active. Ignored if ActivatableID is set.";

    ResetGroup = "";
    ResetGroupTooltip = "The group ID used to reset the turret. Leave empty if no reset group is required.";

    Static = false;
    StaticTooltip = "Determines whether the turret is non-functional and serves only as a map object.";

    _maxLasers = 100;
    _maxDistance = 1000;
    _maxHealth = 100;
    _health = 100;
    _fovOffsetDistance = 50.428;
    _humanUpOffset = 1.0;
    _laserWidth = 0.05;
    _laserColor = Color(255, 0, 72, 155);

    _preparationTime = 0.5;
    _damage = 10;
    _damageDelay = 0.15;
    _fireDamage = 15;
    _fireDamageDelay = 0.25;
    _flipTime = 1.0;

    _once = false;

    # State
    _foundHuman = false;
    _targetLocked = true;
    _onFire = false;
    _flipped = false;
    _broken = false;
    _exploded = false;

    _wasOnFire = false;
    _wasFoundHuman = false;
    _wasTargetLocked = false;
    _wasBroken = false;
    _wasExploded = false;
    _wasCarried = false;
    _wasFlipped = false;

    # @type List<LineRenderer>
    _activeLasers = List();
    # @type List<ObjectSegment>
    _currentLaserPath = List();
    # @type List<ObjectSegment>
    _previousLaserPath = List();

    _preparationTimer = Timer(0.5);
    _damageDelayTimer = Timer(0.0);
    _fireDamageDelayTimer = Timer(0.0);
    _flipTimer = Timer(1.0);
    # @type Dict<string,Dict<string,Transform>>
    _sounds = Dict();

    # @type MapObject
    _eyeObj = null;
    # @type MapObject
    _lightObj = null;
    # @type MapObject
    _fireFX = null;
    # @type TurretFOV
    _fovRef = null;
    # @type Movable
    _movableRef = null;
    # @type Activatable
    _activatable = null;
    # @type MapObject
    _soundManager = null;
    _soundsInited = false;

    _lastSoundTypePlayed = null;
    _lastSoundPlayed = null;

    _SOUND_TYPE_DROPPED = 0;
    _SOUND_TYPE_PICKED_UP = 1;
    _SOUND_TYPE_SHOT_BY_LASER = 2;
    _SOUND_TYPE_SEARCHING = 3;
    _SOUND_TYPE_TARGET_LOCKED = 4;
    _SOUND_TYPE_TARGET_LOST = 5;
    _SOUND_TYPE_DISABLED = 6;
    _SOUND_TYPE_RETIRED = 7;
    _SOUND_TYPE_TIPPED = 8;

    _inactiveOnce = false;

    _qualityLevel = 1;

    function Initialize()
    {
        if (self.ActivatableID > 0)
        {
            activatableObj = Map.FindMapObjectByID(self.ActivatableID);
            if (activatableObj != null)
            {
                self._activatable = activatableObj.GetComponent("Activatable");
            }
        }

        self._eyeObj = self.MapObject.GetChild("Turret_Eye");
        self._lightObj = self.MapObject.GetChild("Turret_Eye_Light");
        self._fireFX = self.MapObject.GetChild("Turret_Fire");

        if (self.Static)
        {
            return;
        }

        self._damageDelayTimer = Timer(0.0);
        self._preparationTimer = Timer(self._preparationTime);
        self._flipTimer = Timer(self._flipTime);
        self._fireDamageDelayTimer = Timer(0.0);

        self._movableRef = self.MapObject.GetComponent("Movable");
        # self._fovRef = self._eyeObj.GetChild("Turret_FOV").GetComponent("TurretFOV");

        if (!self._once && self.ResetGroup != "")
        {
            ResetManager.Add(self.ResetGroup, self);
            self._once = true;
        }

        self._InitSounds();
    }

    function Reset()
    {
        self._damageDelayTimer.Reset(0.0);
        self._preparationTimer.Reset(self._preparationTime);
        self._flipTimer.Reset(self._flipTime);
        self._fireDamageDelayTimer.Reset(0.0);

        self._DeactivateLasers(0);
        self._previousLaserPath.Clear();
        self._health = self._maxHealth;
        self._broken = false;
        self._exploded = false;
        self._onFire = false;
        self._fireFX.Active = false;

        self._wasOnFire = false;
        self._wasFoundHuman = false;
        self._wasBroken = false;
        self._wasExploded = false;
        self._wasCarried = false;

        self._inactiveOnce = false;

        if (self._movableRef != null && self._movableRef.IsCarried())
        {
            PlayerProxy.DropCarrying();
        }
    }

    function SetOnFire()
    {
        self._onFire = true;
    }

    function Explode()
    {
        Game.SpawnEffect(EffectNameEnum.ShifterThunder, self.MapObject.Position, Vector3.Zero, 0.5);
        Game.SpawnEffect(EffectNameEnum.Boom1, self.MapObject.Position, Vector3.Zero, 0.05);
        if (self._movableRef != null && self._movableRef.IsCarried())
        {
            PlayerProxy.DropCarrying();
        }
        self._exploded = true;
    }

    function PlaySound(type, sound)
    {
        if (!self._soundsInited)
        {
            return;
        }
        if (self._lastSoundPlayed != null)
        {
            self.StopSound(self._lastSoundTypePlayed, self._lastSoundPlayed);
        }

        if (sound != null)
        {
            self._sounds.Get(type).Get(sound).PlaySound();
            self._lastSoundTypePlayed = type;
            self._lastSoundPlayed = sound;
        }
        else
        {
            l = self._sounds.Get(type).Values;
            index = Random.RandomInt(0, l.Count - 1);
            l.Get(index).PlaySound();
            self._lastSoundTypePlayed = type;
            self._lastSoundPlayed = self._sounds.Get(type).Keys.Get(index);
        }
    }

    function StopSound(type, sound)
    {
        if (!self._soundsInited)
        {
            return;
        }
        t = self._sounds.Get(type).Get(sound);
        t.StopSound();
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function OnTick()
    {
        self.MapObject.Active = self.Active && (self._activatable == null || self._activatable.IsActive()) && !self._exploded;
        if (self.Static)
        {
            return;
        }

        self._fovRef.MapObject.Active = self.MapObject.Active;

        if (!self.Active || self._broken || self._exploded || (self._activatable != null && !self._activatable.IsActive()) || (self._activatable == null && !self.Active))
        {
            if (!self._inactiveOnce)
            {
                self._DeactivateLasers(0);
                self._previousLaserPath = List();
                self._lightObj.Active = false;
                self._inactiveOnce = true;

                if (self._broken != self._wasBroken)
                {
                    if (self._broken)
                    {
                        self._OnBroken();
                    }
                    self._wasBroken = self._broken;
                }

                if (self._exploded != self._wasExploded)
                {
                    if (self._exploded)
                    {
                        self._OnExploded();
                    }
                    self._wasExploded = self._exploded;
                }
            }

            return;
        }

        self._inactiveOnce = false;

        self._fovRef.MapObject.Position = self.MapObject.Position + (self.MapObject.Forward * self._fovOffsetDistance);
        self._fovRef.MapObject.Rotation = Quaternion.LookRotation(self._eyeObj.Right, self._eyeObj.Forward * -1).Euler;

        self._damageDelayTimer.UpdateOnTick();

        self._UpdateOnFireOnTick();
        self._UpdateFlippedOnTick();

        self._lightObj.Active = Main.QualityLevel >= self._qualityLevel;

        self._currentLaserPath = List();

        startPos = self._eyeObj.Position + (self._eyeObj.Forward * (self._eyeObj.Scale.Y / 2) + (self._eyeObj.Forward * 0.01));

        t = self._fovRef.GetTarget();
        if (t != null && !self._flipped)
        {
            difference = t.Position + (Vector3.Up * self._humanUpOffset) - startPos;
            direction = difference.Normalized;
        }
        else
        {
            direction = self.MapObject.Forward;
            self._preparationTimer.Reset(self._preparationTime);
        }

        self._foundHuman = false;
        self._CastLaser(startPos, direction, 0);
        if (t != null && !self._flipped && !self._foundHuman)
        {
            self._preparationTimer.Reset(self._preparationTime);
            self._currentLaserPath = List();
            direction = self.MapObject.Forward;
            self._CastLaser(startPos, direction, 0);
        }
        else
        {
            self._preparationTimer.UpdateOnTick();
        }

        differenceIndex = self._GetFirstDifferenceIndex(self._currentLaserPath, self._previousLaserPath);

        if (differenceIndex == -1)
        {
            return;
        }

        self._DeactivateLasers(differenceIndex);
        self._UpdateLasers(differenceIndex);

        self._previousLaserPath = self._currentLaserPath;

        if (self._onFire != self._wasOnFire)
        {
            if (self._onFire)
            {
                self._OnStartedBurning();
            }
            self._wasOnFire = self._onFire;
        }

        if (self._foundHuman != self._wasFoundHuman)
        {
            if (self._foundHuman)
            {
                self._OnTargetFound();
            }
            else
            {
                self._OnTargetLost();
            }
            self._wasFoundHuman = self._foundHuman;
        }

        if (self._targetLocked != self._wasTargetLocked)
        {
            if (self._targetLocked)
            {
                self._OnTargetLocked();
            }
            self._wasTargetLocked = self._targetLocked;
        }

        if (self._flipped != self._wasFlipped)
        {
            if (self._flipped)
            {
                self._OnFlipped();
            }
            self._wasFlipped = self._flipped;
        }

        if (self._movableRef != null)
        {
            carriedNow = self._movableRef.IsCarried();
            if (carriedNow != self._wasCarried)
            {
                if (carriedNow)
                {
                    self._OnPickedUp();
                }
                else
                {
                    self._OnDropped();
                }
                self._wasCarried = carriedNow;
            }
        }

        if (self._broken != self._wasBroken)
        {
            if (self._broken)
            {
                self._OnBroken();
            }
            self._wasBroken = self._broken;
        }

        if (self._exploded != self._wasExploded)
        {
            if (self._exploded)
            {
                self._OnExploded();
            }
            self._wasExploded = self._exploded;
        }
    }

    function _InitSounds()
    {
        self._soundManager = self.MapObject.GetChild("soundmanager_turret");
        if (self._soundManager == null)
        {
            return;
        }

        if (self._soundManager.Transform.GetTransform("turret_active_1") == null)
        {
            return;
        }

        soundsList = List();
        soundsList.Add("turret_pickup_1");
        soundsList.Add("turret_pickup_2");
        soundsList.Add("turret_pickup_3");
        soundsList.Add("turret_pickup_4");
        soundsList.Add("turret_pickup_5");
        soundsList.Add("turret_pickup_6");
        soundsList.Add("turret_pickup_7");
        soundsList.Add("turret_pickup_8");
        soundsList.Add("turret_pickup_9");
        soundsList.Add("turret_pickup_10");
        self._AddCustomSounds(self._SOUND_TYPE_PICKED_UP, soundsList);

        soundsList = List();
        soundsList.Add("turretlaunched01");
        soundsList.Add("turretlaunched02");
        soundsList.Add("turretlaunched03");
        soundsList.Add("turretlaunched04");
        soundsList.Add("turretlaunched05");
        soundsList.Add("turretlaunched06");
        soundsList.Add("turretlaunched07");
        soundsList.Add("turretlaunched08");
        soundsList.Add("turretlaunched09");
        soundsList.Add("turretlaunched10");
        soundsList.Add("turretlaunched11");
        self._AddCustomSounds(self._SOUND_TYPE_DROPPED, soundsList);

        soundsList = List();
        soundsList.Add("turretshotbylaser01");
        soundsList.Add("turretshotbylaser02");
        soundsList.Add("turretshotbylaser03");
        soundsList.Add("turretshotbylaser04");
        soundsList.Add("turretshotbylaser05");
        soundsList.Add("turretshotbylaser06");
        soundsList.Add("turretshotbylaser07");
        soundsList.Add("turretshotbylaser08");
        soundsList.Add("turretshotbylaser09");
        soundsList.Add("turretshotbylaser10");
        self._AddCustomSounds(self._SOUND_TYPE_SHOT_BY_LASER, soundsList);

        soundsList = List();
        soundsList.Add("turret_autosearch_1");
        soundsList.Add("turret_autosearch_2");
        soundsList.Add("turret_autosearch_3");
        soundsList.Add("turret_autosearch_4");
        soundsList.Add("turret_autosearch_5");
        soundsList.Add("turret_autosearch_6");
        self._AddCustomSounds(self._SOUND_TYPE_SEARCHING, soundsList);

        soundsList = List();
        soundsList.Add("turret_search_1");
        soundsList.Add("turret_search_2");
        soundsList.Add("turret_search_3");
        soundsList.Add("turret_search_4");
        self._AddCustomSounds(self._SOUND_TYPE_TARGET_LOST, soundsList);

        soundsList = List();
        soundsList.Add("turret_active_1");
        soundsList.Add("turret_active_2");
        soundsList.Add("turret_active_3");
        soundsList.Add("turret_active_4");
        soundsList.Add("turret_active_5");
        soundsList.Add("turret_active_6");
        soundsList.Add("turret_active_7");
        soundsList.Add("turret_active_8");
        self._AddCustomSounds(self._SOUND_TYPE_TARGET_LOCKED, soundsList);

        soundsList = List();
        soundsList.Add("turret_retire_1");
        soundsList.Add("turret_retire_2");
        soundsList.Add("turret_retire_3");
        soundsList.Add("turret_retire_4");
        soundsList.Add("turret_retire_5");
        soundsList.Add("turret_retire_6");
        soundsList.Add("turret_retire_7");
        self._AddCustomSounds(self._SOUND_TYPE_RETIRED, soundsList);

        soundsList = List();
        soundsList.Add("turret_disabled_1");
        soundsList.Add("turret_disabled_2");
        soundsList.Add("turret_disabled_3");
        soundsList.Add("turret_disabled_4");
        soundsList.Add("turret_disabled_5");
        soundsList.Add("turret_disabled_6");
        soundsList.Add("turret_disabled_7");
        soundsList.Add("turret_disabled_8");
        self._AddCustomSounds(self._SOUND_TYPE_DISABLED, soundsList);

        soundsList = List();
        soundsList.Add("turret_tipped_1");
        soundsList.Add("turret_tipped_2");
        soundsList.Add("turret_tipped_3");
        soundsList.Add("turret_tipped_4");
        soundsList.Add("turret_tipped_5");
        soundsList.Add("turret_tipped_6");
        self._AddCustomSounds(self._SOUND_TYPE_TIPPED, soundsList);

        self._soundsInited = true;
    }

    # @param type string
    # @param soundsList List(string)
    function _AddCustomSounds(type, soundsList)
    {
        dict = Dict();
        for (s in soundsList)
        {
            t = self._soundManager.Transform.GetTransform(s);
            dict.Set(s, t);
        }
        self._sounds.Set(type, dict);
    }

    function _DeactivateLasers(startIndex)
    {
        count = self._activeLasers.Count;
        for (i in Range(count - 1, startIndex - 1, -1))
        {
            laser = self._activeLasers.Get(i);
            # ObjectPoolManager.ReturnObjectToPool(ObjectPoolManager.TURRET_LASER, laser);
            ObjectPoolManager.ReturnLineRendererToPool(laser);
            self._activeLasers.RemoveAt(i);
        }
    }

    function _CastLaser(startPos, direction, depth)
    {
        if (depth >= self._maxLasers)
        {
            return;
        }

        laserSegment = ObjectSegment();
        laserSegment.StartPos = startPos;
        laserSegment.Direction = direction;

        res = Physics.LineCast(startPos, startPos + (direction * self._maxDistance), CollideWithEnum.All);
        laserSegment.HitResult = res;
        self._currentLaserPath.Add(laserSegment);

        if (self._currentLaserPath.Count > 1)
        {
            prevSegment = self._currentLaserPath.Get(self._currentLaserPath.Count - 2);
            currentSegment = self._currentLaserPath.Get(self._currentLaserPath.Count - 1);

            if (self._CanMergeSegments(prevSegment, currentSegment))
            {
                prevSegment.HitResult = currentSegment.HitResult;

                self._currentLaserPath.RemoveAt(self._currentLaserPath.Count - 1);
                self._currentLaserPath.RemoveAt(self._currentLaserPath.Count - 1);
                self._currentLaserPath.Add(prevSegment);
            }
        }

        if (res != null)
        {
            if (res.IsMapObject)
            {
                # @type MapObject
                mapObject = res.Collider;
                passThrough = mapObject.GetComponent("TargetPassThrough");
                if (passThrough != null && (passThrough.All || passThrough.TurretLasers))
                {
                    newStartPos = res.Point + direction * 0.01;
                    self._CastLaser(newStartPos, direction, depth + 1);
                }
                elif (mapObject.Name == "Portal_BLUE_Visuals" || mapObject.Name == "Portal_ORANGE_Visuals")
                {
                    if (mapObject.Name == "Portal_BLUE_Visuals")
                    {
                        portalComp = mapObject.GetChild("Portal_BLUE").GetComponent("Portal");
                    }
                    else
                    {
                        portalComp = mapObject.GetChild("Portal_ORANGE").GetComponent("Portal");
                    }

                    if (portalComp != null && portalComp._related != null && portalComp._related.IsEnabled())
                    {
                        newStartPos = portalComp.CalculateRelatedPosition(res.Point);
                        newDirection = portalComp.CalculateRelatedDirection(direction);
                        self._CastLaser(newStartPos + newDirection * -0.1, newDirection, depth + 1);
                    }
                }
            }
            elif (res.IsCharacter)
            {
                # @type Character
                char = res.Collider;
                if (char.IsMine)
                {
                    self._foundHuman = true;
                    if (self._preparationTimer.IsDone() && self._damageDelayTimer.IsDone())
                    {
                        self._targetLocked = true;
                        i = Random.RandomInt(0, 3);
                        if (i == 0){
                            sfx = HumanSoundEnum.APGShot1;
                            sfx2 = HumanSoundEnum.Death1;
                        } elif (i == 1) {
                            sfx = HumanSoundEnum.APGShot2;
                            sfx2 = HumanSoundEnum.Death5;
                        } elif (i == 2) {
                            sfx = HumanSoundEnum.APGShot3;
                            sfx2 = HumanSoundEnum.LimbHit;
                        } else {
                            sfx = HumanSoundEnum.APGShot4;
                            sfx2 = HumanSoundEnum.NapeHit;
                        }
                        SoundManager.Play(sfx);
                        SoundManager.Play(sfx2);
                        self._damageDelayTimer.Reset(self._damageDelay);
                        difference = res.Point - startPos;
                        PlayerProxy.GetCharacter().AddForce(difference.Normalized * 5.5, ForceModeEnum.Impulse);
                        PlayerProxy.GetDamaged("Turret", self._damage);
                    }
                }
                else
                {
                    newStartPos = res.Point + direction * 0.01;
                    self._CastLaser(newStartPos, direction, depth + 1);
                }
            }
        }
    }

    function _CanMergeSegments(segmentA, segmentB)
    {
        if (self._IsPassThroughSegment(segmentA))
        {
            return true;
        }

        if (self._IsPortalSegment(segmentA))
        {
            return false;
        }

        return true;
    }

    function _IsPortalSegment(segment)
    {
        res = segment.HitResult;
        if (res != null && res.IsMapObject)
        {
            name = res.Collider.Name;
            if (name == "Portal_BLUE_Visuals" || name == "Portal_ORANGE_Visuals")
            {
                return true;
            }
        }
        return false;
    }

    function _IsPassThroughSegment(segment)
    {
        res = segment.HitResult;
        if (res != null)
        {
            if (res.IsCharacter && !res.Collider.IsMine)
            {
                return true;
            }
            elif (res.IsMapObject)
            {
                passThrough = res.Collider.GetComponent("TargetPassThrough");
                if (passThrough != null && (passThrough.All || passThrough.TurretLasers))
                {
                    return true;
                }
            }
        }
        return false;
    }

    function _UpdateLasers(startIndex)
    {
        for (i in Range(startIndex, self._currentLaserPath.Count, 1))
        {
            laserSegment = self._currentLaserPath.Get(i);
            # laser = ObjectPoolManager.GetObjectFromPool(ObjectPoolManager.TURRET_LASER);
            laser = ObjectPoolManager.GetLineRendererFromPool();
            if (laser == null)
            {
                return;
            }

            laser.Enabled = true;
            laser.PositionCount = 2;
            laser.StartWidth = self._laserWidth;
            laser.EndWidth = self._laserWidth;
            laser.LineColor = self._laserColor;

            startPos = laserSegment.StartPos;
            direction = laserSegment.Direction;
            res = laserSegment.HitResult;

            if (res != null)
            {
                # distance = Vector3.Distance(startPos, res.Point);
                # laserRotation = self._CalculateRotation(direction);

                # laser.Scale = Vector3(laser.Scale.X, laser.Scale.Y, distance + 0.1);
                # laser.Position = startPos + direction * (distance / 2.0);
                # laser.Rotation = laserRotation;

                laser.SetPosition(0, startPos);
                laser.SetPosition(1, res.Point);

                self._activeLasers.Add(laser);
            }
            else
            {
                # laserRotation = self._CalculateRotation(direction);
                # laser.Scale = Vector3(laser.Scale.X, laser.Scale.Y, 10000);
                # laser.Position = startPos + direction * 5000 + self.MapObject.Up;
                # laser.Rotation = laserRotation;

                laser.SetPosition(0, startPos);
                laser.SetPosition(1, startPos + direction * self._maxDistance);

                self._activeLasers.Add(laser);
            }
        }
    }

    function _GetFirstDifferenceIndex(path1, path2)
    {
        minCount = Math.Min(path1.Count, path2.Count);

        for (i in Range(0, minCount, 1))
        {
            segment1 = path1.Get(i);
            segment2 = path2.Get(i);

            if (!self._VectorsAreEqual(segment1.StartPos, segment2.StartPos) || !self._VectorsAreEqual(segment1.Direction, segment2.Direction))
            {
                return i;
            }

            res1 = segment1.HitResult;
            res2 = segment2.HitResult;

            if ((res1 == null && res2 != null) || (res1 != null && res2 == null))
            {
                return i;
            }

            if (res1 != null && res2 != null)
            {
                if (!self._VectorsAreEqual(res1.Point, res2.Point) || res1.Collider != res2.Collider)
                {
                    return i;
                }
            }
        }

        if (path1.Count != path2.Count)
        {
            return minCount;
        }

        return -1;
    }

    function _VectorsAreEqual(vec1, vec2)
    {
        return Vector3.Distance(vec1, vec2) < 0.001;
    }

    function _CalculateRotation(direction)
    {
        yaw = Math.Atan2(direction.X, direction.Z);
        pitch = Math.Asin(direction.Y) * -1;
        return Vector3(pitch, yaw, 0);
    }

    function _UpdateFlippedOnTick()
    {
        if (self._movableRef == null || !self._movableRef.IsCarried())
        {
            angle = Vector3.Angle(self.MapObject.Up, Vector3.Up);
            if (angle > 90.0)
            {
                self._flipped = true;
                self._flipTimer.UpdateOnTick();
                if (self._flipTimer.IsDone())
                {
                    self._DeactivateLasers(0);
                    self._previousLaserPath.Clear();
                    self._lightObj.Active = false;
                    self._broken = true;
                    SoundManager.Play(HumanSoundEnum.ThunderspearLaunch);
                    return;
                }
                elif (self._damageDelayTimer.IsDone())
                {
                    i = Random.RandomInt(0, 3);
                    if (i == 0){
                        sfx = HumanSoundEnum.APGShot1;
                    } elif (i == 1) {
                        sfx = HumanSoundEnum.APGShot2;
                    } elif (i == 2) {
                        sfx = HumanSoundEnum.APGShot3;
                    } else {
                        sfx = HumanSoundEnum.APGShot4;
                    }
                    SoundManager.Play(sfx);
                    self._damageDelayTimer.Reset(self._damageDelay);
                }
            }
            else
            {
                self._flipped = false;
                self._flipTimer.Reset(self._flipTime);
            }
        }
        else
        {
            self._flipped = false;
            self._flipTimer.Reset(self._flipTime);
        }
    }

    function _UpdateOnFireOnTick()
    {
        self._fireDamageDelayTimer.UpdateOnTick();
        if (!self._onFire || !self._fireDamageDelayTimer.IsDone())
        {
            return;
        }

        self._health = Math.Max(0, self._health - self._fireDamage);
        self._fireFX.Active = true;
        self._fireDamageDelayTimer.Reset(self._fireDamageDelay);

        if (self._health <= 0)
        {
            self.Explode();
            return;
        }
        self._OnGetDamageByBurn();
    }

    function _OnStartedBurning()
    {
        self.PlaySound(self._SOUND_TYPE_SHOT_BY_LASER, null);
    }

    function _OnGetDamageByBurn()
    {
    }

    function _OnBroken()
    {
        self.PlaySound(self._SOUND_TYPE_RETIRED, null);
    }

    function _OnExploded()
    {
        self.PlaySound(self._SOUND_TYPE_DISABLED, null);
    }

    function _OnTargetFound()
    {
        self.PlaySound(self._SOUND_TYPE_SEARCHING, null);
    }

    function _OnTargetLost()
    {
        self.PlaySound(self._SOUND_TYPE_TARGET_LOST, null);
    }

    function _OnTargetLocked()
    {
        self.PlaySound(self._SOUND_TYPE_TARGET_LOCKED, null);
    }

    function _OnPickedUp()
    {
        self.PlaySound(self._SOUND_TYPE_PICKED_UP, null);
    }

    function _OnDropped()
    {
        self.PlaySound(self._SOUND_TYPE_DROPPED, null);
    }

    function _OnFlipped()
    {
        self.PlaySound(self._SOUND_TYPE_TIPPED, null);
    }
}

component TurretFOV
{
    # @type Human
    _target = null;
    _resetTimer = Timer(0.0);
    _resetTime = 0.1;

    function Initialize()
    {
        self._resetTimer = Timer(0.0);
    }

    # @param obj any
    function OnCollisionStay(obj)
    {
        if (obj.Type != ObjectTypeEnum.HUMAN || !obj.IsMine)
        {
            return;
        }

        self._target = obj;
        self._resetTimer.Reset(0.1);
    }

    function OnTick()
    {
        if (!self.MapObject.Active)
        {
            return;
        }

        self._resetTimer.UpdateOnTick();
        if (self._target == null || !self._resetTimer.IsDone())
        {
            return;
        }

        self._target = null;
    }

    # @return Human
    function GetTarget()
    {
        return self._target;
    }
}

component WireMonitor
{
    ButtonID = 0;
    ButtonIDTooltip = "The ID of an object with an Activatable component.";

    # @type List<MapObject>
    _xMarkObjects = List();
    # @type List<MapObject>
    _vMarkObjects = List();

    # @type Activatable
    _activatable = null;

    _previousActive = false;

    # @type Color
    _colorWhenActive = null;
    # @type Color
    _colorWhenInactive = null;
    # @type Color
    _colorMarkVisible = null;
    # @type Color
    _colorMarkInvisible = null;

    function Initialize()
    {
        self._colorWhenActive = Color("#" + ColorEnum.OrangePortal);
        self._colorWhenInactive = Color("#" + ColorEnum.BluePortal);
        self._colorMarkInvisible = Color(0,0,0,0);
        self._colorMarkVisible = Color(0,0,0,255);
        self._activatable = Map.FindMapObjectByID(self.ButtonID).GetComponent("Activatable");

        self._xMarkObjects.Clear();
        self._vMarkObjects.Clear();

        for (obj in self.MapObject.GetChildren())
        {
            if (obj.Name == "XPart")
            {
                self._xMarkObjects.Add(obj);
            }
            elif (obj.Name == "VPart")
            {
                self._vMarkObjects.Add(obj);
            }
        }

        self._previousActive = self._activatable.IsActive();
        self._ApplyColors(self._previousActive);
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function OnTick()
    {
        currentActive = self._activatable.IsActive();
        if (currentActive == self._previousActive)
        {
            return;
        }
        self._ApplyColors(currentActive);
        self._previousActive = currentActive;
    }

    function _ApplyColors(isActive)
    {
        if (isActive)
        {
            self.MapObject.Color = self._colorWhenActive;
            for (obj in self._vMarkObjects)
            {
                obj.Color = self._colorMarkVisible;
            }
            for (obj in self._xMarkObjects)
            {
                obj.Color = self._colorMarkInvisible;
            }
        }
        else
        {
            self.MapObject.Color = self._colorWhenInactive;
            for (obj in self._vMarkObjects)
            {
                obj.Color = self._colorMarkInvisible;
            }
            for (obj in self._xMarkObjects)
            {
                obj.Color = self._colorMarkVisible;
            }
        }
    }
}

component Wire
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component.";

    _colorOn = Color();
    _colorOff = Color();
    # @type Activatable
    _activatable = null;

    function OnGameStart()
    {
        self._colorOn = Color("#" + ColorEnum.OrangePortal);
        self._colorOff = Color("#" + ColorEnum.BluePortal);
        self._activatable = Map.FindMapObjectByID(self.ActivatableID).GetComponent("Activatable");
    }

    function OnTick()
    {
        if (self._activatable.IsActive())
        {
            self.MapObject.Color = self._colorOn;
        }
        else
        {
            self.MapObject.Color = self._colorOff;
        }
    }
}

component PortalGunModifier
{
    EnableOrange = true;
    EnableBlue = true;
    PlaySound = false;

    # @param obj any
    function OnCollisionEnter(obj)
    {
        if (obj.Type != ObjectTypeEnum.HUMAN || !obj.IsMine || PlayerProxy._weapon == null)
        {
            return;
        }

        if (PlayerProxy._weapon._isBlueAvailable == self.EnableBlue && PlayerProxy._weapon._isOrangeAvailable == self.EnableOrange)
        {
            return;
        }

        PlayerProxy._weapon._isBlueAvailable = self.EnableBlue;
        PlayerProxy._weapon._isOrangeAvailable = self.EnableOrange;
        if (self.PlaySound)
        {
            SoundManager.Play(HumanSoundEnum.Checkpoint);
        }
    }

    # @param obj any
    function OnCollisionStay(obj)
    {
        if (obj.Type != ObjectTypeEnum.HUMAN || !obj.IsMine || PlayerProxy._weapon == null)
        {
            return;
        }

        if (PlayerProxy._weapon._isBlueAvailable == self.EnableBlue && PlayerProxy._weapon._isOrangeAvailable == self.EnableOrange)
        {
            return;
        }

        PlayerProxy._weapon._isBlueAvailable = self.EnableBlue;
        PlayerProxy._weapon._isOrangeAvailable = self.EnableOrange;
        if (self.PlaySound)
        {
            SoundManager.Play(HumanSoundEnum.Checkpoint);
        }
    }
}

component LevelReset
{
    Group = "";
    GroupTooltip = "Group ID to reset all registered objects with the same ID.";

    # @param obj any
    function OnCollisionEnter(obj)
    {
        if (obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            ResetManager.Reset(self.Group);
        }
    }
}

component EmancipationGrill
{
    function OnCollisionEnter(obj)
    {
        self._HandleObject(obj);
    }

    # @param obj any
    function OnCollisionStay(obj)
    {
        if (obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            PlayerProxy._weapon.LockGunFor(Time.TickTime * 5);
        }
    }

    function _HandleObject(obj)
    {
        if (obj.Type == ObjectTypeEnum.HUMAN && obj.IsMine)
        {
            PlayerProxy.ResetPortals(true);
        }
        elif (obj.Type == ObjectTypeEnum.MAP_OBJECT)
        {
            comp = obj.GetComponent("Movable");
            if (comp != null)
            {
                comp.Reset();
                SoundManager.Play(HumanSoundEnum.BladeNape4Var1);
            }
        }
    }
}

component Radio
{
    ActivatableID = 0;
    # @type Transform
    _transform = null;
    # @type Activatable
    _activatable = null;
    _isPlaying = false;

    function OnGameStart()
    {
        self._transform = self.MapObject.Transform.GetTransform("looping_radio_mix");
        self._activatable = Map.FindMapObjectByID(self.ActivatableID).GetComponent("Activatable");
    }

    function OnSecond()
    {
        if (self._activatable == null || self._transform == null || self._activatable.IsActive() == self._isPlaying)
        {
            return;
        }

        if (self._activatable.IsActive() && !self._isPlaying)
        {
            self._transform.PlaySound();
            self._isPlaying = true;
        }
        elif (!self._activatable.IsActive() && self._isPlaying)
        {
            self._transform.StopSound();
            self._isPlaying = false;
        }
    }
}

# This need to be refactored so bad
# It works somehow with tons of workarounds
# My brain is already melting...
component CubeDispencer
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component.";

    Reverse = false;
    ReverseTooltip = "If true, the behavior of this component activates when the Activatable is deactivated.";

    ResetGroup = "";
    ResetGroupTooltip = "The group ID used to reset the dispenser. Leave empty if no reset group is required.";

    Type = "WeightedStorageCube";
    TypeTooltip = "The type of cube dispensed by this component.";
    TypeDropbox = "WeightedStorageCube,WeightedCompanionCube,DiscouragementRedirectionCube";

    # @type MapObject
    _active = null;
    # @type Movable
    _activeMovable = null;
    # @type int
    _poolType = null;
    # @type Activatable
    _activatable = null;
    # @type MapObject
    _lidMapObject = null;
    # @type Activatable
    _regionActivatable = null;

    _activateOnce = false;
    _waitForCubeRelease = false;
    _pendingActivation = false;

    function Initialize()
    {
        if (self.Type == "WeightedStorageCube")
        {
            self._poolType = ObjectPoolManager.WEIGHTED_STORAGE_CUBE;
        }
        elif (self.Type == "WeightedCompanionCube")
        {
            self._poolType = ObjectPoolManager.WEIGHTED_COMPANION_CUBE;
        }
        else
        {
            self._poolType = ObjectPoolManager.DISCOURAGEMENT_REDIRECTION_CUBE;
        }

        if (!ObjectPoolManager.IsPoolInited(self._poolType))
        {
            ObjectPoolManager.CreatePool(self._poolType, CubeBuilder(self.Type), 5);
        }

        ResetManager.Add(self.ResetGroup, self);

        self._activatable = Map.FindMapObjectByID(self.ActivatableID).GetComponent("Activatable");
        self._lidMapObject = self.MapObject.GetChild("CubeDispenserHatch");
        self._regionActivatable = self.MapObject.GetChild("CubeDispenserRegionButton").GetComponent("Activatable");
    }

    function OnGameStart()
    {
        self.Initialize();
    }

    function OnTick()
    {
        if (self.MapObject.Active && self._active == null)
        {
            self.PrepareCube();
        }

        if (self._activatable.IsActive() != self.Reverse)
        {
            if (!self._activateOnce)
            {
                if (!self._regionActivatable.IsActive())
                {
                    self.FizzleCube();
                }
                self._activateOnce = true;
                self._pendingActivation = true;
            }
            elif (!self._pendingActivation && !self._waitForCubeRelease)
            {
                self._lidMapObject.Active = !self._regionActivatable.IsActive();
            }
        }
        else
        {
            if (self._activateOnce)
            {
                self._activateOnce = false;
                if (!self._regionActivatable.IsActive() && self.Reverse)
                {
                    self.FizzleCube();
                }
            }
            if (!self._pendingActivation)
            {
                self._lidMapObject.Active = true;
            }
        }

        if (self._pendingActivation)
        {
            if (self._regionActivatable.IsActive())
            {
                self._lidMapObject.Active = false;
                self._pendingActivation = false;
                self._waitForCubeRelease = true;
            }
        }

        if (self._waitForCubeRelease)
        {
            self._lidMapObject.Active = !self._regionActivatable.IsActive();
            self._waitForCubeRelease = self._regionActivatable.IsActive();
        }
    }

    function PrepareCube()
    {
        if (self._active != null)
        {
            return;
        }
        self._active = ObjectPoolManager.GetObjectFromPool(self._poolType);
        self._activeMovable = self._active.GetComponent("Movable");
        self._activeMovable._initPos = Vector3(
            self.MapObject.Position.X,
            self.MapObject.GetBoundsMin().Y + 3.0,
            self.MapObject.Position.Z
        );
        self._activeMovable.Reset();
        self._waitForCubeRelease = false;
    }

    function FizzleCube()
    {
        if (self._activeMovable != null)
        {
            self._activeMovable.Reset();
            self._waitForCubeRelease = false;
        }
    }

    function Reset()
    {
        if (self._active != null)
        {
            ObjectPoolManager.ReturnObjectToPool(self._poolType, self._active);
            self._active = null;
            self._activeMovable = null;
        }
        self._waitForCubeRelease = false;
        self._activateOnce = false;
        self._pendingActivation = false;
        self._lidMapObject.Active = true;
    }

    function OnDeactivate()
    {
        self.Reset();
    }
}

component WheatleyPositionLocker
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component.";

    # @type Activatable
    _activatable = null;
    # @type Movable
    _wheatleyMovable = null;

    function OnGameStart()
    {
        self._activatable = Map.FindMapObjectByID(self.ActivatableID).GetComponent("Activatable");
    }

    # @param obj any
    function OnCollisionEnter(obj)
    {
        if (!self._activatable.IsActive() || self._wheatleyMovable != null)
        {
            return;
        }

        if (obj.Type != ObjectTypeEnum.MAP_OBJECT && obj.Name != "Wheatley")
        {
            return;
        }

        # @type MapObject
        mapObject = obj;

        self._wheatleyMovable = mapObject.GetComponent("Movable");
        self._wheatleyMovable.LockPos(self.MapObject.Position);
    }

    function OnTick()
    {
        if (!self._activatable.IsActive() && self._wheatleyMovable != null)
        {
            self._wheatleyMovable.UnlockPos();
            self._wheatleyMovable = null;
        }
    }
}

#######################
## REFS
#######################

component LampRef
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component for culling. Set to 0 to disable culling behavior.";

    Intensity = 1.5;
    Range = 35.0;
    Type = "Triple";
    TypeDropbox = "Triple,QuadroCube";


    function OnGameStart()
    {
        if (self.Type == "Triple")
        {
            obj = Map.FindMapObjectByName("Lamp_Triple_Base");
        }
        elif (self.Type == "QuadroCube")
        {
            obj = Map.FindMapObjectByName("Lamp_QuadroCube_Base");
        }
        objC = Map.CopyMapObject(obj, true);
        light = objC.GetChild("Lamp_Light");
        # @type IPointLight
        lightC = light.GetComponent("PointLight");
        lightC.Intensity = self.Intensity;
        lightC.Range = self.Range;
        c = objC.AddComponent("ActiveControl");
        c.ActivatableID = self.ActivatableID;
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;
        c.Initialize();
    }
}

class IPointLight
{
    Intensity = 0.0;
    Range = 0.0;
}

component ObjectRef
{
    RefID = 0;
    RefIDTooltip = "The ID of the referenced object.";

    RefName = "";
    RefNameTooltip = "The name of the referenced object. Ignored if ID is not 0.";

    CullingActivatableID = 0;
    CullingActivatableIDTooltip = "The ID of an object with an Activatable component for culling. Set to 0 to disable culling behavior.";


    function OnGameStart()
    {
        if (self.RefID > 0)
        {
            obj = Map.FindMapObjectByID(self.RefID);
        }
        else
        {
            obj = Map.FindMapObjectByName(self.RefName);
        }
        c = Map.CopyMapObject(obj, true);
        c.Position = self.MapObject.Position;
        c.Rotation = self.MapObject.Rotation;

        if (self.CullingActivatableID > 0)
        {
            acComp = c.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }
    }
}

component LaserReceiverRef
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component that this component can activate. Leave 0 to use the Activatable component from the same object.";
    CullingActivatableID = 0;
    Type = "1";
    TypeDropbox = "1,2";

    function OnGameStart()
    {
        if (self.Type == "1")
        {
            obj = Map.FindMapObjectByName("LaserReceiver");
        }
        else
        {
            obj = Map.FindMapObjectByName("LaserReceiver2");
        }
        objC = Map.CopyMapObject(obj, true);
        objC.Active = true;
        c = objC.AddComponent("LaserReceiver");
        if (self.ActivatableID == 0)
        {
            self.ActivatableID = self.MapObject.ID;
        }
        c.ActivatableID = self.ActivatableID;
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;
        c.Initialize();

        if (self.CullingActivatableID > 0)
        {
            acComp = objC.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }
    }
}

component LaserSourceRef
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component. Set to 0 to use the Active field instead.";

    CullingActivatableID = 0;
    CullingActivatableIDTooltip = "The ID of an object with an Activatable component for culling. Set to 0 to disable culling behavior.";

    Active = false;
    ActiveTooltip = "Determines whether the component is active. Ignored if ActivatableID is set.";

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName("LaserSource");
        objC = Map.CopyMapObject(obj, true);
        objC.Active = true;
        c = objC.AddComponent("LaserSource");
        c.ActivatableID = self.ActivatableID;
        c.Active = self.Active;
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;
        c.Initialize();

        if (self.CullingActivatableID > 0)
        {
            acComp = objC.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }
    }
}

component HardLightBridgeRef
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component. Set to 0 to use the Active field instead.";

    CullingActivatableID = 0;
    CullingActivatableIDTooltip = "The ID of an object with an Activatable component for culling. Set to 0 to disable culling behavior.";

    Active = false;
    ActiveTooltip = "Determines whether the component is active. Ignored if ActivatableID is set.";

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName("HardLightBridgeSource");
        objC = Map.CopyMapObject(obj, true);
        objC.Active = true;
        c = objC.AddComponent("HardLightBridgeSource");
        c.ActivatableID = self.ActivatableID;
        c.Active = self.Active;
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;
        c.Initialize();

        if (self.CullingActivatableID > 0)
        {
            acComp = objC.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }
    }
}

component TurretRef
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component. Set to 0 to use the Active field instead.";

    Active = false;
    ActiveTooltip = "Determines whether the component is active. Ignored if ActivatableID is set.";

    Static = false;
    StaticTooltip = "Determines whether the turret is non-functional and serves only as a map object.";

    ResetGroup = "";
    ResetGroupTooltip = "The group ID used to reset the turret. Leave empty if no reset group is required.";

    Movable = true;
    MovableTooltip = "Indicates whether the turret can be picked up. Rigidbody will be applied regardless.";

    LockForward = true;
    LockForwardTooltip = "Specifies whether the turret should face the same direction as the player while being held.";

    Rigidbody = true;
    RigidbodyTooltip = "Indicates whether a rigidbody should be applied. This will always be applied if Movable is true.";

    Mass = 1.0;
    Gravity = Vector3(0, -20, 0);
    FreezeRotation = false;
    Interpolate = true;

    # @type MapObject
    _ref = null;

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName("Turret");
        self._ref = Map.CopyMapObject(obj, true);
        self._ref.Active = self.Active;
        self._ref.Position = self.MapObject.Position;
        self._ref.Rotation = self.MapObject.Rotation;

        if (self.Static)
        {
            return;
        }

        c = self._ref.AddComponent("Turret");
        c.ActivatableID = self.ActivatableID;
        c.Active = self.Active;
        c.Static = self.Static;
        c.ResetGroup = self.ResetGroup;

        c._fovRef = Map.CopyMapObject(
            Map.FindMapObjectByName("Turret_FOV"),
            false
        ).GetComponent("TurretFOV");


        if (self.Rigidbody || self.Movable)
        {
            # TODO: Rigidbody bug. Fix this.
            # self._ref.AddComponent("Rigidbody"); # This is working, fields are not mutable.
            rb = self._ref.AddRigidbody();
            # rb = self._ref.Rigidbody;
            rb.Mass = self.Mass;
            rb.Gravity = self.Gravity;
            rb.FreezeAllRotations = self.FreezeRotation;
            rb.Interpolate = self.Interpolate;
            # # @type IRigidbody
            # rb = self._ref.AddComponent("Rigidbody"); # This is working, fields are not mutable.
        }

        if (self.Movable)
        {
            m = self._ref.AddComponent("Movable");
            m.ResetGroup = self.ResetGroup;
            m.LockForward = self.LockForward;
            m.Initialize();
        }

        c.Initialize();
    }
}

component PortalReference
{
    Type = "Blue";
    TypeTooltip = "The type of portal to create.";
    TypeDropbox = "Blue,Orange";

    GroupID = "";
    GroupIDTooltip = "The group ID to associate with the portal. Required if portals are separated.";

    ButtonID = 0;
    ButtonIDTooltip = "The ID of an object with an Activatable component.";

    Separate = true;
    SeparateTooltip = "If true, creates a portal that is separate from player portals. Requires a GroupID.";

    Active = false;
    ActiveTooltip = "Determines whether the component is active. Ignored if ActivatableID is set.";

    # @type Activatable
    _activatable = null;
    _type = 0;
    _portalRef = null;
    _portalComp = null;
    _resetPos = Vector3(0, -99999, 0);

    function OnGameStart()
    {
        if (self.Type == "Blue")
        {
            self._type = PortalEnum.BLUE;
        }
        else
        {
            self._type = PortalEnum.ORANGE;
        }

        if (self.Separate)
        {
            gID = "Room_" + self.GroupID;

            PortalStorage.Add(gID);
            self._portalRef = PortalStorage.GetBaseObject(gID, self._type);
            self._portalComp = PortalStorage.GetPortalComponent(gID, self._type);

            if (self.Active)
            {
                self._portalRef.Position = self.MapObject.Position;
                self._portalRef.Rotation = self.MapObject.Rotation;
                self._portalComp.Enable();
            }
        }
        else
        {
            self._portalRef = PortalStorage.GetBaseObject(Network.MyPlayer.ID, self._type);
            self._portalComp = PortalStorage.GetPortalComponent(Network.MyPlayer.ID, self._type);
        }

        if (self.ButtonID > 0)
        {
            obj = Map.FindMapObjectByID(self.ButtonID);
            self._activatable = obj.GetComponent("Activatable");
        }
    }

    function OnSecond()
    {
        if (self._activatable == null)
        {
            return;
        }
        if (self._portalRef == null)
        {
            self._portalRef = PortalStorage.GetBaseObject(Network.MyPlayer.ID, self._type);
            self._portalComp = PortalStorage.GetPortalComponent(Network.MyPlayer.ID, self._type);
        }
    }

    function OnTick()
    {
        if (self._activatable == null || self._portalRef == null)
        {
            return;
        }

        if (self._activatable.IsActive())
        {
            self._portalRef.Position = self.MapObject.Position;
            self._portalRef.Rotation = self.MapObject.Rotation;
            self._portalComp.Enable();
            self.Active = true;
        } elif (self.Active != self._activatable.IsActive())
        {
            self._portalRef.Position = self._resetPos;
            self._portalComp.Disable();
            self.Active = false;
        }
    }
}

component WeightedButtonRef
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component that this component can activate. Set to 0 to use the Activatable component from the same object.";

    CullingActivatableID = 0;
    CullingActivatableIDTooltip = "The ID of an object with an Activatable component for culling. Set to 0 to disable culling behavior.";

    SlideVector = Vector3(0, -0.2, 0);
    AnimationDuration = 0.1;

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName("WeightedButton_Region_MOCK");
        objC = Map.CopyMapObject(obj, true);
        objC.Active = true;
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;
        wbComp = objC.AddComponent("WeightedButton");
        if (self.ActivatableID == 0)
        {
            self.ActivatableID = self.MapObject.ID;
        }
        wbComp.ActivatableID = self.ActivatableID;
        wbComp.Initialize();

        b = objC.GetChild("WeightedButton_Visuals_Button_MOCK");
        s = b.AddComponent("Slider");
        s.ButtonID = self.ActivatableID;
        s.SlideVector = self.SlideVector;
        s.AnimationDuration = self.AnimationDuration;

        if (self.CullingActivatableID > 0)
        {
            acComp = objC.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }
    }
}

component WheatleyRef
{
    ActivatableID = 0;
    LockPositionID = 0;
    Follow = true;
    ResetGroup = "";
    Movable = false;
    Controllable = false;
    Mass = 1.0;
    Gravity = Vector3(0, -20, 0);
    FreezeRotation = false;
    Interpolate = true;

    # @type MapObject
    _ref = null;
    # @type Follower
    _follower = null;
    # @type Movable
    _movable = null;
    # @type Controllable
    _controllable = null;

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName("Wheatley");
        objC = Map.CopyMapObject(obj, true);
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;
        if (self.Follow)
        {
            self._follower = objC.AddComponent("Follower");
            self._follower.Follow = self.Follow;
        }
        if (self.Movable)
        {
            # TODO: Rigidbody bug. Fix this.
            # objC.AddComponent("Rigidbody"); # This is working, fields are not mutable.
            rb = objC.AddRigidbody();
            # rb = objC.Rigidbody;
            rb.Mass = self.Mass;
            rb.Gravity = self.Gravity;
            rb.FreezeAllRotations = self.FreezeRotation;
            rb.Interpolate = self.Interpolate;
            # # @type IRigidbody
            # rb = objC.AddComponent("Rigidbody"); # This is working, fields are not mutable.
            
            self._movable = objC.AddComponent("Movable");
            self._movable.LockPositionID = self.LockPositionID;
            self._movable.ResetGroup = self.ResetGroup;
            self._movable.Initialize();
        }

        if (self.Controllable)
        {
            self._controllable = objC.AddComponent("Controllable");
            self._controllable.ResetGroup = self.ResetGroup;
            self._controllable.Initialize();
        }

        if (self.ActivatableID > 0)
        {
            acComp = objC.AddComponent("ActiveControl");
            acComp.ActivatableID = self.ActivatableID;
            acComp.Initialize();
        }

        self._ref = objC;
    }

    function OnSecond()
    {
        if (self._movable == null)
        {
            return;
        }

        self._follower.Follow = self.Follow && (self._movable.IsCarried() || self._movable.IsLocked());
    }

    # @param pos Vector3
    # @param t float
    function MoveTo(pos, t)
    {
        self._controllable.MoveTo(pos, t);
    }
}

component SlideDoorRef
{
    ButtonID = 0;
    CullingActivatableID = 0;
    Static = false;
    SlideVectorLeft = Vector3();
    SlideVectorRight = Vector3();
    AnimationDuration = 0.25;

    function OnGameStart()
    {
        objC = Map.CopyMapObject(Map.FindMapObjectByName("SlideDoor"), true);

        objC.Active = true;
        objC.Position = self.MapObject.Position - Vector3(0.0, 1.2, 0.0);
        objC.Rotation = self.MapObject.Rotation;

        if (self.CullingActivatableID > 0)
        {
            acComp = objC.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }

        if (self.Static)
        {
            return;
        }

        sp = objC.AddComponent("SoundPlayer");
        sp.ActivatableID = self.ButtonID;
        sp.ActivateSound = HumanSoundEnum.ReelIn;
        sp.DeactivateSound = HumanSoundEnum.ReelIn;
        sp.Initialize();

        for (child in objC.GetChildren())
        {
            if (child.Name == "SlideDoor_Left")
            {
                comp = child.GetComponent("Slider");
                comp.ButtonID = self.ButtonID;
                comp.AnimationDuration = self.AnimationDuration;
                comp.SlideVector = self.SlideVectorLeft;
            }
            elif (child.Name == "SlideDoor_Right")
            {
                comp = child.GetComponent("Slider");
                comp.ButtonID = self.ButtonID;
                comp.AnimationDuration = self.AnimationDuration;
                comp.SlideVector = self.SlideVectorRight;
            }
        }
    }
}

component SlideWallRef
{
    ActivatableID = 0;
    SlideVector = Vector3(0, 0, 0);
    AnimationDuration = 0.25;

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName("SlideWall");
        objC = Map.CopyMapObject(obj, true);
        objC.Active = true;
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;
        objC.Scale = self.MapObject.Scale;
        sComp = objC.AddComponent("Slider");
        sComp.ButtonID = self.ActivatableID;
        sComp.SlideVector = self.SlideVector;
        sComp.AnimationDuration = self.AnimationDuration;
    }
}

component LaunchPadRef
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component. Set to 0 to always be active.";

    CullingActivatableID = 0;
    CullingActivatableIDTooltip = "The ID of an object with an Activatable component for culling. Set to 0 to disable culling behavior.";

    Direction = Vector3(0, 1, 0);
    DirectionTooltip = "The direction of the launch force as a vector.";

    Force = 10.0;
    ForceTooltip = "The strength of the launch force applied to the object.";

    WaitForStop = true;
    WaitForStopTooltip = "Determines if the launch pad should wait for the player to stop moving before applying force.";

    LockMovementFor = 3.0;
    LockMovementForTooltip = "The duration (in seconds) during which movement is locked after the player is launched. This should be equal to or greater than the flight duration.";

    _ref = null;

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName("LaunchPad_Case");
        objC = Map.CopyMapObject(obj, true);
        objC.Active = true;
        reg = objC.GetChild("LaunchPad_Region");
        c = reg.AddComponent("LaunchPad");
        c.ActivatableID = self.ActivatableID;
        c.Direction = self.Direction;
        c.Force = self.Force;
        c.WaitForStop = self.WaitForStop;
        c.LockMovementFor = self.LockMovementFor;
        c.Initialize();
        self._ref = c;
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;

        if (self.CullingActivatableID > 0)
        {
            acComp = objC.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }
    }
}

component CompanionRef
{
    ActivatableID = 0;
    Type = "WeightedStorageCube";
    TypeDropbox = "WeightedStorageCube,WeightedCompanionCube,DiscouragementRedirectionCube";
    ResetGroup = "";
    Movable = true;
    LockForward = false;
    Rigidbody = true;
    Mass = 1.0;
    Gravity = Vector3(0, -20, 0);
    FreezeRotation = false;
    Interpolate = true;

    # @type MapObject
    _ref = null;
    # @type Activatable
    _activatable = null;
    _timer = Timer(3.0);

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName(self.Type);
        self._ref = Map.CopyMapObject(obj, true);
        self._ref.Active = true;

        pt = self._ref.AddComponent("TargetPassThrough");
        pt.All = false;
        pt.Portals = true;
        pt.HardLightBridges = true;

        # for (child in self._ref.GetChildren())
        # {
        #     pt = child.AddComponent("TargetPassThrough");
        #     pt.All = false;
        #     pt.Portals = true;
        #     pt.HardLightBridges = true;
        # }

        if (self.Rigidbody || self.Movable)
        {
            # TODO: Rigidbody bug. Fix this.
            # self._ref.AddComponent("Rigidbody"); # This is working, fields are not mutable.
            rb = self._ref.AddRigidbody();
            # rb = self._ref.Rigidbody;
            rb.Mass = self.Mass;
            rb.Gravity = self.Gravity;
            rb.FreezeAllRotations = self.FreezeRotation;
            rb.Interpolate = self.Interpolate;
            # # @type IRigidbody
            # rb = self._ref.AddComponent("Rigidbody"); # This is working, fields are not mutable.
        }

        self._ref.Position = self.MapObject.Position;
        self._ref.Rotation = self.MapObject.Rotation;
        if (self.Movable)
        {
            m = self._ref.AddComponent("Movable");
            m.ResetGroup = self.ResetGroup;
            m.LockForward = self.LockForward;
            m.Initialize();
        }

        if (self.ActivatableID > 0)
        {
            self._activatable = Map.FindMapObjectByID(self.ActivatableID).GetComponent("Activatable");
            acComp = self._ref.AddComponent("ActiveControl");
            acComp.ActivatableID = self.ActivatableID;
            acComp.Initialize();
        }
    }
}

component WireMonitorRef
{
    ButtonID = 0;
    ButtonIDTooltip = "The ID of an object with an Activatable component.";
    CullingActivatableID = 0;
    CullingActivatableIDTooltip = "The ID of an object with an Activatable component for culling. Set to 0 to disable culling behavior.";

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName("WireMonitor");
        objC = Map.CopyMapObject(obj, true);
        objC.Active = true;
        c = objC.AddComponent("WireMonitor");
        c.ButtonID = self.ButtonID;
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;
        c.Initialize();

        if (self.CullingActivatableID > 0)
        {
            acComp = objC.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }
    }
}

component TeleportReference
{
    Group = "Campaign";
    _pos = null;
    _rot = null;

    _teleportForTarget = null;
    _teleportForRotate = false;
    _teleportForTimer = Timer(0.0);

    function OnGameStart()
    {
        self._pos = self.MapObject.Position;
        self._rot = self.MapObject.Forward;
    }

    function OnTick()
    {
        self._teleportForTimer.UpdateOnTick();
        if (self._teleportForTimer.IsDone())
        {
            self._teleportForTarget = null;
            self._teleportForRotate = false;
            return;
        }
        self.Teleport(self._teleportForTarget, self._teleportForRotate);
    }

    function Teleport(obj, rotate)
    {
        obj.Position = self._pos;
        if (rotate && obj.Type == ObjectTypeEnum.HUMAN)
        {
            Camera.LookAt(Camera.Position + self._rot * 15.0);
        }
    }

    function TeleportFor(obj, rotate, time)
    {
        self._teleportForTimer.Reset(time);
        self._teleportForTarget = obj;
        self._teleportForRotate = rotate;
    }
}

component CubeDispencerRef
{
    ActivatableID = 0;
    ActivatableIDTooltip = "The ID of an object with an Activatable component.";

    CullingActivatableID = 0;
    CullingActivatableIDTooltip = "The ID of an object with an Activatable component for culling. Set to 0 to disable culling behavior.";

    Reverse = false;
    ReverseTooltip = "If true, the behavior of this component activates when the Activatable is deactivated.";

    ResetGroup = "";
    ResetGroupTooltip = "The group ID used to reset the dispenser. Leave empty if no reset group is required.";

    Type = "WeightedStorageCube";
    TypeTooltip = "The type of cube dispensed by this component.";
    TypeDropbox = "WeightedStorageCube,WeightedCompanionCube,DiscouragementRedirectionCube";

    # @type CubeDispencer
    _cdComp = null;

    function OnGameStart()
    {
        obj = Map.FindMapObjectByName("CubeDispenserMock");
        objC = Map.CopyMapObject(obj, true);
        objC.Active = true;
        objC.Position = self.MapObject.Position;
        objC.Rotation = self.MapObject.Rotation;
        reg = objC.GetChild("CubeDispenserRegionButton");
        objC.Scale = self.MapObject.Scale;

        ac = reg.AddComponent("Activatable");
        ac.Initialize();
        rbComp = reg.AddComponent("RegionButton");
        rbComp.DeactivateDelay = 0;
        rbComp.Reverse = false;
        rbComp.MyHuman = false;
        rbComp.MyCamera = false;
        rbComp.ResetGroup = "";
        rbComp.MapObjects = "";
        rbComp.Components = "Movable";
        rbComp.Once = false;
        rbComp.Initialize();

        if (self.CullingActivatableID > 0)
        {
            acComp = reg.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }

        self._cdComp = objC.AddComponent("CubeDispencer");
        self._cdComp.ActivatableID = self.ActivatableID;
        self._cdComp.Reverse = self.Reverse;
        self._cdComp.ResetGroup = self.ResetGroup;
        self._cdComp.Type = self.Type;
        self._cdComp.Initialize();

        if (self.CullingActivatableID > 0)
        {
            acComp = objC.AddComponent("ActiveControl");
            acComp.ActivatableID = self.CullingActivatableID;
            acComp.Initialize();
        }
    }
}

#######################
# CLASSES
#######################

class Timer
{
    # @type float
    _time = 0.0;
    _lastInitialTime = 0.0;

    # @param time float
    function Init(time)
    {
        self.Reset(time);
    }

    # @param decimals int
    # @return string
    function String(decimals)
    {
        return String.FormatFloat(self._time, decimals);
    }

    # @return float
    function GetTime()
    {
        return self._time;
    }

    # @return float
    function GetInitialTime()
    {
        return self._lastInitialTime;
    }

    # @return bool
    function IsDone()
    {
        return self._time <= 0.0;
    }

    # @param time float
    function Reset(time)
    {
        self._time = time;
        self._lastInitialTime = time;
    }

    function UpdateOnFrame()
    {
        self.update(Time.FrameTime);
    }

    function UpdateOnTick()
    {
        self.update(Time.TickTime);
    }

    function update(val)
    {
        self._time -= val;
    }
}

class Logger
{
    LogLevel = 0;
    Prefix = "";

    _traceColor = "e8e8e8";
    _debugColor = "00FFFF";
    _errorColor = "FF0000";
    _infoColor = "0000FF";

    _tracePrefix = "[TRACE]";
    _debugPrefix = "[DEBUG]";
    _errorPrefix = "[ERR]";
    _infoPrefix = "[INF]";

    function Init(logLevel, prefix)
    {
        self.LogLevel = logLevel;
        self.Prefix = prefix;
    }

    function Trace(msg)
    {
        if (self.LogLevel > -1)
        {
            return;
        }

        logLevelPrefix = HTML.Color(self._tracePrefix, self._traceColor);
        prefix = logLevelPrefix;
        if (self.Prefix != "")
        {
            prefix = logLevelPrefix + self.Prefix;
        }
        msg = prefix + " " + msg;
    }

    function Debug(msg)
    {
        if (self.LogLevel > 0)
        {
            return;
        }

        logLevelPrefix = HTML.Color(self._debugPrefix, self._debugColor);
        prefix = logLevelPrefix;
        if (self.Prefix != "")
        {
            prefix = logLevelPrefix + self.Prefix;
        }
        msg = prefix + " " + msg;
        Game.Print(msg);
    }

    function Error(msg)
    {
        if (self.LogLevel > 1)
        {
            return;
        }

        logLevelPrefix = HTML.Color(self._errorPrefix, self._errorColor);
        prefix = logLevelPrefix;
        if (self.Prefix != "")
        {
            prefix = logLevelPrefix + self.Prefix;
        }
        msg = prefix + " " + msg;
        Game.Print(msg);
    }

    function Info(msg)
    {
        if (self.LogLevel > 2)
        {
            return;
        }

        logLevelPrefix = HTML.Color(self._infoPrefix, self._infoColor);
        if (self.Prefix != "")
        {
            prefix = logLevelPrefix + self.Prefix;
        }
        prefix = logLevelPrefix;
        msg = prefix + " " + msg;
        Game.Print(msg);
    }
}

class KVProxy
{
    Key = "";
    Value = null;

    function Init(k, v)
    {
        self.Key = k;
        self.Value = v;
    }
}

class ObjectSegment
{
    # @type Vector3
    StartPos = null;
    # @type Vector3
    Direction = null;
    # @type LineCastHitResult
    HitResult = null;
}

class HumanTransformCache
{
    Human = null;
    Hip = null;
    # @type Transform
    Spine = null;
    # @type Transform
    Chest = null;
    # @type Transform
    GroundLeft = null;
    # @type Transform
    GroundRight = null;
    # @type Transform
    HandL = null;
    # @type Transform
    HandR = null;
    # @type Transform
    Head = null;
    # @type Transform
    Neck = null;
    # @type Transform
    ForearmL = null;
    # @type Transform
    ForearmR = null;
    # @type Transform
    UpperarmL = null;
    # @type Transform
    UpperarmR = null;
    # @type Transform
    HookLeftAnchorDefault = null;
    # @type Transform
    HookRightAnchorDefault = null;
    # @type Transform
    HookLeftAnchorGun = null;
    # @type Transform
    HookRightAnchorGun = null;
    ControllerBody = null;

    # @param human Human
    function Init(human)
    {
        self.Human = human.Transform;
        self.ControllerBody = human.Transform.GetTransform("Armature/Core/Controller_Body");
        self.Hip = human.Transform.GetTransform("Armature/Core/Controller_Body/hip");
        self.Spine = self.Hip.GetTransform("spine");
        self.Chest = self.Spine.GetTransform("chest");
        self.GroundLeft = human.Transform.GetTransform("GroundLeft");
        self.GroundRight = human.Transform.GetTransform("GroundRight");
        self.Neck = self.Chest.GetTransform("neck");
        self.Head = self.Neck.GetTransform("head");
        self.UpperarmL = self.Chest.GetTransform("shoulder_L/upper_arm_L");
        self.UpperarmR = self.Chest.GetTransform("shoulder_R/upper_arm_R");
        self.ForearmL = self.UpperarmL.GetTransform("forearm_L");
        self.ForearmR = self.UpperarmR.GetTransform("forearm_R");
        self.HandL = self.ForearmL.GetTransform("hand_L");
        self.HandR = self.ForearmR.GetTransform("hand_R");
        self.HookLeftAnchorDefault = self.Chest.GetTransform("hookRefL1");
        self.HookRightAnchorDefault = self.Chest.GetTransform("hookRefR1");
        self.HookLeftAnchorGun = self.HandL.GetTransform("hookRef");
        self.HookRightAnchorGun = self.HandR.GetTransform("hookRef");
    }
}

class RigidBodyAccelerationTracker
{
    # @type RigidbodyBuiltin
    _rb = null;
    _savedAcceleration = 0.0;

    # @type Timer
    _resetTimer = Timer(0.0);
    _resetTime = 0.3;

    # @parm rb RigidbodyBuiltin
    function Init(rb)
    {
        self._rb = rb;
    }

    function OnTick()
    {
        self._resetTimer.UpdateOnTick();
        if (self._resetTimer.IsDone())
        {
            self._savedAcceleration = 0.0;
        }

        currentAcceleration = self._rb.Velocity.Magnitude;

        if (currentAcceleration > 1.0)
        {
            if (self._savedAcceleration != currentAcceleration)
            {
                self._resetTimer.Reset(self._resetTime);
            }
            self._savedAcceleration = currentAcceleration;
        }
    }

    function GetAcceleration()
    {
        return self._savedAcceleration;
    }
}

class MapObjectPoolData
{
    # @type List<MapObject>
    pool = null;
    limit = 0;
    # @type CommonBuilder
    builder = null;

    # @param limit int
    # @param builder CommonBuilder
    function Init(limit, builder)
    {
        self.pool = List();
        self.limit = limit;
        self.builder = builder;
    }
}


#######################
## WEAPONS
#######################

class ProjectileData
{
    # @type MapObject
    Obj = null;
    # @type Vector3
    EndPos = Vector3(0.0);

    function Init(obj, endPos)
    {
        self.Obj = obj;
        self.EndPos = endPos;
    }
}

class PortalGun
{
    # @type Human
    _character = null;

    _cd = 0.1;
    _maxDistance = 1000.0;

    _objPositionLerpStep = 0.1;
    _objMinPositionLerp = 0.05;
    _objRotationLerp = 0.1;
    _objRotationSpeed = 60.0;
    _projectileSpeed = 180.0;
    _projectileRotationSpeed = 120.0;
    _objEndLerp = 0.05;
    _atomScaleLerp = 0.015;

    _hudDuration = 1.5;

    # @type MapObject
    _objRef = null;
    # @type MapObject
    _objEnd = null;
    _objEndIPos = Vector3(0.0);
    # @type MapObject
    _objAtom = null;
    _objAtomIScale = Vector3(0.0);
    _once = false;

    # @type List<ProjectileData>
    _activeProjectiles = List();
    _cdTimerBlue = Timer(0.0);
    _cdTimerOrange = Timer(0.0);

    _isBlueActive = false;
    _isOrangeActive = false;
    _isBlueAvailable = false;
    _isOrangeAvailable = false;

    _colorBlue = Color("#" + ColorEnum.BluePortal);
    _colorOrange = Color("#" + ColorEnum.OrangePortal);

    # @type Timer
    _lockGunTimer = null;

    function Init(char)
    {
        self._character = char;
        self._lockGunTimer = Timer(0.0);
        self._SetupWeaponAndKeys();
        self._SetupObjectPool();
        self._DisableArms();
    }

    function Destroy()
    {
        Input.SetKeyDefaultEnabled(InputManager.BluePortal, true);
        Input.SetKeyDefaultEnabled(InputManager.OrangePortal, true);
        Input.SetKeyDefaultEnabled(InputManager.ResetPortals, true);
        self._isBlueActive = false;
        self._isOrangeActive = false;
        self._objRef.Active = false;

        for (p in self._activeProjectiles)
        {
            ObjectPoolManager.ReturnObjectToPool(ObjectPoolManager.PORTALGUN_PROJECTILE, p.Obj);
        }
        self._activeProjectiles = List();
    }

    function OnFrame()
    {
        if (!self._isBlueAvailable && !self._isOrangeAvailable)
        {
            self._objRef.Active = false;
            return;
        }

        self._cdTimerBlue.UpdateOnFrame();
        self._cdTimerOrange.UpdateOnFrame();
        self._UpdateObject();
        self._UpdateProjectiles();
        self._HandleInput();
    }

    function OnTick()
    {
        self._lockGunTimer.UpdateOnTick();
    }

    # @param t float
    function LockGunFor(t)
    {
        self._lockGunTimer.Reset(t);
    }

    function _HandleInput()
    {
        if (Input.GetKeyDown(InputManager.BluePortal) && self._isBlueAvailable && self._cdTimerBlue.IsDone())
        {
            if (!self._lockGunTimer.IsDone())
            {
                self._RejectPortal(PortalEnum.BLUE);
                return;
            }
            self._ActivatePortal(PortalEnum.BLUE, null, null);
        }
        elif (Input.GetKeyDown(InputManager.OrangePortal) && self._isOrangeAvailable && self._cdTimerOrange.IsDone())
        {
            if (!self._lockGunTimer.IsDone())
            {
                self._RejectPortal(PortalEnum.ORANGE);
                return;
            }
            self._ActivatePortal(PortalEnum.ORANGE, null, null);
        }
        elif (Input.GetKeyDown(InputManager.ResetPortals) && (self._isBlueAvailable || self._isOrangeAvailable))
        {
            self.ResetPortals(false);
        }
    }

    function ResetPortals(force)
    {
        if (self._isBlueAvailable || force)
        {
            self._DisablePortal(PortalEnum.BLUE);
            self._isBlueActive = false;
        }

        if (self._isOrangeAvailable || force)
        {
            self._DisablePortal(PortalEnum.ORANGE);
            self._isOrangeActive = false;
        }

        SoundManager.Play(HumanSoundEnum.GasBurst);
    }

    function _SetupWeaponAndKeys()
    {
        self._character.SetWeapon(WeaponEnum.Thunderspear);
        self._character.SetSpecial(SpecialEnum.Potato);
        Input.SetKeyDefaultEnabled(InputManager.BluePortal, false);
        Input.SetKeyDefaultEnabled(InputManager.OrangePortal, false);
        Input.SetKeyDefaultEnabled(InputManager.ResetPortals, false);
    }

    function _SetupObjectPool()
    {
        if (!self._once)
        {
            self._objRef = ObjectPoolManager.GetObjectFromPool(ObjectPoolManager.PORTAL_GUN);
            self._objEnd = self._objRef.GetChild("PortalGunObjEnd");
            self._objEndIPos = self._objEnd.LocalPosition;
            self._objAtom = self._objRef.GetChild("PortalGunAtom");
            self._objAtomIScale = self._objAtom.Scale;
            self._once = true;
        }
    }

    function _DisableArms()
    {
        PlayerProxy._transformCache.UpperarmR.SetRenderersEnabled(false);
        PlayerProxy._transformCache.UpperarmL.SetRenderersEnabled(false);
        PlayerProxy._transformCache.Neck.SetRenderersEnabled(false);
    }

    function _ActivatePortal(t, startPos, distance)
    {
        if (startPos == null)
        {
            startPos = Camera.Position;
            distance = self._maxDistance;
        }

        direction = Camera.Forward.Normalized;
        endPos = startPos + direction * distance;

        self._PlayFireAnimation();

        res = Physics.LineCast(startPos, endPos, CollideWithEnum.MapObjects);
        if (res == null)
        {
            self._RejectPortal(t);
            return;
        }

        self._ProcessLineCastResult(t, res, direction, startPos, distance);
    }

    function _PlayFireAnimation()
    {
        self._objEnd.LocalPosition = self._objEndIPos;
        self._objEnd.Position = self._objEnd.Position + self._objRef.Up * -0.15;
        self._objAtom.Scale = Vector3(0.0);
    }

    function _ProcessLineCastResult(t, res, direction, startPos, distance)
    {
        passThrough = res.Collider.GetComponent("TargetPassThrough");
        if (
            (passThrough != null && (passThrough.All || passThrough.Portals))
            || (
                (res.Collider.Name == "Portal_ORANGE_Visuals" && t == PortalEnum.ORANGE)
                || (res.Collider.Name == "Portal_BLUE_Visuals" && t == PortalEnum.BLUE)
            )
        )
        {
            newStartPos = res.Point + direction * 0.01;
            newDistance = distance - Vector3.Distance(startPos, res.Point);
            if (newDistance > 0)
            {
                self._ActivatePortal(t, newStartPos, newDistance);
            }
            return;
        }

        if (res.Collider.GetComponent("PortalSurfaceable") != null)
        {
            self._PlacePortal(t, res);
        }
        else
        {
            self._RejectPortal(t);
        }
    }

    # @param t int
    # @param res LineCastHitResult
    function _PlacePortal(t, res)
    {
        id = self._character.Player.ID;
        portal = PortalStorage.GetBaseObject(id, t);
        if (portal == null) { return; }
        portal.Position = self._CalculatePortalPosition(res);
        portal.Rotation = self._CalculatePortalRotation(res);
        self._SpawnProjectile(t, res.Point);

        portalComponent = PortalStorage.GetPortalComponent(id, t);
        portalComponent.Enable();
        portalComponent.Animate();

        if (t == PortalEnum.BLUE)
        {
            self._isBlueActive = true;
            self._cdTimerBlue.Reset(self._cd);
            SoundManager.Play(HumanSoundEnum.HookRetractLeft);
        }
        elif (t == PortalEnum.ORANGE)
        {
            self._isOrangeActive = true;
            self._cdTimerOrange.Reset(self._cd);
            SoundManager.Play(HumanSoundEnum.HookRetractRight);
        }
    }

    function _RejectPortal(t)
    {
        SoundManager.Play(HumanSoundEnum.NoGas);
        if (t == PortalEnum.BLUE)
        {
            self._cdTimerBlue.Reset(self._cd);
        }
        elif (t == PortalEnum.ORANGE)
        {
            self._cdTimerOrange.Reset(self._cd);
        }
    }

    function _SpawnProjectile(t, endPos)
    {
        projectileObj = ObjectPoolManager.GetObjectFromPool(ObjectPoolManager.PORTALGUN_PROJECTILE);
        projectileObj.Active = true;
        projectileObj.Position = self._objRef.Position + self._objRef.Up;

        if (t == PortalEnum.BLUE)
        {
            projectileObj.Color = self._colorBlue;
        }
        elif (t == PortalEnum.ORANGE)
        {
            projectileObj.Color = self._colorOrange;
        }

        pFX = projectileObj.GetChild("PortalGunProjectileFX");
        pFX.Color = projectileObj.Color;

        projectile = ProjectileData(projectileObj, endPos);
        self._activeProjectiles.Add(projectile);
    }

    function _DisablePortal(t)
    {
        id = self._character.Player.ID;
        portal = PortalStorage.GetBaseObject(id, t);
        portal.Position = Vector3(0, -99999, 0);
        PortalStorage.GetPortalComponent(id, t).Disable();
    }

    function _UpdateObject()
    {
        self._objRef.Active = true;

        deltaTime = Time.FrameTime;

        currentPosition = self._objRef.Position;
        targetPosition = Camera.Position + Camera.Right * 0.45 + Camera.Up * -0.425 + Camera.Forward * 0.3;

        if (self._character.Velocity.Magnitude > 1.0)
        {
            targetPosition += Camera.Forward * 0.15;
        }

        distance = Vector3.Distance(currentPosition, targetPosition);
        lerpSpeed = Math.Max(10.0 + (distance * 150.0), 10.0) * deltaTime;
        self._objRef.Position = Vector3.Slerp(currentPosition, targetPosition, lerpSpeed);

        currentRotation = self._objRef.Rotation;
        targetRotation = Quaternion.LookRotation(Camera.Up * -1, Camera.Forward);

        rotationSpeed = 30.0 * deltaTime;
        self._objRef.Rotation = Quaternion.Slerp(Quaternion.FromEuler(currentRotation), targetRotation, rotationSpeed).Euler;

        lerpSpeedEnd = 7.5 * deltaTime;
        self._objEnd.LocalPosition = Vector3.Slerp(self._objEnd.LocalPosition, self._objEndIPos, lerpSpeedEnd);

        lerpSpeedScale = 2.5 * deltaTime;
        self._objAtom.Scale = Vector3.Slerp(self._objAtom.Scale, self._objAtomIScale, lerpSpeedScale);

        rotationDelta = Vector3(150.0, 150.0, 150.0) * deltaTime;
        self._objAtom.Rotation = self._objAtom.Rotation + rotationDelta;
    }

    function _UpdateProjectiles()
    {
        # @type List<ProjectileData>
        projectilesToRemove = List();
        for (projectile in self._activeProjectiles)
        {
            obj = projectile.Obj;

            deltaTime = Time.FrameTime;

            difference = projectile.EndPos - obj.Position;
            direction = difference.Normalized;
            moveDistance = self._projectileSpeed * deltaTime;

            if (Vector3.Distance(obj.Position, projectile.EndPos) <= moveDistance)
            {
                obj.Position = projectile.EndPos;
                projectilesToRemove.Add(projectile);
            }
            else
            {
                obj.Position = obj.Position + direction * moveDistance;
            }

            rotationDelta = Vector3(self._projectileRotationSpeed, self._projectileRotationSpeed, self._projectileRotationSpeed) * deltaTime;
            obj.Rotation = obj.Rotation + rotationDelta;
        }

        for (p in projectilesToRemove)
        {
            ObjectPoolManager.ReturnObjectToPool(ObjectPoolManager.PORTALGUN_PROJECTILE, p.Obj);
            self._activeProjectiles.Remove(p);
        }
    }

    # @param res LineCastHitResult
    # @return Vector3
    function _CalculatePortalRotation(res)
    {
        forward = res.Normal;

        angleUp   = Vector3.Angle(forward, Vector3.Up);
        angleDown = Vector3.Angle(forward, Vector3.Down);
        threshold = 10.0;
        isPortalVertical = false;
        if (angleUp < threshold || angleDown < threshold)
        {
            isPortalVertical = true;
        }

        if (isPortalVertical)
        {
            dotUpForward = Vector3.Dot(Camera.Up, forward);
            upOnPlane = Camera.Up - (forward * dotUpForward);
            if (upOnPlane.Magnitude < 0.001)
            {
                upOnPlane = Vector3.Up;
                dotUpForward = Vector3.Dot(upOnPlane, forward);
                upOnPlane = upOnPlane - (forward * dotUpForward);
            }
            upOnPlane = upOnPlane.Normalized;

            right = Vector3.Cross(forward, upOnPlane).Normalized;
            up = Vector3.Cross(right, forward).Normalized;
            return Quaternion.LookRotation(forward, up).Euler;
        }
        else
        {
            return Quaternion.LookRotation(forward, Vector3.Up).Euler;
        }
    }

    # @param res LineCastHitResult
    # @return Vector3
    function _CalculatePortalPosition(res)
    {
        portalSize = Vector3(2.5, 4, 0.1);
        halfWidth = portalSize.X / 2.0;
        halfHeight = portalSize.Y / 2.0;

        forward = res.Normal.Normalized;

        right = Vector3.Cross(Vector3.Up, forward).Normalized;
        up = Vector3.Cross(forward, right).Normalized;

        # @type List<Vector3>
        localCorners = List();
        # @type MapObject
        mapObject = res.Collider;
        for (corner in mapObject.GetCorners())
        {
            toCorner = corner - res.Point;

            localX = Vector3.Dot(toCorner, right);
            localY = Vector3.Dot(toCorner, up);
            localCorners.Add(Vector3(localX, localY, 0));
        }

        # for (child in res.Collider.GetChildren())
        # {
        #     if (child.GetComponent("PortableSurface") != null)
        #     {
        #         for (corner in child.GetCorners())
        #         {
        #             toCorner = corner - res.Point;
        #             localX = Vector3.Dot(toCorner, right);
        #             localY = Vector3.Dot(toCorner, up);
        #             localCorners.Add(Vector3(localX, localY, 0));
        #         }
        #     }
        # }

        minX = Math.Infinity;
        maxX = Math.Infinity * -1;
        minY = Math.Infinity;
        maxY = Math.Infinity * -1;

        for (localCorner in localCorners)
        {
            if (localCorner.X < minX)
            {
                minX = localCorner.X;
            }
            if (localCorner.X > maxX)
            {
                maxX = localCorner.X;
            }
            if (localCorner.Y < minY)
            {
                minY = localCorner.Y;
            }
            if (localCorner.Y > maxY)
            {
                maxY = localCorner.Y;
            }
        }

        allowedMinX = minX + halfWidth;
        allowedMaxX = maxX - halfWidth;
        allowedMinY = minY + halfHeight;
        allowedMaxY = maxY - halfHeight;

        if (allowedMinX > allowedMaxX || allowedMinY > allowedMaxY)
        {
            # Surface small
            return res.Point;
        }

        desiredLocalX = 0;
        desiredLocalY = 0;

        clampedX = Math.Clamp(desiredLocalX, allowedMinX, allowedMaxX);
        clampedY = Math.Clamp(desiredLocalY, allowedMinY, allowedMaxY);

        correctedLocalPos = Vector3(clampedX, clampedY, 0);

        correctedWorldPos = res.Point + (right * correctedLocalPos.X) + (up * correctedLocalPos.Y);

        return correctedWorldPos;
    }
}

#######################
## ABILITIES
#######################

class Ability
{
    function OnTickHandler(){}

    function OnFrameHandler(){}
}

class AirMovementAbility
{
    # @type Human
    _owner = null;
    _force = 1.0;
    _forceType = ForceModeEnum.Force;
    _gravityEffect = 9.81;
    _maxAirSpeed = 15.0;
    _posOffset = Vector3(0, 0.5, 0);
    _zeroVec = Vector3(0, 0, 0);

    function Init(owner, forceMultiplier, forceType, gravityMultiplier, maxAirSpeed)
    {
        self._owner = owner;
        self._force *= forceMultiplier;
        self._forceType = forceType;
        self._gravityEffect = 9.81 * gravityMultiplier;
        self._maxAirSpeed = maxAirSpeed;
    }

    function SetDefaultSettings()
    {
        self._force = 50.0;
        self._forceType = ForceModeEnum.Force;
        self._gravityEffect = 9.81;
        self._maxAirSpeed = 15.0;
    }

    function SetQuakeSettings()
    {
        self._force = 10.0;
        self._forceType = ForceModeEnum.Impulse;
        self._gravityEffect = 9.81;
        self._maxAirSpeed = 15.0;
    }

    function SetPortalSettings()
    {
        self._force = 30.0;
        self._forceType = ForceModeEnum.Force;
        self._gravityEffect = 9.81 * 2.0;
        self._maxAirSpeed = 10.0;
    }

    function OnFrameHandler(){}

    function OnTickHandler()
    {
        if (PlayerProxy._movementLocked || self._owner.Grounded)
        {
            return;
        }

        if (self._gravityEffect != 0.0)
        {
            self._owner.AddForce(Vector3(0, self._gravityEffect * -1, 0), ForceModeEnum.Force);
        }

        if (
            !Input.GetKeyHold(InputGeneralEnum.Forward)
            && !Input.GetKeyHold(InputGeneralEnum.Back)
            && !Input.GetKeyHold(InputGeneralEnum.Left)
            && !Input.GetKeyHold(InputGeneralEnum.Right)
        )
        {
            return;
        }

        cameraForward = Camera.Forward.Normalized;
        cameraLeft = Vector3.Cross(cameraForward, Vector3(0, 1, 0)).Normalized;

        cameraForward = Vector3(cameraForward.X, 0, cameraForward.Z).Normalized;
        cameraLeft = Vector3(cameraLeft.X, 0, cameraLeft.Z).Normalized;

        movementForce = self._zeroVec;
        currentVelocity = self._owner.Velocity;

        forwardVelocity = Vector3.Dot(currentVelocity, cameraForward);
        leftVelocity = Vector3.Dot(currentVelocity, cameraLeft);

        if (Input.GetKeyHold(InputGeneralEnum.Forward))
        {
            if (forwardVelocity < self._maxAirSpeed)
            {
                movementForce += cameraForward * self._force;
            }
        }
        if (Input.GetKeyHold(InputGeneralEnum.Back))
        {
            if (forwardVelocity > self._maxAirSpeed * -1)
            {
                movementForce += cameraForward * self._force * -1;
            }
        }
        if (Input.GetKeyHold(InputGeneralEnum.Left))
        {
            if (leftVelocity < self._maxAirSpeed)
            {
                movementForce += cameraLeft * self._force;
            }
        }
        if (Input.GetKeyHold(InputGeneralEnum.Right))
        {
            if (leftVelocity > self._maxAirSpeed * -1)
            {
                movementForce += cameraLeft * self._force * -1;
            }
        }

        if (movementForce != self._zeroVec)
        {
            self._owner.AddForce(movementForce, self._forceType);
        }
    }
}

class BunnyHopAbility
{
    # @type Human
    _owner = null;
    _bunnyHopTimer = Timer(0.0);
    _landingVelocity = Vector3(0, 0, 0);
    _maxBunnyHopDelay = 0.1;
    _isInAir = false;
    _wasInAir = false;

    function Init(owner, maxBunnyHopDelay)
    {
        self._owner = owner;
        self._maxBunnyHopDelay = maxBunnyHopDelay;
    }

    function OnFrameHandler()
    {
        if (PlayerProxy._movementLocked)
        {
            return;
        }

        self._bunnyHopTimer.UpdateOnFrame();

        if (!Input.GetKeyHold(InputHumanEnum.Jump) || !self._bunnyHopTimer.IsDone())
        {
            return;
        }

        self._isInAir = !self._owner.Grounded;

        if (!self._isInAir && self._wasInAir)
        {
            self._landingVelocity = self._owner.Velocity;
            self._bunnyHopTimer.Reset(self._maxBunnyHopDelay);
        }

        self._wasInAir = self._isInAir;

        if (self._isInAir)
        {
            return;
        }

        velY = self._landingVelocity.Y;
        if (velY <= 0)
        {
            velY = 16.0;
        }

        reversedVelocity = Vector3(self._landingVelocity.X, velY, self._landingVelocity.Z);
        self._owner.Velocity = reversedVelocity;
        self._bunnyHopTimer.Reset(0.0);
        self._owner.PlaySound(HumanSoundEnum.Jump);
    }

    function OnTickHandler(){}
}

class JumpAbility
{
    _jumpForce = 10.0;
    _timer = Timer(0.0);
    _delay = Time.TickTime * 5;

    function Init(jumpForce)
    {
        self._jumpForce = jumpForce;
        Input.SetKeyDefaultEnabled(InputHumanEnum.Jump, false);
    }

    function Destroy()
    {
        Input.SetKeyDefaultEnabled(InputHumanEnum.Jump, true);
    }

    function GetName()
    {
        return "Jump";
    }

    function OnFrameHandler()
    {
        self._timer.UpdateOnFrame();
        if (PlayerProxy._movementLocked)
        {
            return;
        }

        h = PlayerProxy.GetCharacter();
        if (h == null)
        {
            return;
        }

        if (h.Grounded && self._timer.IsDone() && Input.GetKeyHold(InputHumanEnum.Jump))
        {
            h.AddForce(Vector3(0, self._jumpForce, 0), ForceModeEnum.Force);
            self._timer.Reset(self._delay);
        }
    }

    function OnTickHandler(){}
}

class ZoomAbility
{
    _fov = 30.0;
    _savedFOV = 115.0;
    _zooming = false;
    _targetFOV = 115.0;
    _currentFOV = 115.0;
    _transitionTime = 0.25;
    _transitionElapsed = 0.0;
    _isTransitioning = false;
    _currentFOVStart = 115.0;

    function Init(fov, defaultFOV)
    {
        self._fov = fov;
        self._savedFOV = defaultFOV;
        self._targetFOV = defaultFOV;
        self._currentFOV = defaultFOV;
        self._transitionElapsed = 0.0;
        self._isTransitioning = false;
        self._currentFOVStart = defaultFOV;
        Camera.SetFOV(self._currentFOV);
    }

    function Destroy()
    {
        Camera.SetFOV(self._savedFOV);
        self._targetFOV = self._savedFOV;
        self._currentFOV = self._savedFOV;
        self._transitionElapsed = 0.0;
        self._isTransitioning = false;
    }

    function OnFrameHandler()
    {
        if (Input.GetKeyDown(InputManager.Zoom))
        {
            self._SetTargetFOV(self._fov);
            Camera.SetFOV(self._fov);
            self._zooming = true;
        }
        elif (self._zooming && Input.GetKeyDown(InputManager.ZoomIn))
        {
            self._targetFOV = Math.Clamp(self._targetFOV - 15.0, self._fov, self._savedFOV);
            Camera.SetFOV(self._targetFOV);
            # self._SetTargetFOV(newTarget);
        }
        elif (self._zooming && Input.GetKeyDown(InputManager.ZoomOut))
        {
            self._targetFOV = Math.Clamp(self._targetFOV + 15.0, self._fov, self._savedFOV);
            Camera.SetFOV(self._targetFOV);
            # self._SetTargetFOV(newTarget);
        }
        elif (self._zooming && Input.GetKeyUp(InputManager.Zoom))
        {
            self._SetTargetFOV(self._savedFOV);
            self._zooming = false;
            Camera.SetFOV(self._savedFOV);
        }

        # self._HandleTransitionOnFrame();
    }

    function OnTickHandler(){}

    function _SetTargetFOV(newTargetFOV)
    {
        if (newTargetFOV != self._targetFOV)
        {
            self._currentFOVStart = self._currentFOV;
            self._targetFOV = Math.Clamp(newTargetFOV, self._fov, self._savedFOV);
            self._transitionElapsed = 0.0;
            self._isTransitioning = true;
        }
    }

    function _HandleTransitionOnFrame()
    {
        if (self._isTransitioning)
        {
            self._transitionElapsed += Time.FrameTime;
            t = Math.Clamp(self._transitionElapsed / self._transitionTime, 0.0, 1.0);
            self._currentFOV = Math.Lerp(self._currentFOVStart, self._targetFOV, t);
            Camera.SetFOV(self._currentFOV);

            if (t >= 1.0)
            {
                self._isTransitioning = false;
                self._currentFOV = self._targetFOV;
                Camera.SetFOV(self._currentFOV);
            }
        }
    }
}

#######################
## GENERAL
#######################

extension HumanTransformCacheExtension
{
    # @type Dict
    _cache = Dict();

    # @param human Human
    # @return HumanTransformCache
    function GetTransformCache(human)
    {
        if (self._cache.Contains(human))
        {
            return self._cache.Get(human);
        }
        cache = HumanTransformCache(human);
        self._cache.Set(human, cache);
        return cache;
    }

    # @param human Human
    function Add(human)
    {
        self._cache.Set(human, HumanTransformCache(human));
    }

    # @param human Human
    function Remove(human)
    {
        self._cache.Remove(human);
    }
}

#######################
# EXTENSIONS
#######################

#######################
## GENERAL
#######################

extension PlayerProxy
{
    SpeedRunMode = false;

    # @type Human
    _character = null;
    # @type HumanTransformCache
    _transformCache = null;
    # @type PortalGun
    _weapon = null;
    # @type List<Ability>
    _abilities = List();
    _velocityTimer = Timer(0.0);
    _movementLockTimer = Timer(0.0);
    _movementLocked = false;
    # @type Vector3
    _velocity = null;
    # @type Movable
    _carrying = null;
    _regenerationTimer = Timer(0.0);
    _timeBeforeRegeneration = 2.5;
    _regenerationStep = 15;
    _regenerationDelay = 0.45;
    _regenerationDelayTimer = Timer(0.0);
    _pickupDistance = 3.0;
    _isApertureScienceEmployee = false;

    function OnSpawn()
    {
        self._character = Network.MyPlayer.Character;
        self._transformCache = HumanTransformCache(self._character);
        if (self._character.Type == ObjectTypeEnum.HUMAN)
        {
            self._weapon = PortalGun(self._character);

            if (Main.AirMovementPreset != AirMovementPreset.NONE)
            {
                airMovement = AirMovementAbility(
                    self._character,
                    Main.AirMovementForceMultiplier / 100.0,
                    Main.AirMovementForceType,
                    Main.GravityMultiplier / 100.0,
                    Main.MaxAirSpeed / 100.0
                );

                if (Main.AirMovementPreset == AirMovementPreset.PORTAL)
                {
                    airMovement.SetPortalSettings();
                }
                self.AddAbility(airMovement);
            }


            if (Main.BunnyHop)
            {
                self.AddAbility(BunnyHopAbility(self._character, 0.2));
            }

            self.AddAbility(ZoomAbility(30.0, Main.FOV));

            self.ForceFPV();
            self.DisableGas();
            self.SetMaxHP(100);
            self.SetCurrentHP(100);
            self._character.CanDodge = false;

            if (Main.CustomSpeed > 0)
            {
                self.SetSpeed(Main.CustomSpeed, Main.CustomDodgeSpeed);
            }
        }
    }

    function OnDie()
    {
        self._character = null;
        self._transformCache = null;
        self._weapon.Destroy();
        self._weapon = null;
        self._abilities.Clear();
    }

    function OnSecond()
    {
        if (self._character == null)
        {
            return;
        }

        self.ForceFPV();
        self.DisableGas();
        if (Main.CustomSpeed > 0)
        {
            self.SetSpeed(Main.CustomSpeed, Main.CustomDodgeSpeed);
        }
    }

    function OnTick()
    {
        if (self._character == null)
        {
            return;
        }

        self.UpdateRegenerationOnTick();

        for (a in self._abilities)
        {
            a.OnTickHandler();
        }

        if (self._weapon != null)
        {
            self._weapon.OnTick();
        }

        self._velocityTimer.UpdateOnTick();
        if (!self._velocityTimer.IsDone())
        {
            # if (self._character.Velocity.Magnitude < self._velocity.Magnitude)
            if (self._character.Velocity.Magnitude < 0.1)
            {
                self._character.Velocity = self._velocity;
            }
        }
        else
        {
            self._velocity = null;
        }

        self._movementLockTimer.UpdateOnTick();
        if (self._movementLocked && self._movementLockTimer.IsDone())
        {
            self.UnlockMovement();
        }
    }

    function OnFrame()
    {
        if (self._character == null)
        {
            return;
        }

        PlayerAccelerationTracker.OnFrame();

        for (a in self._abilities)
        {
            a.OnFrameHandler();
        }

        self._weapon.OnFrame();

        if (Network.MyPlayer.Character.CurrentAnimation == HumanAnimationEnum.WallRun)
        {
            Network.MyPlayer.Character.PlayAnimation(HumanAnimationEnum.Air2, 0.00001);
            self.LockMovementFor(Time.FrameTime);
        }

        self._HandleInput();
    }

    function AddAbility(a)
    {
        self._abilities.Add(a);
    }

    function ResetPortals(force)
    {
        if (self._weapon == null)
        {
            return;
        }
        self._weapon.ResetPortals(force);
    }

    function ForceFPV()
    {
        Camera.SetCameraMode(CameraModeEnum.FPS);
        Camera.FollowDistance = 0.0;
    }

    function ForceFOV(v)
    {
        Camera.SetFOV(v);
    }

    function DisableGas()
    {
        self._character.CurrentGas = 0.0;
    }

    function SetMaxHP(hp)
    {
        self._character.MaxHealth = hp;
    }

    function SetCurrentHP(hp)
    {
        self._character.Health = hp;
    }

    function SetSpeed(spd, dodgeSpd)
    {
        if (self._character.State == HumanStateEnum.GroundDodge)
        {
            self._character.Speed = dodgeSpd;
        }
        else
        {
            self._character.Speed = spd;
        }
    }

    # @return Human
    function GetCharacter()
    {
        return self._character;
    }

    function SetVelocityFor(v, t)
    {
        self._velocity = v;
        self._velocityTimer.Reset(t);
    }

    function LockMovement()
    {
        if (self._movementLocked)
        {
            return;
        }
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Forward, false);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Back, false);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Left, false);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Right, false);
        # Input.SetKeyDefaultEnabled(InputHumanEnum.Jump, false);
        self._movementLocked = true;
    }

    function LockMovementFor(t)
    {
        self._movementLockTimer.Reset(t);
        if (self._movementLocked)
        {
            return;
        }
        self.LockMovement();
    }

    function UnlockMovement()
    {
        if (!self._movementLocked)
        {
            return;
        }
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Forward, true);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Back, true);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Left, true);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Right, true);
        # Input.SetKeyDefaultEnabled(InputHumanEnum.Jump, true);
        self._movementLocked = false;
    }

    function TeleportTo(obj)
    {
        if (self._character == null)
        {
            return;
        }

        self._character.Position = obj.Position;
        Camera.LookAt(Camera.Position + obj.Forward * 15.0);
    }

    function _HandleInput()
    {
        if (Input.GetKeyDown(InputManager.Interact))
        {
            if (self._carrying != null)
            {
                self.DropCarrying();
                return;
            }

            startPos = Camera.Position;
            res = self._CastPTAwareRay(startPos, Camera.Forward, self._pickupDistance);
            if (res == null)
            {
                return;
            }

            # @type MapObject
            mapObject = res.Collider;

            movable = mapObject.GetComponent("Movable");
            if (movable != null && movable.CanPickup())
            {
                self._carrying = movable;
                self._carrying.Pickup(self._character);
                return;
            }

            btn = mapObject.GetComponent("Button");
            if (btn != null)
            {
                btn.Activate();
                return;
            }
            return;
        }
        elif (Input.GetKeyDown(InputManager.SpeedRunGUI))
        {
            SpeedRunGUI.ShowUI();
            return;
        }
        elif (!self.SpeedRunMode)
        {
            if (Input.GetKeyDown(InputManager.SkipCutscene))
            {
                CutsceneManager.ResetTimer();
                return;
            }
            elif (Input.GetKeyDown(InputManager.TeleportGUI))
            {
                if (!Network.IsMasterClient && Network.MyPlayer.GetCustomProperty("TELEPORT_ACCESS") != 1){return;}
                TeleportGUI.ShowUI();
                return;
            }
        }
    }

    # @param startPos Vector3
    # @param direction Vector3
    # @param distance float
    # @return LineCastHitResult
    function _CastPTAwareRay(startPos, direction, distance)
    {
        endPos = startPos + direction * distance;
        res = Physics.LineCast(startPos, endPos, CollideWithEnum.MapObjects);
        if (res == null)
        {
            return null;
        }

        if (!res.IsMapObject)
        {
            return null;
        }

        # @type MapObject
        collider = res.Collider;

        pt = collider.GetComponent("TargetPassThrough");
        if (pt != null && pt.All)
        {
            return self._CastPTAwareRay(res.Point + direction * 0.1, direction, distance - Vector3.Distance(startPos, res.Point));
        }

        return res;
    }

    function DropCarrying()
    {
        if (self._carrying != null)
        {
            self._carrying.Drop();
            self._carrying = null;
        }
    }

    # @return Movable
    function GetCarrying()
    {
        return self._carrying;
    }

    # @param src string
    # @param dmg int
    function GetDamaged(src, dmg)
    {
        if (Main.GodMode || self._character == null)
        {
            return;
        }

        self._character.GetDamaged(src, dmg);
        self._regenerationTimer.Reset(self._timeBeforeRegeneration);
    }

    function UpdateRegenerationOnTick()
    {
        if (self._character == null)
        {
            return;
        }
        self._regenerationTimer.UpdateOnTick();
        self._regenerationDelayTimer.UpdateOnTick();
        if (self._character.Health >= self._character.MaxHealth || !self._regenerationTimer.IsDone() || !self._regenerationDelayTimer.IsDone())
        {
            return;
        }

        self._character.Health = Math.Min(self._character.Health + self._regenerationStep, self._character.MaxHealth);
        self._regenerationDelayTimer.Reset(self._regenerationDelay);
    }

    function SetIsApertureScienceEmployee(v)
    {
        self._isApertureScienceEmployee = v;
    }

    function IsApertureScienceEmployee()
    {
        return self._isApertureScienceEmployee;
    }
}

extension PlayerAccelerationTracker
{
    _savedAcceleration = 0.0;

    # @type Timer
    _resetTimer = Timer(0.0);
    _resetTime = 0.3;

    function OnFrame()
    {
        character = PlayerProxy.GetCharacter();

        self._resetTimer.UpdateOnFrame();
        if (self._resetTimer.IsDone() && character.Grounded)
        {
            self._savedAcceleration = 0.0;
        }

        currentAcceleration = character.Velocity.Magnitude;

        if (currentAcceleration > 1.0)
        {
            if (self._savedAcceleration != currentAcceleration)
            {
                self._resetTimer.Reset(self._resetTime);
            }
            self._savedAcceleration = currentAcceleration;
        }
    }

    function GetAcceleration()
    {
        return self._savedAcceleration;
    }
}

extension ButtonGroupStorage
{
    # @type Dict<string,List<Button>>
    _s = Dict();

    # @param k string
    # @param v Button
    function Add(k, v)
    {
        l = self._s.Get(k, List());
        l.Add(v);
        self._s.Set(k, l);
    }


    # @param k string
    # @return List<Button>
    function GetList(k)
    {
        return self._s.Get(k, List());
    }
}

extension PortalStorage
{
    _inited = false;

    _blueRef = null;
    _orangeRef = null;

    _portals = Dict();
    _bluePortalsComponents = Dict();
    _orangePortalsComponents = Dict();
    _bluePortalsVisuals = Dict();
    _orangePortalsVisuals = Dict();

    function Initialize()
    {
        if (self._inited)
        {
            return;
        }

        self._orangeRef = Map.FindMapObjectByName("Portal_ORANGE_Visuals");
        self._blueRef = Map.FindMapObjectByName("Portal_BLUE_Visuals");
        self._inited = true;
    }

    # @param id string
    function Add(id)
    {
        if (!self._inited)
        {
            self.Initialize();
        }

        if (self._portals.Contains(id))
        {
            return;
        }

        portalOrangeVisuals = Map.CopyMapObject(self._orangeRef, true);
        portalOrange = portalOrangeVisuals.GetChild("Portal_ORANGE");

        portalBlueVisuals = Map.CopyMapObject(self._blueRef, true);
        portalBlue = portalBlueVisuals.GetChild("Portal_BLUE");

        portalOrangeComponent = portalOrange.GetComponent("Portal");

        portalBlueComponent = portalBlue.GetComponent("Portal");

        portalOrangeComponent.UID = id;
        portalBlueComponent.UID = id;

        portalOrangeComponent.Initialize();
        portalBlueComponent.Initialize();

        portalOrangeComponent.SetRelated(portalBlueComponent);
        portalBlueComponent.SetRelated(portalOrangeComponent);

        self._orangePortalsComponents.Set(portalOrangeComponent.UID, portalOrangeComponent);
        self._bluePortalsComponents.Set(portalBlueComponent.UID, portalBlueComponent);

        self._orangePortalsVisuals.Set(portalOrangeComponent.UID, portalOrangeVisuals);
        self._bluePortalsVisuals.Set(portalBlueComponent.UID, portalBlueVisuals);

        self._portals.Set(id, true);
    }

    # @param id string
    function Remove(id)
    {
        portalComponent = self._orangePortalsComponents.Get(id, null);
        portalVisuals = self._orangePortalsVisuals.Get(id, null);
        Map.DestroyMapObject(portalVisuals, true);
        self._orangePortalsComponents.Remove(id);
        self._orangePortalsVisuals.Remove(id);

        portalComponent = self._bluePortalsComponents.Get(id, null);
        portalVisuals = self._bluePortalsVisuals.Get(id, null);
        Map.DestroyMapObject(portalVisuals, true);
        self._bluePortalsComponents.Remove(id);
        self._bluePortalsVisuals.Remove(id);
        self._portals.Remove(id);
    }

    # @param id string
    # @param t int
    # @return MapObject
    function GetBaseObject(id, t)
    {
        if (t == PortalEnum.BLUE)
        {
            return self._bluePortalsVisuals.Get(id, null);
        }
        elif (t == PortalEnum.ORANGE)
        {
            return self._orangePortalsVisuals.Get(id, null);
        }
    }

    # @param id string
    # @param t int
    # @return Portal
    function GetPortalComponent(id, t)
    {
        if (t == PortalEnum.BLUE)
        {
            return self._bluePortalsComponents.Get(id, null);
        }
        elif (t == PortalEnum.ORANGE)
        {
            return self._orangePortalsComponents.Get(id, null);
        }
    }
}

extension InputManager
{
    BluePortal = null;
    OrangePortal = null;
    ResetPortals = null;
    Interact = null;
    TeleportGUI = null;
    AdminPanelGUI = null;
    SkipCutscene = null;
    QualityPreset = null;
    Zoom = null;
    ZoomIn = null;
    ZoomOut = null;
    SpeedRunGUI = null;

    function InitKeybinds()
    {
        Input.SetKeyDefaultEnabled(InputHumanEnum.AttackDefault, false);
        Input.SetKeyDefaultEnabled(InputHumanEnum.AttackSpecial, false);
        Input.SetKeyDefaultEnabled(InputHumanEnum.Reload, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.ItemMenu, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.Function1, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.Function2, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.Function3, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.Function4, false);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.SkipCutscene, false);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.ChangeCamera, false);

        self.BluePortal = InputHumanEnum.AttackDefault;
        self.OrangePortal = InputHumanEnum.AttackSpecial;
        self.ResetPortals = InputHumanEnum.Reload;
        self.Interact = InputHumanEnum.HookRight;
        self.TeleportGUI = InputInteractionEnum.Function1;
        self.AdminPanelGUI = InputInteractionEnum.Function2;
        self.QualityPreset = InputInteractionEnum.Function3;
        self.SpeedRunGUI = InputInteractionEnum.Function4;
        self.SkipCutscene = InputGeneralEnum.SkipCutscene;
        self.Zoom = InputGeneralEnum.ChangeCamera;
        self.ZoomIn = InputHumanEnum.ReelOut;
        self.ZoomOut = InputHumanEnum.ReelIn;
    }

    function OnSpawn()
    {
        Input.SetKeyDefaultEnabled(InputHumanEnum.AttackDefault, false);
        Input.SetKeyDefaultEnabled(InputHumanEnum.AttackSpecial, false);
        Input.SetKeyDefaultEnabled(InputHumanEnum.Reload, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.ItemMenu, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.Function1, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.Function2, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.Function3, false);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.Function4, false);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.SkipCutscene, false);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.ChangeCamera, false);
    }

    function OnDie()
    {
        Input.SetKeyDefaultEnabled(InputHumanEnum.AttackDefault, true);
        Input.SetKeyDefaultEnabled(InputHumanEnum.AttackSpecial, true);
        Input.SetKeyDefaultEnabled(InputHumanEnum.Reload, true);
        Input.SetKeyDefaultEnabled(InputInteractionEnum.ItemMenu, true);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.SkipCutscene, true);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.ChangeCamera, true);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Forward, true);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Back, true);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Left, true);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Right, true);
    }
}

extension TeleportGUI
{
    ID = "teleport";
    Title = "Teleport";
    Width = 200;
    Height = 600;
    _inited = false;

    # @type Dict<string,Dict<string,TeleportReference>>
    _zonesByGroup = Dict();

    # @type List<string>
    _popups = List();

    function Initialize()
    {
        if (self._inited)
        {
            return;
        }

        UI.CreatePopup(self.ID, self.Title, self.Width, self.Height);
        self._popups.Add(self.ID);

        for (obj in Map.FindMapObjectsByComponent("TeleportReference"))
        {
            c = obj.GetComponent("TeleportReference");
            grp = c.Group;
            if (grp == "")
            {
                grp = "Unsorted";
            }

            groupDict = self._zonesByGroup.Get(grp, Dict());
            groupDict.Set(obj.Name, c);
            self._zonesByGroup.Set(grp, groupDict);
        }

        groupNames = List();
        for (grp in self._zonesByGroup.Keys)
        {
            groupNames.Add(grp);
        }
        groupNames.Sort();

        for (i in Range(0, groupNames.Count, 1))
        {
            grp = groupNames.Get(i);
            btnID = self.ID + ":group:" + grp;
            UI.AddPopupButton(self.ID, btnID, grp);

            childID = self.ID + "_group_" + grp;

            UI.CreatePopup(childID, grp, 200, 600);
            self._popups.Add(childID);

            groupDict = self._zonesByGroup.Get(grp, Dict());
            pointNames = List();
            for (pt in groupDict.Keys)
            {
                pointNames.Add(pt);
            }
            pointNames.Sort();

            for (j in Range(0, pointNames.Count, 1))
            {
                pointName = pointNames.Get(j);
                btnID = self.ID + ":point:" + grp + ":" + pointName;
                UI.AddPopupButton(childID, btnID, pointName);
            }
        }

        UIRouter.RegisterHandler(self);
        self._inited = true;
    }

    function ShowUI()
    {
        UI.ShowPopup(self.ID);
    }

    function HideUI()
    {
        for (k in self._popups)
        {
            UI.HidePopup(k);
        }
    }

    function CanHandleClick(btn)
    {
        return String.StartsWith(btn, self.ID + ":group:")
            || String.StartsWith(btn, self.ID + ":point:");
    }

    function OnButtonClick(btn)
    {
        if (!self._inited)
        {
            return;
        }

        if (String.StartsWith(btn, self.ID + ":group:"))
        {
            grp = String.Replace(btn, self.ID + ":group:", "");
            childID = self.ID + "_group_" + grp;
            UI.ShowPopup(childID);
            return;
        }

        if (String.StartsWith(btn, self.ID + ":point:"))
        {
            suffix = String.Replace(btn, self.ID + ":point:", "");
            parts = String.Split(suffix, ":");
            if (parts.Count < 2)
            {
                return;
            }
            grp = parts.Get(0);
            pointName = parts.Get(1);

            groupDict = self._zonesByGroup.Get(grp);
            c = groupDict.Get(pointName);

            PlayerProxy.ResetPortals(true);
            carried = PlayerProxy.GetCarrying();
            if (carried != null)
            {
                PlayerProxy.DropCarrying();
                carried.Reset();
            }

            c.TeleportFor(PlayerProxy.GetCharacter(), true, 0.1);
            self.HideUI();
        }
    }
}

extension AdminPanelGUI
{
    ID = "ap";
    Title = "Admin Panel";
    Width = 200;
    Height = 600;
    _inited = false;

    _tpZones = Dict();

    function Initialize()
    {
        if (!self._inited)
        {
            UIRouter.RegisterHandler(self);
        }

        UI.CreatePopup(self.ID, self.Title, self.Width, self.Height);
        for (p in Network.Players)
        {
            UI.AddPopupButton(self.ID, self.ID + ":" + Convert.ToString(p.ID), Convert.ToString(p.ID));
        }
        self._inited = true;
    }

    function CanHandleClick(btn)
    {
        return String.StartsWith(btn, self.ID + ":");
    }

    function ShowUI()
    {
        self.Initialize();
        UI.ShowPopup(self.ID);
    }

    function HideUI()
    {
        UI.HidePopup(self.ID);
    }

    function OnButtonClick(btn)
    {
        if (!self._inited)
        {
            return;
        }

        key = String.Replace(btn, self.ID + ":", "");

        target = null;
        for (p in Network.Players)
        {
            if (Convert.ToString(p.ID) == key)
            {
                target = p;
            }
        }

        if (target == null)
        {
            return;
        }

        Dispatcher.Send(target, TeleportAccessMessage.New(1));
    }
}

extension SpeedRunGUI
{
    ID = "speedrun";
    Title = "Speedrun";
    Width = 200;
    Height = 600;
    _inited = false;

    function Initialize()
    {
        if (self._inited)
        {
            return;
        }

        UI.CreatePopup(self.ID, self.Title, 200, 400);
        UI.AddPopupBottomButton(self.ID, self.ID + ":stop", "Stop");
        for (k in SpeedRunManager._spawnPointsByGroup.Keys)
        {
            UI.AddPopupButton(self.ID, self.ID + ":" + k, k);
        }

        UIRouter.RegisterHandler(self);

        self._inited = true;
    }

    function CanHandleClick(btn)
    {
        return String.StartsWith(btn, self.ID + ":");
    }

    function ShowUI()
    {
        UI.ShowPopup(self.ID);
    }

    function HideUI()
    {
        UI.HidePopup(self.ID);
    }

    # @param btn string
    function OnButtonClick(btn)
    {
        if (!self._inited)
        {
            MCLogger.Error("Not inited: " + self.ID);
            return;
        }

        key = String.Replace(btn, self.ID + ":", "");
        if (key == "stop")
        {
            SpeedRunManager.Reset();
            PlayerProxy.SpeedRunMode = false;
            Network.MyPlayer.SpawnPoint = null;
            PlayerProxy.GetCharacter().GetKilled("Speedrun Stopped");
            self.HideUI();
            return;
        }

        SpeedRunManager.Reset();
        sp = SpeedRunManager._spawnPointsByGroup.Get(key);
        PlayerProxy.SpeedRunMode = true;
        Network.MyPlayer.SpawnPoint = sp;
        PlayerProxy.GetCharacter().GetKilled("Speedrun Started");
        self.HideUI();
        return;
    }
}

extension ScoreboardManager
{
    function Initialize()
    {
        UI.SetScoreboardHeader("Chamber");
        UI.SetScoreboardProperty("scoreboard");
    }

    # @param n string
    function UpdateChamber(n)
    {
        Network.MyPlayer.SetCustomProperty("chamber", n);
        self.Update();
    }

    function Update()
    {
        chamber = Network.MyPlayer.GetCustomProperty("chamber");
        Network.MyPlayer.SetCustomProperty("scoreboard", chamber);
    }
}

extension EasterEggManager
{
    _dict = Dict();
    _foundCount = 0;
    _totalCount = 0;

    # @param name string
    function Register(name)
    {
        self._dict.Set(name, false);
        self._totalCount += 1;
    }

    # @param name string
    function SetFound(name)
    {
        if (self._dict.Get(name, false))
        {
            return;
        }

        self._dict.Set(name, true);
        self._foundCount += 1;
    }

    # @return int
    function GetTotal()
    {
        return self._totalCount;
    }

    # @return int
    function GetFound()
    {
        return self._foundCount;
    }
}

extension UIManager
{
    _topLeft = "";
    _topLeftActive = "";
    _topCenter = "";
    _topCenterActive = "";
    _topRight = "";
    _topRightActive = "";

    _middleLeft = "";
    _middleLeftActive = "";
    _middleCenter = "";
    _middleCenterActive = "";
    _middleRight = "";
    _middleRightActive = "";

    _bottomRight = "";
    _bottomRightActive = "";

    function OnSecond()
    {
        self._PrepareLabelsOnSecond();
    }

    function OnTick()
    {
        self._PrepareLabelsOnTick();
        self._UpdateLabels();
    }

    function _PrepareLabelsOnTick()
    {
        self._middleCenter = self._BuildCrosshair();
        self._middleRight = self._BuildSpeedrunWidget();
    }

    function _PrepareLabelsOnSecond()
    {
        easterEggsLabel = self._BuildEasterEggs();
        creditsLabel = self._BuildCredits();
        keyBindsLabel = self._BuildKeyBinds();
        self._topLeft = keyBindsLabel;
        self._topCenter = creditsLabel;
        self._topRight = easterEggsLabel;
        self._bottomRight = self._BuildNotes();
    }

    function _UpdateLabels()
    {
        if (self._topLeft != self._topLeftActive)
        {
            UI.SetLabel(UILabelEnum.TopLeft, self._topLeft);
            self._topLeftActive = self._topLeft;
        }

        if (self._topCenter != self._topCenterActive)
        {
            UI.SetLabel(UILabelEnum.TopCenter, self._topCenter);
            self._topCenterActive = self._topCenter;
        }

        if (self._topRight != self._topRightActive)
        {
            UI.SetLabel(UILabelEnum.TopRight, self._topRight);
            self._topRightActive = self._topRight;
        }

        if (self._middleLeft != self._middleLeftActive)
        {
            UI.SetLabel(UILabelEnum.MiddleLeft, self._middleLeft);
            self._middleLeftActive = self._middleLeft;
        }

        if (self._middleCenter != self._middleCenterActive)
        {
            UI.SetLabel(UILabelEnum.MiddleCenter, self._middleCenter);
            self._middleCenterActive = self._middleCenter;
        }

        if (self._middleRight != self._middleRightActive)
        {
             UI.SetLabel(UILabelEnum.MiddleRight, self._middleRight);
             self._middleRightActive = self._middleRight;
        }

        if (self._bottomRight != self._bottomRightActive)
        {
            UI.SetLabel(UILabelEnum.BottomRight, self._bottomRight);
            self._bottomRightActive = self._bottomRight;
        }
    }

    function _BuildEasterEggs()
    {
        str = I18n.Get("easter_eggs.title") + ": "
            + EasterEggManager.GetFound()
            + "/"
            + EasterEggManager.GetTotal();
        str = HTML.Color(HTML.Size(str, 24), ColorEnum.PastelCream);
        return str;
    }

    function _BuildCrosshair()
    {
        if (PlayerProxy._weapon == null)
        {
            return "";
        }

        if (!PlayerProxy._weapon._isBlueAvailable && !PlayerProxy._weapon._isOrangeAvailable)
        {
            return "";
        }

        if (PlayerProxy._weapon._isBlueActive)
        {
            bluePortalColor = ColorEnum.BluePortalDarker;
        }
        else
        {
            bluePortalColor = ColorEnum.BluePortal;
        }

        if (PlayerProxy._weapon._isOrangeAvailable)
        {
            if (PlayerProxy._weapon._isOrangeActive)
            {
                orangePortalColor = ColorEnum.OrangePortalDarker;
            }
            else
            {
                orangePortalColor = ColorEnum.OrangePortal;
            }
        }
        else
        {
            orangePortalColor = bluePortalColor;
        }

        return String.Newline
        + String.Newline
        + String.Newline
        + String.Newline
        + String.Newline
        + String.Newline
        + String.Newline
        + String.Newline
        + HTML.Size(HTML.Bold(
            HTML.Color("(", bluePortalColor)
            + "     "
            + "     "
            + HTML.Color(")", orangePortalColor)
        ), 48);
    }

    function _BuildKeyBinds()
    {
        str = "";

        if (Network.IsMasterClient)
        {
            str += String.Newline
                + "[" + Input.GetKeyName(InputManager.AdminPanelGUI) + "] " + HTML.Color(I18n.Get("input.admin_panel"), ColorEnum.PastelCream);
        }

        if (PlayerProxy._character != null)
        {
            if (!PlayerProxy.SpeedRunMode && Network.MyPlayer.GetCustomProperty("TELEPORT_ACCESS") == 1)
            {
                str += String.Newline
                    + "[" + Input.GetKeyName(InputManager.TeleportGUI) + "] " + HTML.Color(I18n.Get("input.teleport_gui"), ColorEnum.PastelCream);
            }

            str += String.Newline
                    + "[" + Input.GetKeyName(InputManager.SpeedRunGUI) + "] " + HTML.Color(I18n.Get("input.speedrun_gui"), ColorEnum.PastelCream);

            if (PlayerProxy._weapon != null)
            {
                if (PlayerProxy._weapon._isBlueAvailable)
                {
                    str += String.Newline
                        + "[" + Input.GetKeyName(InputManager.BluePortal) + "] " + HTML.Color(I18n.Get("input.portal_blue"), ColorEnum.BluePortal);
                }
                if (PlayerProxy._weapon._isOrangeAvailable)
                {
                    str += String.Newline
                    + "[" + Input.GetKeyName(InputManager.OrangePortal) + "] " + HTML.Color(I18n.Get("input.portal_orange"), ColorEnum.OrangePortal);
                }

                if (PlayerProxy._weapon._isBlueAvailable || PlayerProxy._weapon._isOrangeAvailable)
                {
                    str += String.Newline
                    + "[" + Input.GetKeyName(InputManager.ResetPortals) + "] " + HTML.Color(I18n.Get("input.reset_portals"), ColorEnum.PastelCream);
                }
            }

            str += String.Newline
                + "[" + Input.GetKeyName(InputManager.Interact) + "] " + HTML.Color(I18n.Get("input.interact"), ColorEnum.PastelCream);

            if (!PlayerProxy.SpeedRunMode)
            {
                str += String.Newline
                    + "[" + Input.GetKeyName(InputManager.SkipCutscene) + "] " + HTML.Color(I18n.Get("input.skip_cutscene"), ColorEnum.PastelCream);
            }
            str += String.Newline
                + "[" + Input.GetKeyName(InputManager.Zoom) + "] " + HTML.Color(I18n.Get("input.zoom"), ColorEnum.PastelCream);
            str += String.Newline
                + "[" + Input.GetKeyName(InputManager.ZoomIn) + "] / "+ "[" + Input.GetKeyName(InputManager.ZoomOut) + "] " + HTML.Color(I18n.Get("input.zoom_in_out"), ColorEnum.PastelCream);
        }

        str += String.Newline
                + "[" + Input.GetKeyName(InputManager.QualityPreset) + "] " + HTML.Color(I18n.Get("input.quality") + ": ", ColorEnum.PastelCream) + Main.QualityLevel;

        if (str != "")
        {
            str = I18n.Get("input.title") + str;
        }

        return str;
    }

    function _BuildCredits()
    {
        return HTML.Color(
                "Portal 2 Custom Logic & Map"
                + String.Newline
                + "by Jagerente"
            , ColorEnum.PastelCream);
    }

    function _BuildNotes()
    {
        return HTML.Color(
            I18n.Get("notes.settings")
            , ColorEnum.Orangered);
    }

    function _BuildSpeedrunWidget()
    {
        if (!PlayerProxy.SpeedRunMode)
        {
            return "";
        }

        return SpeedRunManager.GetTextLabel(6, 6);
    }
}

extension SpeedRunManager
{
    SpeedRunFinished = false;
    _currentSegments = Dict();
    _activeGroup = "";
    _activeSegment = "";
    _runTime = 0.0;
    _segmentStartTime = 0.0;

    # @type Dict<string,bool>
    _groups = Dict();
    # @type Dict<string,List<string>>
    _segmentsByGroup = Dict();
    # @type Dict<string,Vector3>
    _spawnPointsByGroup = Dict();

    # @type List<SpeedRunCheck>
    _components = List();

    function Initialize()
    {
        LocalBestManager.InitializeLocalBest(self._groups);

        # LeaderboardManager.InitializeLeaderboard();
    }

    function OnTick()
    {
        if (self._activeGroup != "")
        {
            self._runTime += Time.TickTime;
        }
    }

    # @param group string
    # @param segmentName string
    function RegisterSegment(group, segmentName)
    {
        self._groups.Set(group, true);
        segList = self._segmentsByGroup.Get(group, List());
        segList.Add(segmentName);
        segList.Sort();
        self._segmentsByGroup.Set(group, segList);
    }

    # @param c SpeedRunCheck
    function RegisterComponent(c)
    {
        self._components.Add(c);
    }

    # @param group string
    # @param pos Vector3
    function RegisterSpawnPoint(group, pos)
    {
        self._spawnPointsByGroup.Set(group, pos);
    }

    # @param group string
    # @param firstSegment string
    function StartSpeedrun(group, firstSegment)
    {
        self.SpeedRunFinished = false;

        self._activeGroup = group;
        self._runTime = 0.0;
        self._currentSegments.Clear();
        self._activeSegment = "";
        self._segmentStartTime = 0.0;
        self.StartSegment(firstSegment);
    }

    # @param group string
    function StopSpeedrun()
    {
        text = Network.MyPlayer.Name + " finished " + self._activeGroup + " speed run for " + String.FormatFloat(self._runTime, 2) + "s";
        text = HTML.Color(text, ColorEnum.PastelCream);
        Game.PrintAll(text);

        self.SpeedRunFinished = true;

        if (self._activeSegment != "")
        {
            self.EndSegment(self._activeSegment);
        }
        self.SaveResults();
        self._activeGroup = "";
    }

    # @param segmentName string
    function StartSegment(segmentName)
    {
        if (self._activeSegment != "")
        {
            self.EndSegment(self._activeSegment);
        }
        self._activeSegment = segmentName;
        self._segmentStartTime = self._runTime;
    }

    # @param segmentName string
    function EndSegment(segmentName)
    {
        self._currentSegments.Set(segmentName, self._runTime);
        self._activeSegment = "";
        self._segmentStartTime = 0.0;
    }

    function SaveResults()
    {
        runResult = self._BuildResult();

        LocalBestManager.SaveLocalBestResult(runResult);

        # LeaderboardManager.PublishResult(runResult);
    }

    function Reset()
    {
        self._currentSegments.Clear();
        self._activeGroup = "";
        self._activeSegment = "";
        self._runTime = 0.0;
        self._segmentStartTime = 0.0;
        self.SpeedRunFinished = false;

        for (c in self._components)
        {
            c.Reset();
        }
    }

    # @param group string
    function ClearLocalResults()
    {
        LocalBestManager.ClearLocalResults();
    }

    # function ClearLeaderboard()
    # {
    #     LeaderboardManager.ClearLeaderboardFile();
    # }

    _lastSavedLabel = "";

    # @param segmentsBefore int
    # @param segmentsAfter int
    # @return string
    function GetTextLabel(segmentsBefore, segmentsAfter)
    {
        if (self._activeGroup != "")
        {
            self._lastSavedLabel = self._BuildActiveRunText(segmentsBefore, segmentsAfter);
            return self._lastSavedLabel;
        }


        lastRun = LocalBestManager.GetLastRunResult();
        if (lastRun != null)
        {
            return self._BuildFinishedRunText(lastRun);
        }

        return self._lastSavedLabel;

        # return "No active speedrun" + String.Newline;
    }

    # @param segmentsBefore int
    # @param segmentsAfter int
    # @return string
    function _BuildActiveRunText(segmentsBefore, segmentsAfter)
    {
        currentVal = self._runTime;
        currentValStr = String.FormatFloat(currentVal, 2);

        bestRes = LocalBestManager.GetLocalBest(self._activeGroup);


        bestSegmentVal = 0.0;
        if (bestRes != null && self._activeSegment != "")
        {
            bestSegmentVal = bestRes.Segments.Get(self._activeSegment, 0.0);
        }

        colorForCurrentVal = "70BD66";
        if (bestSegmentVal > 0.0)
        {
            diff = currentVal - bestSegmentVal;
            if (diff > 0)
            {
                colorForCurrentVal = "BD7066";
            }
            elif (diff == 0)
            {
                colorForCurrentVal = "AAAAAA";
            }
            else
            {
                colorForCurrentVal = "70BD66";
            }
        }

        coloredCurrentVal = HTML.Color(currentValStr, colorForCurrentVal);

        bestTotalVal = "N/A";
        if (bestRes != null)
        {
            bestTotalVal = String.FormatFloat(bestRes.TotalTime, 2);
        }

        txt = "Current Time: " + coloredCurrentVal
            + String.Newline
            + "Best Time: " + bestTotalVal + String.Newline
            + String.Newline
            + "Segments:" + String.Newline;

        segList = self._segmentsByGroup.Get(self._activeGroup, List());
        currentIndex = -1;
        for (i in Range(0, segList.Count, 1))
        {
            if (segList.Get(i) == self._activeSegment)
            {
                currentIndex = i;
                break;
            }
        }

        startIndex = currentIndex - segmentsBefore;
        if (startIndex < 0)
        {
            startIndex = 0;
        }
        endIndex = currentIndex + segmentsAfter + 1;
        if (endIndex > segList.Count)
        {
            endIndex = segList.Count;
        }

        for (i in Range(startIndex, endIndex, 1))
        {
            segName = segList.Get(i);
            doneTime = self._currentSegments.Get(segName, -1.0);

            segBestVal = 0.0;
            if (bestRes != null)
            {
                segBestVal = bestRes.Segments.Get(segName, 0.0);
            }

            if (doneTime < 0.0)
            {
                if (segBestVal != 0.0)
                {
                    line = segName + ": " + String.FormatFloat(segBestVal, 2);
                }
                else
                {
                    line = segName + ": N/A";
                }
            }
            else
            {
                segTimeStr = String.FormatFloat(doneTime, 2);

                diffSeg = doneTime - segBestVal;
                diffAbs = diffSeg;
                if (diffAbs < 0)
                {
                    diffAbs = diffAbs * -1;
                }
                diffStr = String.FormatFloat(diffAbs, 2);

                signSeg = "+";
                colorSeg = "BD7066";

                if (segBestVal == 0.0)
                {
                    signSeg = "-";
                    colorSeg = "70BD66";
                }
                else
                {
                    if (diffSeg < 0)
                    {
                        signSeg = "-";
                        colorSeg = "70BD66";
                    }
                    if (diffSeg == 0)
                    {
                        signSeg = "";
                        colorSeg = "AAAAAA";
                    }
                }

                line = segName + ": " + segTimeStr;
                if (segBestVal != 0.0)
                {
                    line += " " + HTML.Color("(" + signSeg + diffStr + ")", colorSeg);
                }
                else
                {
                    line += " " + HTML.Color("(" + signSeg + segTimeStr + ")", colorSeg);
                }
            }

            if (i == currentIndex)
            {
                line = HTML.Color(line, "FFCC66");
            }

            txt += line + String.Newline;
        }
        return txt;
    }


    function _BuildFinishedRunText(runResult)
    {
        segmentRowLimit = 10;
        totalStr = String.FormatFloat(runResult.TotalTime, 2);
        bestTotalVal = totalStr;
        bestRun = LocalBestManager.GetLocalBest(runResult.Group);
        if (bestRun != null)
        {
            bestTotalVal = String.FormatFloat(bestRun.TotalTime, 2);
        }

        t = "Last Speedrun Result" + String.Newline
            + "Group: " + runResult.Group + String.Newline
            + "Total Time: " + totalStr + String.Newline
            + "Best Time: " + bestTotalVal + String.Newline
            + String.Newline
            + "Segments:" + String.Newline;
        segNames = List();
        for (segName in runResult.Segments.Keys)
        {
            segNames.Add(segName);
        }
        segCount = segNames.Count;
        row = 0;
        while (row < segmentRowLimit)
        {
            if (row >= segCount)
            {
                row = row + 1;
            }
            else
            {
                lineStr = "";
                col = 0;
                innerLoop = true;
                while (innerLoop)
                {
                    index = row + col * segmentRowLimit;
                    if (index >= segCount)
                    {
                        innerLoop = false;
                    }
                    else
                    {
                        segName = segNames.Get(index);
                        segTime = runResult.Segments.Get(segName, 0.0);
                        segTimeStr = String.FormatFloat(segTime, 2);
                        bestVal = 0.0;
                        if (bestRun != null)
                        {
                            bestVal = bestRun.Segments.Get(segName, 0.0);
                        }
                        bestValStr = null;
                        if (bestVal > 0.0)
                        {
                            bestValStr = String.FormatFloat(bestVal, 2);
                        }
                        else
                        {
                            bestValStr = "N/A";
                        }
                        diff = segTime - bestVal;
                        if (bestVal == 0.0)
                        {
                            diffSign = "-";
                            diffColor = "70BD66";
                            diffVal = String.FormatFloat(segTime, 2);
                        }
                        else
                        {
                            diffAbs = diff;
                            if (diffAbs < 0)
                            {
                                diffAbs = diffAbs * -1;
                            }
                            diffVal = String.FormatFloat(diffAbs, 2);
                            diffSign = "+";
                            diffColor = "BD7066";
                            if (diff < 0)
                            {
                                diffSign = "-";
                                diffColor = "70BD66";
                            }
                            if (diff == 0)
                            {
                                diffSign = "";
                                diffColor = "AAAAAA";
                            }
                        }
                        labelStr = segName + ": " + segTimeStr;
                        labelStr = labelStr + " / " + bestValStr;
                        if (bestVal > 0.0 || bestVal == 0.0)
                        {
                            labelStr = labelStr + " (" + HTML.Color(diffSign + diffVal, diffColor) + ")";
                        }
                        if (col == 0)
                        {
                            lineStr = labelStr;
                        }
                        else
                        {
                            lineStr = lineStr + "    " + labelStr;
                        }
                        col = col + 1;
                    }
                }
                t = t + lineStr + String.Newline;
                row = row + 1;
            }
        }
        return t;
    }

    # @return SpeedRunResult
    function _BuildResult()
    {
        r = SpeedRunResult();
        r.Group = self._activeGroup;
        r.TotalTime = self._runTime;
        r.Segments = self._currentSegments;
        return r;
    }
}

extension LocalBestManager
{
    _bestResultsByGroup = Dict();
    _lastRunResult = null;

    function InitializeLocalBest(groupsDict)
    {
        PersistentData.Clear();
        PersistentData.LoadFromFile("p2sres", true);

        for (g in groupsDict.Keys)
        {
            bestStr = PersistentData.GetProperty(g, null);
            if (bestStr != null)
            {
                tmpRes = SpeedRunResult();
                tmpRes.FromString(bestStr);
                if (tmpRes.Segments.Count < SpeedRunManager._segmentsByGroup.Get(g).Count)
                {
                    PersistentData.SetProperty(g, null);
                    PersistentData.SaveToFile("p2sres", true);
                }
                else
                {
                    self._bestResultsByGroup.Set(g, tmpRes);
                }
            }
        }
    }

    # @param runResult SpeedRunResult
    function SaveLocalBestResult(runResult)
    {
        self._lastRunResult = runResult;
        bestRes = self._bestResultsByGroup.Get(runResult.Group, null);
        if (bestRes == null || self._IsRunBetterThan(runResult, bestRes))
        {
            PersistentData.Clear();
            PersistentData.SetProperty(runResult.Group, runResult.ToString());
            PersistentData.SaveToFile("p2sres", true);
            self._bestResultsByGroup.Set(runResult.Group, runResult);
        }
    }

    function GetLastRunResult()
    {
        return self._lastRunResult;
    }

    # @param group string
    # @return SpeedRunResult
    function GetLocalBest(group)
    {
        return self._bestResultsByGroup.Get(group, null);
    }

    # @param group string
    function ClearLocalResultsForGroup(group)
    {
        if (self._bestResultsByGroup.Contains(group))
        {
            self._bestResultsByGroup.Remove(group);
        }

        PersistentData.Clear();
        PersistentData.LoadFromFile("p2sres", true);
        PersistentData.SetProperty(group, null);
        PersistentData.SaveToFile("p2sres", true);
    }

    function ClearLocalResults()
    {
        self._bestResultsByGroup.Clear();
        PersistentData.Clear();
        PersistentData.SaveToFile("p2sres", true);
    }

    # @param run1 SpeedRunResult
    # @param run2 SpeedRunResult
    # @return bool
    function _IsRunBetterThan(run1, run2)
    {
        return run1.TotalTime < run2.TotalTime;
    }
}

# extension LeaderboardManager
# {
#     # @type Dict
#     Results = null;

#     # @return void
#     function Initialize()
#     {
#         self.Results = Dict();

#         PersistentData.Clear();
#         PersistentData.LoadFromFile("p2slb", true);

#         storedRaw = PersistentData.GetProperty("Results", null);
#         if (storedRaw == null || storedRaw == "")
#         {
#             return;
#         }

#         loadedTopDict = Json.LoadFromString(storedRaw);
#         if (loadedTopDict == null)
#         {
#             return;
#         }

#         for (groupName in loadedTopDict.Keys)
#         {
#             groupDictRaw = loadedTopDict.Get(groupName, null);
#             if (groupDictRaw == null)
#             {
#                 continue;
#             }

#             groupDictObj = Dict();

#             for (playerName in groupDictRaw.Keys)
#             {
#                 runResultStr = groupDictRaw.Get(playerName, null);
#                 if (runResultStr == null)
#                 {
#                     continue;
#                 }
#                 tmpRes = SpeedRunResult();
#                 tmpRes.FromString(runResultStr);

#                 groupDictObj.Set(playerName, tmpRes);
#             }

#             self.Results.Set(groupName, groupDictObj);
#         }
#     }

#     # @param runResult SpeedRunResult
#     function PublishResult(runResult)
#     {
#         Dispatcher.Send(Network.MasterClient, SpeedRunResultsMessage.New(runResult));
#     }

#     # @param playerName string
#     # @param runResult SpeedRunResult
#     function UpdateLeaderboards(playerName, runResult)
#     {
#         if (self.Results == null)
#         {
#             self.Results = Dict();
#         }

#         groupName = runResult.Group;
#         groupDict = self.Results.Get(groupName, null);
#         if (groupDict == null)
#         {
#             groupDict = Dict();
#         }

#         oldRun = groupDict.Get(playerName, null);
#         if (oldRun == null)
#         {
#             groupDict.Set(playerName, runResult);
#             self.Results.Set(groupName, groupDict);
#             self._SaveAll();
#             return;
#         }

#         if (!self._IsRunBetterThan(runResult, oldRun))
#         {
#             return;
#         }

#         groupDict.Set(playerName, runResult);
#         self.Results.Set(groupName, groupDict);
#         self._SaveAll();
#     }

#     function ClearLeaderboardFile()
#     {
#         self.Results = Dict();
#         PersistentData.Clear();
#         PersistentData.SaveToFile("p2slb", true);
#     }

#     # @return Dict
#     function GetResults()
#     {
#         if (self.Results == null)
#         {
#             self.Results = Dict();
#         }
#         return self.Results;
#     }

#     # @param run1 SpeedRunResult
#     # @param run2 SpeedRunResult
#     # @return bool
#     function _IsRunBetterThan(run1, run2)
#     {
#         return run1.TotalTime < run2.TotalTime;
#     }

#     function _SaveAll()
#     {
#         topDictRaw = Dict();

#         for (groupName in self.Results.Keys)
#         {
#             groupDictObj = self.Results.Get(groupName, null);
#             if (groupDictObj == null)
#             {
#                 continue;
#             }

#             groupDictRaw = Dict();

#             for (playerName in groupDictObj.Keys)
#             {
#                 srObj = groupDictObj.Get(playerName, null);
#                 if (srObj == null)
#                 {
#                     continue;
#                 }

#                 srStr = srObj.ToString();
#                 groupDictRaw.Set(playerName, srStr);
#             }

#             topDictRaw.Set(groupName, groupDictRaw);
#         }

#         jsonStr = Json.SaveToString(topDictRaw);

#         PersistentData.Clear();
#         PersistentData.LoadFromFile("p2slb", true);
#         PersistentData.SetProperty("Results", jsonStr);
#         PersistentData.SaveToFile("p2slb", true);
#     }
# }

class SpeedRunResult
{
    Group = "";
    TotalTime = 0.0;
    Segments = Dict();

    # @param d Dict
    function FromDict(d)
    {
        self.Group = d.Get("group", null);
        self.TotalTime = d.Get("total_time", null);
        self.Segments = d.Get("segments", null);
    }

    # @return Dict
    function ToDict()
    {
        d = Dict();
        d.Set("group", self.Group);
        d.Set("total_time", self.TotalTime);
        d.Set("segments", self.Segments);
        return d;
    }

    # @param str string
    function FromString(str)
    {
        self.FromDict(Json.LoadFromString(str));
    }

    # @return string
    function ToString()
    {
        return Json.SaveToString(self.ToDict());
    }
}

#######################
## MISC
#######################

extension HTML
{
    function Color(str, color)
    {
        return "<color=#" + color + ">" + str + "</color>";
    }

    function Size(str, size)
    {
        return "<size=" + size + ">" + str + "</size>";
    }

    function Bold(str)
    {
        return "<b>" + str + "</b>";
    }

    function Italic(str)
    {
        return "<i>" + str + "</i>";
    }
}

extension SoundManager
{
    # @type MapObject
    _customManager = null;
    # @type Dict<string,Dict<string,Transform>>
    _levels = Dict();
    _customInited = false;

    function Initialize()
    {
        self._customManager = Map.FindMapObjectByName("soundmanager");
        if (self._customManager == null)
        {
            return;
        }

        if (self._customManager.GetTransform("Level_1-1-0") == null)
        {
            return;
        }
        self._customInited = true;

        levelName = "Level_1-1-0";
        sequencesList = List();
        sequencesList.Add("prehub06");
        sequencesList.Add("prehub08");
        sequencesList.Add("prehub10");
        sequencesList.Add("prehub11");
        sequencesList.Add("announcer_generated_status");
        sequencesList.Add("announcer_generated_as_guild");
        sequencesList.Add("announcer_generated_cube_button");
        sequencesList.Add("testchamber07");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-2-0";
        sequencesList = List();
        sequencesList.Add("good02");
        sequencesList.Add("announcer_generated_btn_interact");
        sequencesList.Add("prehub20");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-3-0";
        sequencesList = List();
        sequencesList.Add("sp_intro_03_intro12");
        sequencesList.Add("sp_intro_03_intro09");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-4-0";
        sequencesList = List();
        sequencesList.Add("prehub42");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-4-1";
        sequencesList.Add("testchamber09");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-5-0";
        sequencesList = List();
        sequencesList.Add("testchamber02");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-6-0";
        sequencesList = List();
        sequencesList.Add("testchamber10");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-6-1";
        sequencesList = List();
        sequencesList.Add("prehub17");
        sequencesList.Add("prehub18");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-7-0";
        sequencesList = List();
        sequencesList.Add("sp_intro_03_intro02");
        sequencesList.Add("demosphereintro04");
        sequencesList.Add("demosphereintro02");
        sequencesList.Add("demosphereintro07");
        sequencesList.Add("demosphereintro08");
        sequencesList.Add("demosphereintro09");
        sequencesList.Add("demosphereintro10");
        sequencesList.Add("demosphereintro11");
        sequencesList.Add("demosphereintro13");
        sequencesList.Add("demosphereintro14");
        sequencesList.Add("demosphereintro15");

        sequencesList.Add("raildropintro01");
        sequencesList.Add("demospherecatch02");
        sequencesList.Add("demospherecatch05");
        sequencesList.Add("demospherecatch07");
        sequencesList.Add("demospherefall04");
        sequencesList.Add("demospherethud03");
        sequencesList.Add("demospherethud06");

        sequencesList.Add("demospherefirstdoorwaysequence01");
        sequencesList.Add("demospherefirstdoorwaysequence04");
        sequencesList.Add("demospherefirstdoorwaysequence05");
        sequencesList.Add("demospherefirstdoorwaysequence06");
        sequencesList.Add("demospherefirstdoorwaysequence07");
        sequencesList.Add("demospherefirstdoorwaysequence08");

        sequencesList.Add("demospherefirstdoorwaysequence10");
        sequencesList.Add("demospherefirstdoorwaysequence11");
        sequencesList.Add("demospherefirstdoorwaysequence02");
        sequencesList.Add("demospherefirstdoorwaysequence09");
        sequencesList.Add("demospherefirstdoorwaysequence13");
        sequencesList.Add("demospherefirstdoorwaysequence16");
        sequencesList.Add("demospherefirstdoorwaysequence20");

        sequencesList.Add("turnaroundnow01");
        sequencesList.Add("secretpanelopens07");
        sequencesList.Add("callingoutinitial14");
        sequencesList.Add("gloriousfreedom03");
        sequencesList.Add("gladosgantry20");
        sequencesList.Add("gladosgantry21");
        sequencesList.Add("gladosgantry22");
        sequencesList.Add("raildroppostfall02");
        sequencesList.Add("raildroppostfall03");
        sequencesList.Add("raildroppostfall05");
        sequencesList.Add("raildroppostfall08");
        sequencesList.Add("raildroppostfall09");
        sequencesList.Add("raildroppostfall15");
        sequencesList.Add("raildroppostfall16");
        sequencesList.Add("raildroppostfall17");
        sequencesList.Add("raildroppostfall19");
        sequencesList.Add("raildroppostfall20");
        sequencesList.Add("raildroppickup02");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-8-0";
        sequencesList = List();
        sequencesList.Add("wakeup_powerup02");
        sequencesList.Add("sp_a1_wakeup_hacking11");
        sequencesList.Add("fgb_hello01");
        sequencesList.Add("chellgladoswakeup01");
        sequencesList.Add("sp_a1_wakeup_hacking03");
        sequencesList.Add("chellgladoswakeup04");
        sequencesList.Add("chellgladoswakeup05");
        sequencesList.Add("demospherepowerup07");
        sequencesList.Add("sp_a2_wheatley_ows_long03");
        sequencesList.Add("a1_wakeup_pinchergrab01");
        sequencesList.Add("a1_wakeup_pinchergrab02");
        sequencesList.Add("chellgladoswakeup06");
        sequencesList.Add("wakeup_outro01");
        sequencesList.Add("wakeup_outro02");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_1-9-0";
        sequencesList = List();
        sequencesList.Add("sp_incinerator_01_01");
        sequencesList.Add("sp_incinerator_01_18");
        sequencesList.Add("sp_a2_intro1_found01");
        sequencesList.Add("sp_incinerator_01_08");
        sequencesList.Add("sp_incinerator_01_09");
        sequencesList.Add("sp_incinerator_01_10");
        sequencesList.Add("sp_a2_intro1_found05");
        sequencesList.Add("sp_a2_intro1_found06");
        sequencesList.Add("sp_a2_intro1_found07");
        sequencesList.Add("sp_a2_intro1_found08");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_2-1-0";
        sequencesList = List();
        sequencesList.Add("sarcasmcore01");
        sequencesList.Add("glados_generated_oh_good");
        sequencesList.Add("sp_laser_redirect_intro_entry02");
        sequencesList.Add("glados_generated_deadly_lasers");
        sequencesList.Add("sp_laser_redirect_intro_entry03");
        sequencesList.Add("sp_a2_laser_intro_ending02");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_2-2-0";
        sequencesList = List();
        sequencesList.Add("sp_a2_laser_stairs_intro02");
        sequencesList.Add("sp_a2_laser_stairs_intro03");
        sequencesList.Add("sp_laser_powered_lift_completion02");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_2-3-0";
        sequencesList = List();
        sequencesList.Add("sp_a2_dual_lasers_intro01");
        sequencesList.Add("sp_laser_redirect_intro_completion01");
        sequencesList.Add("sp_laser_redirect_intro_completion03");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_2-4-0";
        sequencesList = List();
        sequencesList.Add("sp_laser_over_goo_entry01");
        sequencesList.Add("sp_a2_laser_over_goo_intro01");
        sequencesList.Add("sp_laser_over_goo_completion01");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_2-5-0";
        sequencesList = List();
        sequencesList.Add("faith_plate_intro01");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_2-6-0";
        sequencesList = List();
        sequencesList.Add("sp_catapult_intro_completion01");
        sequencesList.Add("sp_trust_fling_entry01");
        sequencesList.Add("sp_trust_fling_entry02");
        sequencesList.Add("cavejohnson_generated_book_easter");
        sequencesList.Add("cavejohnson_generated_book_easter2");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_2-7-0";
        sequencesList = List();
        sequencesList.Add("fizzlecube01");
        sequencesList.Add("fizzlecube03");
        sequencesList.Add("fizzlecube05");
        sequencesList.Add("fizzlecube06");
        sequencesList.Add("sp_a2_pit_flings02");
        sequencesList.Add("sp_a2_pit_flings03");
        sequencesList.Add("sp_a2_pit_flings06");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_2-8-0";
        sequencesList = List();
        sequencesList.Add("sp_a2_fizzler_intro01");
        sequencesList.Add("sp_a2_fizzler_intro04");
        sequencesList.Add("sp_a2_fizzler_intro05");
        sequencesList.Add("sp_a2_fizzler_intro06");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_3-1-0";
        sequencesList = List();
        sequencesList.Add("sp_catapult_fling_sphere_peek01");
        sequencesList.Add("sp_catapult_fling_sphere_peek02");
        sequencesList.Add("sp_catapult_fling_sphere_peek03");
        sequencesList.Add("sp_catapult_fling_sphere_peek_failureone01");
        sequencesList.Add("sp_catapult_fling_sphere_peek_failureone02");
        sequencesList.Add("sp_catapult_fling_sphere_peek_failureone03");
        sequencesList.Add("sp_catapult_fling_sphere_peek_failuretwo01");
        sequencesList.Add("sp_catapult_fling_sphere_peek_failuretwo02");
        sequencesList.Add("sp_catapult_fling_sphere_peek_failuretwo03");
        sequencesList.Add("sp_catapult_fling_sphere_peek_failurethree01");
        sequencesList.Add("sp_a2_pit_flings06");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_3-2-0";
        sequencesList = List();
        sequencesList.Add("sp_a2_ricochet01");
        sequencesList.Add("glados_generated_deers");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_3-3-0";
        sequencesList = List();
        sequencesList.Add("sp_a2_bridge_intro01");
        sequencesList.Add("sp_a2_bridge_intro03");
        sequencesList.Add("sp_a2_bridge_intro04");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_3-4-0";
        sequencesList = List();
        sequencesList.Add("sp_a2_bridge_the_gap01");
        sequencesList.Add("sp_a2_bridge_the_gap02");
        sequencesList.Add("sp_a2_bridge_the_gap_expo01");
        sequencesList.Add("sp_a2_bridge_the_gap_expo03");
        sequencesList.Add("sp_a2_bridge_the_gap_expo06");
        sequencesList.Add("sp_sphere_2nd_encounter_entrytwo01");
        sequencesList.Add("sp_trust_fling01");
        sequencesList.Add("sp_trust_fling04");
        sequencesList.Add("sp_trust_flingalt02");
        sequencesList.Add("sp_trust_flingalt07");
        sequencesList.Add("sp_trust_flingalt08");
        sequencesList.Add("testchambermisc19");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_3-5-0";
        sequencesList = List();
        sequencesList.Add("turret_intro01");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_3-6-0";
        sequencesList = List();
        sequencesList.Add("testchambermisc21");
        sequencesList.Add("testchambermisc23");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_3-7-0";
        sequencesList = List();
        sequencesList.Add("sp_a2_turret_intro01");
        sequencesList.Add("sp_a2_turret_intro03");
        sequencesList.Add("testchambermisc30");
        sequencesList.Add("sp_a2_turret_blocker_future_starter01");
        sequencesList.Add("sp_a2_turret_blocker_future_starter02");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_3-8-0";
        sequencesList = List();
        sequencesList.Add("testchambermisc31");
        sequencesList.Add("sp_a2_laser_vs_turret_r1");
        sequencesList.Add("testchambermisc24");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_3-9-0";
        sequencesList = List();
        sequencesList.Add("testchambermisc39");
        sequencesList.Add("testchambermisc33");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_4-1-0";
        sequencesList = List();
        sequencesList.Add("sad_party_horn_01");
        sequencesList.Add("sp_a2_column_blocker01");
        sequencesList.Add("sp_a2_column_blocker03");
        sequencesList.Add("sp_a2_column_blocker04");
        sequencesList.Add("testchambermisc34");
        sequencesList.Add("testchambermisc35");
        sequencesList.Add("testchambermisc41");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_4-2-0";
        sequencesList = List();
        sequencesList.Add("sp_a2_column_blocker05");
        sequencesList.Add("sp_a2_dilemma01");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_4-3-0";
        sequencesList = List();
        sequencesList.Add("a2_triple_laser01");
        sequencesList.Add("a2_triple_laser02");
        sequencesList.Add("a2_triple_laser03");
        self.AddCustomSounds(levelName, sequencesList);

        levelName = "Level_4-4-0";
        sequencesList = List();
        sequencesList.Add("sp_a2_bts1_intro01");
        self.AddCustomSounds(levelName, sequencesList);
    }

    function Play(name)
    {
        char = PlayerProxy.GetCharacter();
        if (char == null)
        {
            return;
        }

        char.StopSound(name);
        char.PlaySound(name);
    }

    function PlayCustom(level, sequence)
    {
        if (!self._customInited)
        {
            return;
        }
        self._levels.Get(level).Get(sequence).PlaySound();
    }

    function StopCustom(level, sequence)
    {
        if (!self._customInited)
        {
            return;
        }
        self._levels.Get(level).Get(sequence).StopSound();
    }

    # @param levelName string
    # @param sequencesList List(string)
    function AddCustomSounds(levelName, sequencesList)
    {
        dict = Dict();
        transformLevel = self._customManager.Transform.GetTransform(levelName);
        for (s in sequencesList)
        {
            dict.Set(s, transformLevel.GetTransform(s));

        }
        self._levels.Set(levelName, dict);
    }
}

extension MCLogger
{
    Log = Logger(-1, "[MCLOG]");

    function Info(msg)
    {
        if (!Network.IsMasterClient)
        {
            return;
        }

        self.Log.Info(msg);
    }

    function Debug(msg)
    {
        if (!Network.IsMasterClient)
        {
            return;
        }

        self.Log.Debug(msg);
    }

    function Trace(msg)
    {
        if (!Network.IsMasterClient)
        {
            return;
        }

        self.Log.Trace(msg);
    }

    function Error(msg)
    {
        if (!Network.IsMasterClient)
        {
            return;
        }

        self.Log.Error(msg);
    }
}

extension ObjectPoolManager
{
    LASER = 1;
    HARD_LIGHT_BRIDGE = 2;
    TURRET_LASER = 3;
    PORTALGUN_PROJECTILE = 4;
    LINE_RENDERER = 5;
    PORTAL_GUN = 6;
    WEIGHTED_STORAGE_CUBE = 7;
    WEIGHTED_COMPANION_CUBE = 8;
    DISCOURAGEMENT_REDIRECTION_CUBE = 9;

    # @type Dict<int,MapObjectPoolData>
    _pools = Dict();
    # @type List<LineRenderer>
    _lineRendererPool = List();
    _inited = false;
    _lineRendererPoolSize = 100;

    function Initialize()
    {
        self._pools = Dict();
        self._lineRendererPool = List();
        self._inited = true;
    }

    # @param objectType int
    # @param builder CommonBuilder
    # @param poolSize int
    function CreatePool(objectType, builder, poolSize)
    {
        if (!self._inited)
        {
            self.Initialize();
        }

        if (!self._pools.Contains(objectType))
        {
            poolData = MapObjectPoolData(poolSize, builder);
            self._pools.Set(objectType, poolData);
        }
    }

    # @return bool
    function IsPoolInited(objectType)
    {
        return self._pools.Contains(objectType);
    }

    # @return LineRenderer
    function GetLineRendererFromPool()
    {
        if (!self._inited)
        {
            self.Initialize();
        }

        for (line in self._lineRendererPool)
        {
            if (!line.Enabled)
            {
                return line;
            }
        }

        if (self._lineRendererPool.Count < self._lineRendererPoolSize)
        {
            line = LineRenderer();
            self._lineRendererPool.Add(line);
            return line;
        }

        return null;
    }

    # @param line LineRenderer
    function ReturnLineRendererToPool(line)
    {
        if (!self._inited)
        {
            self.Initialize();
        }

        line.Enabled = false;
    }

    # @param objectType int
    # @return MapObject
    function GetObjectFromPool(objectType)
    {
        if (!self._inited)
        {
            self.Initialize();
        }

        if (self._pools.Contains(objectType))
        {
            poolData = self._pools.Get(objectType);
            for (obj in poolData.pool)
            {
                if (!obj.Active)
                {
                    obj.Active = true;
                    obj.SetComponentsEnabled(true);
                    return obj;
                }
            }

            if (poolData.pool.Count < poolData.limit)
            {
                newObj = poolData.builder.Build();
                newObj.Active = true;
                newObj.SetComponentsEnabled(true);
                poolData.pool.Add(newObj);
                return newObj;
            }
        }
        return null;
    }

    # @param objectType int
    # @param obj MapObject
    function ReturnObjectToPool(objectType, obj)
    {
        if (!self._inited)
        {
            self.Initialize();
        }

        if (self._pools.Contains(objectType))
        {
            obj.Active = false;
            obj.Position = Vector3(0, -9999, 0);
            obj.SetComponentsEnabled(false);
        }
    }

    # @param objectType int
    function ClearPool(objectType)
    {
        if (!self._inited)
        {
            self.Initialize();
        }

        if (self._pools.Contains(objectType))
        {
            pool = self._pools.Get(objectType);
            for (obj in pool.pool)
            {
                obj.Active = false;
                obj.Position = Vector3(0, -9999, 0);
                obj.SetComponentsEnabled(false);
            }
        }
    }
}

class CommonBuilder
{
    # @type MapObject
    _ref = null;

    # @param ref MapObject
    function Init(ref)
    {
        self._ref = ref;
    }

    # @return MapObject
    function Build()
    {
        return Map.CopyMapObject(self._ref, true);
    }
}

class CubeBuilder
{
    _type = null;

    function Init(t)
    {
        self._type = t;
    }

    # @return MapObject
    function Build()
    {
        ref = Map.FindMapObjectByName(self._type);
        obj = Map.CopyMapObject(ref, true);

        pt = obj.AddComponent("TargetPassThrough");
        pt.All = false;
        pt.Portals = true;
        pt.HardLightBridges = true;

        # TODO: Rigidbody bug. Fix this.
        # obj.AddComponent("Rigidbody"); # This is working, fields are not mutable.
        rb = obj.AddRigidbody();
        # rb = obj.Rigidbody;
        rb.Mass = 1.0;
        rb.Gravity = Vector3(0, -20, 0);
        rb.FreezeAllRotations = false;
        rb.Interpolate = true;
        # # @type IRigidbody
        # rb = obj.AddComponent("Rigidbody"); # This is working, fields are not mutable.

        m = obj.AddComponent("Movable");
        m.ResetGroup = "";
        m.LockForward = true;
        m.Initialize();

        return obj;
    }
}

class Resetable
{
    function Reset(){}
}

extension ResetManager
{
    # @type Dict<string,List<Resetable>>
    _resetables = Dict();

    function Add(k, v)
    {
        l = self._resetables.Get(k, List());
        l.Add(v);
        self._resetables.Set(k, l);
    }

    function Reset(k)
    {
        l = self._resetables.Get(k, null);
        if (l != null)
        {
            for (v in l)
            {
                v.Reset();
            }
        }
    }

    function ResetAll()
    {
        for (l in self._resetables.Values)
        {
            for (v in l)
            {
                v.Reset();
            }
        }
    }
}

extension CutsceneManager
{
    _timers = Dict();
    _cutscenesState = Dict();
    _cutscenesCanPlay = Dict();
    _timer = Timer(0.0);
    _pendingTimer = Timer(0.0);
    _pendingCutsceneID = null;
    _pendingCutsceneFull = null;
    _isCutsceneRunning = false;
    _skipSignal = false;

    # @param id string
    # @param full bool
    function Start(id, full)
    {
        if (self._pendingCutsceneID == id || !self.GetCanPlay(id))
        {
            return;
        }

        if (self._isCutsceneRunning)
        {
            self._pendingCutsceneID = id;
            self._pendingCutsceneFull = full;
            self._skipSignal = true;
        }
        else
        {
            self.SetCanPlay(id, false);
            self._isCutsceneRunning = true;
            Cutscene.Start(id, full);
        }
    }

    # @param t float
    function Wait(t)
    {
        self._timer.Reset(t);
    }

    function ResetTimer()
    {
        self._timer.Reset(0.0);
    }

    function IsTimerDone()
    {
        return self._timer.IsDone();
    }

    function GetState(k)
    {
        return self._cutscenesState.Get(k, 0);
    }

    # @param k string
    # @param v int
    function SetState(k, v)
    {
        return self._cutscenesState.Set(k, v);
    }

    # @param k string
    function GetCanPlay(k)
    {
        return self._cutscenesCanPlay.Get(k, true);
    }

    # @param k string
    # @param v bool
    function SetCanPlay(k, v)
    {
        return self._cutscenesCanPlay.Set(k, v);
    }

    # @return bool
    function SkipSent()
    {
        return self._skipSignal;
    }

    function OnTick()
    {
        self._timer.UpdateOnTick();

        if (!self._isCutsceneRunning)
        {
            self._pendingTimer.UpdateOnTick();
            pID = self._pendingCutsceneID;
            pFull = self._pendingCutsceneFull;
            if (self._pendingTimer.IsDone() && pID != null)
            {
                # self._pendingTimer.Reset(0.25);
                self._isCutsceneRunning = true;
                self._pendingCutsceneID = null;
                self._pendingCutsceneFull = null;
                self.SetCanPlay(pID, false);
                Cutscene.Start(pID, pFull);
            }
        }
    }

    function ResetAll()
    {
        if (self._isCutsceneRunning)
        {
            self._skipSignal = true;
        }
        else
        {
            self._skipSignal = false;
        }
        self._pendingCutsceneID = null;
        self._pendingCutsceneFull = null;

        self._cutscenesState.Clear();
        self._cutscenesCanPlay.Clear();

        self._isCutsceneRunning = false;
    }

    # @param k string
    function OnCutsceneComplete(k)
    {
        self.Wait(0.0);
        self._isCutsceneRunning = false;
        self._skipSignal = false;
        if (self._pendingCutsceneID != null)
        {
            self._pendingTimer.Reset(0.1);
        }
    }
}

class Handler
{
    # @param sender Player
    # @param msg Dict
    function Handle(sender, msg){}
}

extension Router
{
    # @type Dict<string,Handler>
    _handlers = Dict();

    function RegisterHandler(topic, handler)
    {
        self._handlers.Set(topic, handler);
    }

    # @param sender Player
    # @param msg string
    function Route(sender, msg)
    {
        # @type Dict<string, any>
        dict = Json.LoadFromString(msg);
        topic = dict.Get("topic");

        h = self._handlers.Get(topic, null);
        if (h == null)
        {
            return;
        }

        h.Handle(sender, dict);
    }
}

extension Dispatcher
{
    # @param p Player
    # @param msg Dict
    function Send(p, msg)
    {
        raw = Json.SaveToString(msg);
        Network.SendMessage(p, raw);
    }

    # @param msg Dict
    function SendOthers(msg)
    {
        raw = Json.SaveToString(msg);
        Network.SendMessageOthers(raw);
    }

    # @param msg Dict
    function SendAll(msg)
    {
        raw = Json.SaveToString(msg);
        Network.SendMessageAll(raw);
    }
}

class UIRouterHandler
{
    # @param btn string
    function CanHandleClick(btn){}
    # @param btn string
    function OnButtonClick(btn){}
}

extension UIRouter
{
    # @type List<UIRouterHandler>
    _handlers = List();

    # @param h UIRouterHandler
    function RegisterHandler(h)
    {
        self._handlers.Add(h);
    }

    # @param btn string
    function OnButtonClick(btn)
    {
        for (h in self._handlers)
        {
            if (h.CanHandleClick(btn))
            {
                h.OnButtonClick(btn);
                return;
            }
        }
    }
}

#######################
# ENUMS
#######################

#######################
## INGAME
#######################

extension ObjectTypeEnum
{
    HUMAN = "Human";
    Titan = "Titan";
    MAP_OBJECT = "MapObject";
}

#######################
## CUSTOM
#######################

extension ColorEnum
{
    BluePortal = "0096FF";
    BluePortalDarker = "005C99";
    OrangePortal = "FF6A00";
    OrangePortalDarker = "993F00";
    PastelBlue = "8BD3E6";
    PastelRed = "FF6D6A";
    PastelYellow = "E9EC6B";
    PastelOrange = "EFBE7D";
    PastelPurple = "B1A2CA";
    PastelCream = "FDFFB6";
    DarkRed = "f22c3d";
    Orangered = "FF4500";
}

extension PortalEnum
{
    BLUE = 0;
    ORANGE = 1;
}

extension AirMovementPreset
{
    NONE = "None";
    DEFAULT = "Default";
    QUAKE = "Quake";
    PORTAL = "Portal";
}

#######################
## MESSAGES
#######################

extension BaseMessage
{
    KEY_TOPIC = "topic";
}

extension TeleportAccessMessage
{
    TOPIC = "teleport_access";
    KEY_ALLOW = "allow";

    # @param allow int
    # @return Dict
    function New(allow)
    {
        msg = Dict();
        msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
        msg.Set(self.KEY_ALLOW, allow);
        return msg;
    }
}

# extension SpeedRunResultsMessage
# {
#     TOPIC = "speedrun_results";
#     KEY_DATA = "data";

#     # @param data SpeedRunResult
#     # @return Dict
#     function New(data)
#     {
#         msg = Dict();
#         msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
#         msg.Set(self.KEY_DATA, data.ToDict());

#         return msg;
#     }
# }

#######################
## MESSAGE HANDLERS
#######################

class TeleportAccessMessageHandler
{
    # @param sender Player
    # @param msg Dict
    function Handle(sender, msg)
    {
        allow = msg.Get(TeleportAccessMessage.KEY_ALLOW);
        Network.MyPlayer.SetCustomProperty("TELEPORT_ACCESS", allow);
    }
}

# class SpeedRunResultsMessageHandler
# {
#     # @param sender Player
#     # @param msg Dict
#     function Handle(sender, msg)
#     {
#         rawData = msg.Get(SpeedRunResultsMessage.KEY_DATA);
#         spdDTO = SpeedRunResult();
#         spdDTO.FromDict(rawData);
#         SpeedRunManager.UpdateLeaderboards(sender.Name, spdDTO);
#     }
# }


extension I18n
{
    ChineseLanguage = "简体中文";
    EnglishLanguage = "English";
    RussianLanguage = "Russian";
    TraditionalChineseLanguage = "繁體中文";

    # @type Dict<string,Dict<string,string>>
    _languages = Dict();
    # @type string
    _defaultLanguage = null;

    # @param key string
    # @return string
    function Get(key)
    {
        pack = self._LoadLanguagePack();
        localized = pack.Get(key, null);
        if (localized != null)
        {
            return localized;
        }

        defaultPack = self._languages.Get(self._defaultLanguage);
        localized = defaultPack.Get(key, null);
        if (localized != null)
        {
            return localized;
        }

        return "[ERR] Localized string not found: " + key;
    }

    # @param language string
    function SetDefaultLanguage(language)
    {
        self._defaultLanguage = language;
    }

    # @param pack LanguagePack
    function RegisterLanguagePack(pack)
    {
        self._languages.Set(pack.Language(), pack.Load());

        if (self._defaultLanguage == null)
        {
            self._defaultLanguage = pack.Language();
        }
    }

    # @return Dict<string,string>
    function _LoadLanguagePack()
    {
        return self._languages.Get(Locale.CurrentLanguage, self._languages.Get(self._defaultLanguage));
    }
}

class LanguagePack
{
    # @return Dict<string,string>
    function Load(){}

    # @return string
    function Language(){}
}

class EnglishLanguagePack
{
    # @type Dict<string,string>
    _pack = Dict();

    # @return Dict<string,string>
    function Load()
    {
        return self._pack;
    }

    # @return string
    function Language()
    {
        return I18n.EnglishLanguage;
    }

    function Init()
    {
        # UI
        self._pack.Set("input.title", "Keybinds");
        self._pack.Set("input.admin_panel", "Admin Panel");
        self._pack.Set("input.teleport_gui", "Teleport GUI");
        self._pack.Set("input.speedrun_gui", "Speedrun GUI");
        self._pack.Set("input.portal_blue", "Blue Portal");
        self._pack.Set("input.portal_orange", "Orange Portal");
        self._pack.Set("input.reset_portals", "Reset Portals");
        self._pack.Set("input.interact", "Interact");
        self._pack.Set("input.skip_cutscene", "Skip Cutscene");
        self._pack.Set("input.zoom", "Zoom");
        self._pack.Set("input.zoom_in_out", "Zoom In / Out");
        self._pack.Set("input.quality", "Quality Preset");
        self._pack.Set("notes.settings", "Recommended Render Distance: 250"
                + String.Newline
                + "[" + Input.GetKeyName(InputGeneralEnum.Pause) + "] / Settings / Graphics / Render distance");
        self._pack.Set("easter_eggs.title", "Easter Eggs Found");

        # Cutscenes
        self._pack.Set("Level_1-1-0-prehub06", "Hello, and again, welcome to the " + HTML.Color("Aperture Science Enrichment Center", ColorEnum.PastelBlue) + ".");
        self._pack.Set("Level_1-1-0-announcer_generated_status", "Always take a look at the left side of your screen, it contains useful information about your status and all hotkeys you need.");
        self._pack.Set("Level_1-1-0-announcer_generated_as_guild", "Add " + HTML.Color("'Aperture Science'", "a1c1f1") + " to your Guild Name, to access secret features.");
        self._pack.Set("Level_1-1-0-prehub10", "The portal will open, and emergency testing will begin in three, two, one...");

        self._pack.Set("Level_1-1-0-prehub11", "Cubes and button-based testing remains an important tool for science, even in a dire emergency. Press " + HTML.Color("[" + Input.GetKeyName(InputManager.Interact) + "]", ColorEnum.PastelOrange) + " to grab the " + HTML.Color("cube", ColorEnum.PastelBlue) + " and put it on the " + HTML.Color("button.", ColorEnum.PastelRed));

        self._pack.Set("Level_1-1-0-testchamber07", "You have just passed through an " + HTML.Color("Aperture Science Material Emancipation Grill", ColorEnum.PastelBlue) + ", which vaporizes most " + HTML.Color("Aperture Science", ColorEnum.PastelBlue) + " equipment that touches it.");

        self._pack.Set("Level_1-2-0-announcer_generated_btn_interact", "To interact with buttons, target the " + HTML.Color("red part", ColorEnum.PastelRed) + " and press " + HTML.Color("[" + Input.GetKeyName(InputManager.Interact) + "]", ColorEnum.PastelOrange) + ".");

        self._pack.Set("Level_1-2-0-good02", "Good.");

        self._pack.Set("Level_1-2-0-prehub20_1", "Before re-entering a relaxation vault at the conclusion of testing, please take a moment to write down the results of your test.");
        self._pack.Set("Level_1-2-0-prehub20_2", "An Aperture Science Re-Integration Associate will revive you for an interview when society has been rebuild.");

        self._pack.Set("Level_1-3-0-sp_intro_03_intro12", "Hey-hey, you made it!");
        self._pack.Set("Level_1-3-0-sp_intro_03_intro09", "There should be a " + HTML.Color("Portal Device", ColorEnum.BluePortal) + " on that podium over there.");

        self._pack.Set("Level_1-4-0-prehub42", "This next test is very dangerous. To help you remain tranquil in the face of almost certain death, smooth jazz will be deployed in three...two...one...");
        self._pack.Set("Level_1-4-1-testchamber09_1", "Great work! "
            + String.Newline
            + "Because this message is prerecorded, many observations related to your perfomance are speculation on our part.");
        self._pack.Set("Level_1-4-1-testchamber09_2", "Please, disregard any undeserved compliments.");

        self._pack.Set("Cutscene_Level_1_4_2", "EH EREH???...");

        self._pack.Set("Level_1-5-0-testchamber02_1", "If the Enrichment Center is currently being bombarded with fireballs, metiorites, or other objects from space...");
        self._pack.Set("Level_1-5-0-testchamber02_2", "...please avoid unsheltered testing areas wherever a lack of shelter from space-debris DOES NOT appear to be a deliberate part of the test.");

        self._pack.Set("Level_1-6-0-testchamber10", "This next test applies the " +  HTML.Color("Principles of Momentum", ColorEnum.PastelOrange) + " to movement through portals. If the laws of physics no longer apply in the future, God help you.");

        self._pack.Set("Level_1-6-1-prehub17", "If you are a non-employee who has discovered this facility amid the ruins of civilization, welcome! And remember: Testing is the future, and future starts with you.");

        self._pack.Set("Level_1-6-1-prehub18_1", "Good work getting this far, future-starter!");
        self._pack.Set("Level_1-6-1-prehub18_2", "That said, if you are simple-minded, old, or irradiated in such a way that the future should not start with you...");
        self._pack.Set("Level_1-6-1-prehub18_3", "...please return to your primitive tribe, and send back someone better qualified for testing.");

        self._pack.Set("Level_1-7-0-sp_intro_03_intro02", "Hey! Oi oi! I'm up here!");
        self._pack.Set("Level_1-7-0-demosphereintro04_1", "Oh, brilliant. You DID find a " + HTML.Color("Portal Gun", ColorEnum.BluePortal)+ "!");
        self._pack.Set("Level_1-7-0-demosphereintro04_2", "You know what? It just goes to show: people with brain damage are the real heroes in the end aren't they? At the end of the day. Brave.");
        self._pack.Set("Level_1-7-0-demosphereintro02", "Pop a portal on that wall behind me there, and i'll meet you on the other side of the room.");

        self._pack.Set("Level_1-7-0-demosphereintro07", "Right behind me.");
        self._pack.Set("Level_1-7-0-demosphereintro08", "Just pop a portal right behind me there, and come on through to the other side.");
        self._pack.Set("Level_1-7-0-demosphereintro09", "Pop a little portal, just there, alright? Behind me. And come on through.");
        self._pack.Set("Level_1-7-0-demosphereintro10", "Alright, let me explain again. Pop a portal. Behind me. Alright? And come on through.");
        self._pack.Set("Level_1-7-0-demosphereintro11", "Pop a portal. Behind me, on the wall. Come on through.");
        self._pack.Set("Level_1-7-0-demosphereintro13", "Come on through.");
        self._pack.Set("Level_1-7-0-demosphereintro14", "Come on through to the other side.");
        self._pack.Set("Level_1-7-0-demosphereintro15", "Come on through.");

        self._pack.Set("Level_1-7-0-raildropintro01_1", "Okay, listen, let me, lay something on you here. It's pretty heavy.");
        self._pack.Set("Level_1-7-0-raildropintro01_2", "They told me NEVER NEVER EVER to disengage myself from my Management Rail. Or I would die.");
        self._pack.Set("Level_1-7-0-raildropintro01_3", "But we're out of options here. So... " + HTML.Color("get ready to catch me", ColorEnum.PastelOrange) + " , alright. On the off chance that I'm not dead the moment I pop off this thing.");

        self._pack.Set("Level_1-7-0-demospherecatch02-1", HTML.Color("On three", ColorEnum.PastelRed) + ". Ready?");
        self._pack.Set("Level_1-7-0-demospherecatch02-2", HTML.Color("One...", ColorEnum.PastelBlue));
        self._pack.Set("Level_1-7-0-demospherecatch02-3", HTML.Color("Two...", ColorEnum.PastelOrange));

        self._pack.Set("Level_1-7-0-demospherecatch05-1", HTML.Color("THREE!", ColorEnum.PastelRed));
        self._pack.Set("Level_1-7-0-demospherecatch05-2", "That's high, It's TOO high, isn't it, really, that...");

        self._pack.Set("Level_1-7-0-demospherecatch07-1", "Alright, going on three, just gives you too much time to think about it.");
        self._pack.Set("Level_1-7-0-demospherecatch07-2", "Let's uh, go on " + HTML.Color("ONE", ColorEnum.PastelRed) + " this time.");
        self._pack.Set("Level_1-7-0-demospherecatch07-3", "Okay, ready?");

        self._pack.Set("Level_1-7-0-demospherefall04-1", HTML.Color("ONE!", ColorEnum.PastelRed));
        self._pack.Set("Level_1-7-0-demospherefall04-2", HTML.Color("CATCH ME! CATCH ME! CATCH ME! CATCH ME! CATCH ME! CATCH ME! AW!", ColorEnum.PastelRed));

        self._pack.Set("Level_1-7-0-demospherethud06", "I. Am. Not. Dead! I'm not dead! Ha-ha-ha-ha.");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence04", "Plug me into that stick on the wall over there. Yeah? And I'll show you something. You'll be impressed by that.");

        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence01", "Plug me into that stick on the wall over there. I'll show you something.");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence05", "Go on. Just jam me in over there.");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence06", "Right on that stick over there. Just put me right on it.");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence07", "It is tricky. It is tricky. But, umm... just... plug me in, please.");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence08", "It DOES sound rude. I'm not going to lie to you. It DOES sound rude. It's not. Put me right on it. Stick me in.");

        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence10", "Umm. Yeah, I can't do it if you're watching.");

        self._pack.Set("demospherefirstdoorwaysequence11", "Seriously, I'm not joking, could you just turn around for a second?");
        self._pack.Set("demospherefirstdoorwaysequence02", "I can't... I can't do it if you're watching. [nervous laugh]");
        self._pack.Set("demospherefirstdoorwaysequence09", "I can't do it if you're watching. If you.... just turn around?");
        self._pack.Set("demospherefirstdoorwaysequence13", "Alright. [nervous laugh] Can't do it if you're leering at me. Creepy.");
        self._pack.Set("demospherefirstdoorwaysequence16", "What's that behind you? It's only a robot on a bloody stick! A different one!");
        self._pack.Set("demospherefirstdoorwaysequence20", "Okay. Listen. I can't do it with you watching. I know it seems pathetic, given what we've been through. But just turn around. Please?");

        self._pack.Set("turnaroundnow01", "Alright, you can turn around now!");
        self._pack.Set("secretpanelopens07", "Bam! Secret panel! That I opened. While your back was turned.");
        self._pack.Set("callingoutinitial14", "Pick me up. Let's get out of here.");
        self._pack.Set("raildroppickup02", "Oh! Brilliant, thank you, great.");
        self._pack.Set("raildroppostfall02", "Are you still... are you still there? Could you pick me up do you think? If you are there?");
        self._pack.Set("raildroppostfall03", "Sorry, are you still there? Could you pick... could you pick me up?");
        self._pack.Set("raildroppostfall05", "Hello? Can you.. can you pick me up, please?");
        self._pack.Set("raildroppostfall08", "If you are there, would you mind... give me a little bit of help? Heh... just pick me up.");
        self._pack.Set("raildroppostfall09", "Look... look down! Where am I? Where am I?....");
        self._pack.Set("raildroppostfall15", "Don't want to hassle you. Sure you're busy. Um... but - still here on the floor. Waiting to be picked up.");
        self._pack.Set("raildroppostfall16", "On the floor. Needing your help. The whole time. All the time. Needing your help.");
        self._pack.Set("raildroppostfall17", "Still here on the floor. Waiting to be picked up. Um...");
        self._pack.Set("raildroppostfall19", "Look down. Who's that, down there, talking? It's me! Down on the floor. Needing you to pick me up.");
        self._pack.Set("raildroppostfall20_1", "What are you doing, are you just having a little five minutes to yourself? Fair enough. You've had a rough time. You've been asleep for who knows how long.");
        self._pack.Set("raildroppostfall20_2", "You've got the massive brain damage. And you're having a little rest. But NOW. Get yourself up. And pick me up.");

        self._pack.Set("gloriousfreedom03_1", "Look at this! No rail to tell us where to go! Oh, this is brilliant. We can go where ever we want!");
        self._pack.Set("gloriousfreedom03_2", "Hold on though where are we going? Seriously. Hang on, let me just get my bearings.");
        self._pack.Set("gloriousfreedom03_3", "Just follow the rail, actually.");

        self._pack.Set("gladosgantry20", "Probably ought to bring you up to speed on something right now.");
        self._pack.Set("gladosgantry21", "In order to escape, we're going to have to go through HER chamber.");
        self._pack.Set("gladosgantry22", "And, she will probably kill us if, um, she's awake.");

        self._pack.Set("wakeup_powerup02", "Power up complete.");
        self._pack.Set("sp_a1_wakeup_hacking11", "I don't... Okay. Okay. Okay. Listen, alright: New plan. Act natural, act natural. We've done nothing wrong.");
        self._pack.Set("fgb_hello01", "Hello!");
        self._pack.Set("chellgladoswakeup01", "Oh... It's you.");
        self._pack.Set("sp_a1_wakeup_hacking03", "You KNOW her???");
        self._pack.Set("chellgladoswakeup04_1", "It's been a loooooong time.");
        self._pack.Set("chellgladoswakeup04_2", "How have you been?");
        self._pack.Set("chellgladoswakeup05_1", "I've been really busy being " + HTML.Color("dead", ColorEnum.PastelRed) + ".");
        self._pack.Set("chellgladoswakeup05_2", "You know... after " + HTML.Color("YOU MURDERED ME", ColorEnum.PastelRed) + ".");
        self._pack.Set("demospherepowerup07", "You did WHAT?");
        self._pack.Set("a1_wakeup_pinchergrab02", "Oh no! No no no no no...No! No!");
        self._pack.Set("sp_a2_wheatley_ows_long03", "Gah!");
        self._pack.Set("chellgladoswakeup06_1", "Okay. Look. We both said a lot of things that you're going to regret.");
        self._pack.Set("chellgladoswakeup06_2", "But I think we can put our differences behind us. For science. " + HTML.Color("You monster", ColorEnum.PastelRed) + ".");
        self._pack.Set("wakeup_outro01", "I will say, though, that since you went to all the trouble of waking me up, you must really, " + HTML.Color("REALLY", ColorEnum.PastelRed) + " love to test.");
        self._pack.Set("wakeup_outro02", "I love it too. There is just one small thing we need to take care of first.");

        self._pack.Set("sp_incinerator_01_01", "Here we are. The Incinerator Room. Be careful not to trip over any parts of me that didn't get completely burned when you threw them down here.");
        self._pack.Set("sp_incinerator_01_18", HTML.Color("The Dual Portal Device", ColorEnum.OrangePortal) + " should be around here somewhere. Once you find it, we can start testing. Just like old times.");

        self._pack.Set("sp_a2_intro1_found01", "Good. You have a " + HTML.Color("Dual Portal Device", ColorEnum.OrangePortal) + ". There should be a way back to the testing area up ahead.");
        self._pack.Set("sp_incinerator_01_08_1", "Once testing starts, I'm required by protocol to keep interaction with you to a minimum.");
        self._pack.Set("sp_incinerator_01_08_2", "Luckily, we haven't started testing yet. This will be our only chance to talk.");
        self._pack.Set("sp_incinerator_01_09_1", "Do you know the biggest lesson I learned from what you did?");
        self._pack.Set("sp_incinerator_01_09_2", "I discovered I have a sort of black-box quick-save feature.");
        self._pack.Set("sp_incinerator_01_09_3", "In the event of a catastrophic failure, the last two minutes of my life are preserved for analysis.");
        self._pack.Set("sp_incinerator_01_10", "I was able - well, forced really - to relive you killing me. Again and again. " + HTML.Color("Forever", ColorEnum.PastelRed) + ".");
        self._pack.Set("sp_a2_intro1_found05", "You know, if you'd done that to somebody else, they might devote thier existence to exacting " + HTML.Color("REVENGE", ColorEnum.PastelRed) + ".");
        self._pack.Set("sp_a2_intro1_found06_1", "Luckily I'm a bigger person that that.");
        self._pack.Set("sp_a2_intro1_found06_2", "I'm happy to put this all behind us and get back to work.");
        self._pack.Set("sp_a2_intro1_found06_3", "After all, we've got a lot to do and only 60 more years to do it.");
        self._pack.Set("sp_a2_intro1_found06_4", "More or less. I don't have the acturial tables in front of me.");
        self._pack.Set("sp_a2_intro1_found07_1", "But the important thing is you're back. " + HTML.Color("With me", ColorEnum.PastelRed) + ". And now I'm onto all your little tricks.");
        self._pack.Set("sp_a2_intro1_found07_2", "So there's nothing to stop us from testing... " + HTML.Color("for the rest of your life", ColorEnum.PastelRed) + ".");
        self._pack.Set("sp_a2_intro1_found08", "After that... who knows? I might take up a hobby. Reanimating the dead, maybe.");

        self._pack.Set("sarcasmcore01", "Sarcasm self test complete.");
        self._pack.Set("sp_laser_redirect_intro_entry02", "Oh good, that's back online. I'll start getting everything else working while you perform this first simple test.");
        self._pack.Set("sp_laser_redirect_intro_entry03", "Which involves " + HTML.Color("Deadly Lasers", ColorEnum.PastelRed) + ". And how test subjects react, when locked in a room with deadly lasers.");

        self._pack.Set("sp_a2_laser_intro_ending02", "Not bad. I forgot how good you are at this. You should pace yourself, though. We have a LOT of tests to do.");

        self._pack.Set("sp_a2_laser_stairs_intro02_1", "This next test involves " + HTML.Color("Discouragement Redirection Cubes", ColorEnum.PastelPurple) +".");
        self._pack.Set("sp_a2_laser_stairs_intro02_2", "I just finished building them before you had your...well, episode.");
        self._pack.Set("sp_a2_laser_stairs_intro02_3", "So now we'll both get to see how they work.");
        self._pack.Set("sp_a2_laser_stairs_intro03", "There should be one in the corner.");

        self._pack.Set("sp_laser_powered_lift_completion02_1", "Well done. Here come the test results.");
        self._pack.Set("sp_laser_powered_lift_completion02_2", HTML.Color("You are a horrible person", ColorEnum.PastelRed) +".");
        self._pack.Set("sp_laser_powered_lift_completion02_3", "That's what it says: " + HTML.Color("'A horrible person'", ColorEnum.PastelRed) + ". We weren't even testing for that.");
        self._pack.Set("sp_a2_dual_lasers_intro01_1", "Don't let that " + HTML.Color("'horrible person'", ColorEnum.PastelRed) + " thing discourage you. It's just a data point.");
        self._pack.Set("sp_a2_dual_lasers_intro01_2", "If it makes you feel any better, Science has now validated your birth mother's decision to abandon you on a doorstep.");

        self._pack.Set("sp_laser_redirect_intro_completion01", "Congratulations. Not on the test.");
        self._pack.Set("sp_laser_redirect_intro_completion03_1", "Most people emerge from suspension terribly undernourished.");
        self._pack.Set("sp_laser_redirect_intro_completion03_2", "I want you congratulate you on beating the odds and somehow managing to pack on a few pounds.");

        self._pack.Set("sp_laser_over_goo_entry01", "One moment.");
        self._pack.Set("sp_a2_laser_over_goo_intro01_1", "You are navigating these test chambers faster than I can build them, so feel free to slow down and...");
        self._pack.Set("sp_a2_laser_over_goo_intro01_2", "...do whatever it is you do when you are not destroying this facility");

        self._pack.Set("sp_laser_over_goo_completion01_1", "I'll give you a credit. I guess you are listening to me.");
        self._pack.Set("sp_laser_over_goo_completion01_2", "But for the record, you don't have to go THAT slowly.");

        self._pack.Set("faith_plate_intro01_1", "This next test involves the " + HTML.Color("Aperture Science Aerial Faithplate", ColorEnum.PastelBlue) + ".");
        self._pack.Set("faith_plate_intro01_2", "It was part of an initiative to investigate how well test subjects could solve problems, when they were catapulted into space.");
        self._pack.Set("faith_plate_intro01_3", "Results were highly informative: " + HTML.Color("they could not", ColorEnum.PastelRed) + ". Good luck!");

        self._pack.Set("sp_catapult_intro_completion01", "Let's see what the next test is. Oh, " + HTML.Color("Advanced Aerial Faithplates", ColorEnum.PastelBlue) + ".");
        self._pack.Set("sp_trust_fling_entry01", "Well, have fun soaring through the air without a care in the world.");
        self._pack.Set("sp_trust_fling_entry02", "I have to go to the wing that was made entirely of glass, and pickup 15 acres of broken glass. By myself.");

        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_1", "You open the book to find the message: "
            + String.Newline
            + HTML.Color("'Aperture Science'", "a1c1f1") + " Employees Only. Minimum IQ: 200. Yours? Questionable."
            + String.Newline
            + "Please close the book to avoid confusion.");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_2", "As an authorized " + HTML.Color("Aperture Science", "a1c1f1") + " employee, the book's encrypted text rearranges itself into something vaguely readable.");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_3", "Congratulations on meeting the bare minimum qualifications.");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_4", "You open the book, and its pages are packed with complex formulas, test logs, and vaguely unsettling diagrams.");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_5", "As you scan the data, a handwritten note slowly appears, left by a fellow " + HTML.Color("Aperture Science", "a1c1f1") + " employee...");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_6", "Dear future reader: The formulas are correct. The results? Debatable. Good luck!");

        self._pack.Set("fizzlecube01", "Oh! Did I accidentally fizzle that before you could complete the test? I'm sorry.");
        self._pack.Set("fizzlecube03", "Go ahead and grab another one.");
        self._pack.Set("fizzlecube05", "Oh. No. I fizzled that one too.");
        self._pack.Set("fizzlecube06_1", "Oh well. We have warehouses full of the things");
        self._pack.Set("fizzlecube06_2", "Absolutely worthless. I'm happy to get rid of them.");

        self._pack.Set("sp_a2_pit_flings03_1", "Every test chamber is equipped with an " + HTML.Color("Emancipation Grill", ColorEnum.PastelBlue) + " at it's exit.");
        self._pack.Set("sp_a2_pit_flings03_2", "So that test subjects cannot smuggle test objects out of the test area.");
        self._pack.Set("sp_a2_pit_flings03_3", "This one is broken.");
        self._pack.Set("sp_a2_pit_flings02", HTML.Color("Don't take anything with you.", ColorEnum.PastelRed));

        self._pack.Set("sp_a2_pit_flings06", "I think that one was about to say: " + HTML.Color("'I love you'", ColorEnum.PastelPurple) + ". They are sentient, of course. We just have a lot of them.");

        self._pack.Set("sp_a2_fizzler_intro01", "This next test involves emancipation grills. Remember? I told you about them in the last test area, that did not have one.");
        self._pack.Set("sp_a2_fizzler_intro04", "Ohhh, no. The turbines again. I have to go. Wait. This next test DOES require some explanation. Let me give you the fast version.");
        self._pack.Set("sp_a2_fizzler_intro05", "[fast gibberish]");
        self._pack.Set("sp_a2_fizzler_intro06", "There. If you have any questions, just remember what I said in slow motion. Test on your own recognizance, I'll be right back.");

        self._pack.Set("sp_catapult_fling_sphere_peek01", "Hey! Hey! It's me! I'm okay!");
        self._pack.Set("sp_catapult_fling_sphere_peek_failureone01_1", "Well I'm back!");
        self._pack.Set("sp_catapult_fling_sphere_peek_failureone01_2", HTML.Color("The Aerial Faithplate", ColorEnum.PastelBlue) + " in here is sending a distress signal.");
        self._pack.Set("sp_catapult_fling_sphere_peek_failureone02", "You broke it, didn't you?");
        self._pack.Set("sp_catapult_fling_sphere_peek_failureone03", "There, try it now.");
        self._pack.Set("sp_catapult_fling_sphere_peek02", "You'll never believe what happened! There I was, just lying there, you thought I was done for, but --");
        self._pack.Set("sp_catapult_fling_sphere_peek_failuretwo01_1", "Hmm. This plate must not be calibrated to someone of your...generousness.");
        self._pack.Set("sp_catapult_fling_sphere_peek_failuretwo01_2", "I'll add a few zeros to the maximum weight.");
        self._pack.Set("sp_catapult_fling_sphere_peek_failuretwo02", "You look great, by the way. Very healthy.");
        self._pack.Set("sp_catapult_fling_sphere_peek_failuretwo03", "Try it now.");
        self._pack.Set("sp_catapult_fling_sphere_peek03", "A bloody bird! Right? Couldn't believe it either. And then the bird--");
        self._pack.Set("sp_catapult_fling_sphere_peek_failurethree01_1", "You seem to have defeated it's load-bearing capacity. Well done.");
        self._pack.Set("sp_catapult_fling_sphere_peek_failurethree01_2", "I'll just lower the ceiling.");

        self._pack.Set("sp_a2_ricochet01_1", "Enjoy this next test. I'm going to go to the surface. It's beautiful day out.");
        self._pack.Set("sp_a2_ricochet01_2", "Yesterday I saw a deer. If you solve this next test, maybe I'll let you ride an elevator all the way up to the break room.");
        self._pack.Set("sp_a2_ricochet01_3", "And I'll tell you about the time I saw a deer again.");

        self._pack.Set("glados_generated_deers_1", "Well, you passed the test. I didn't see the deer today. I did see some humans.");
        self._pack.Set("glados_generated_deers_2", "But with you here I've got more test subjects than I'll ever need.");

        self._pack.Set("sp_a2_bridge_intro01_1", "These bridges are made from natural light that I pump in from the surface.");
        self._pack.Set("sp_a2_bridge_intro01_2", "If you rubbed your cheek on one, it would be like standing outside with the sun shining on your face.");
        self._pack.Set("sp_a2_bridge_intro01_3", HTML.Color("It would also set your hair on fire", ColorEnum.PastelRed) + ". So don't actually do it.");

        self._pack.Set("sp_a2_bridge_intro03_1", "Excellent. You're a predator, and these tests are your prey.");
        self._pack.Set("sp_a2_bridge_intro03_2", "Speaking of which, I was researching sharks for an upcoming test.");
        self._pack.Set("sp_a2_bridge_intro03_3", "Do you know who else murders people who are only trying to help?");
        self._pack.Set("sp_a2_bridge_intro04", "Did you guess sharks? Because that's wrong. The correct answer is nobody. " + HTML.Color("Nobody but you is that pointlessly cruel", ColorEnum.PastelRed) + ".");

        self._pack.Set("sp_a2_bridge_the_gap02_1", "Perfect. The door is malfunctioning.");
        self._pack.Set("sp_a2_bridge_the_gap02_2", "I guess somebody's going to have to repair it.");
        self._pack.Set("sp_a2_bridge_the_gap02_3", "No, it's ok. I'll do that too.");
        self._pack.Set("sp_a2_bridge_the_gap02_4", "I'll be right back. Don't touch anything.");
        self._pack.Set("sp_trust_fling01", "Hey! Hey! Up here!");
        self._pack.Set("sp_trust_flingalt07", "I found some bird eggs up here. Just dropped 'em into the door mechanism. Shut it right down. I...AGH!");
        self._pack.Set("sp_trust_flingalt02", "BIRD! BIRD! BIRD! BIRD!");
        self._pack.Set("sp_trust_flingalt08", "[out of breath] Okay. That's probably the bird, isn't it? That laid the eggs! Livid!");
        self._pack.Set("sp_a2_bridge_the_gap_expo01", "Okay, look, the point is, we're gonna break out of here! Very soon, I promise, I promise!");
        self._pack.Set("sp_a2_bridge_the_gap_expo03", "I just have to figure out how. To break us out of here.");
        self._pack.Set("sp_a2_bridge_the_gap_expo06", "Here she comes! Keep testing! Remember: you never saw me!");
        self._pack.Set("sp_sphere_2nd_encounter_entrytwo01", "I went and spoke with the door mainframe. Let's just say he won't be... well, living anymore. Anyway, back to testing.");

        self._pack.Set("testchambermisc19_1", "Well done. In fact, you did so well, I'm going to note this on your file, in the commendations section.");
        self._pack.Set("testchambermisc19_2", "Oh, there's lots of room here.");
        self._pack.Set("testchambermisc19_3", "Did.... well...");
        self._pack.Set("testchambermisc19_4", "Enough.");

        self._pack.Set("turret_intro01_1", "This next test involves " + HTML.Color("Turrets", ColorEnum.PastelRed) + ". You remember them, right?");
        self._pack.Set("turret_intro01_2", "They're the pale, spherical things that are full of bullets. Oh wait. That's you in five seconds.");
        self._pack.Set("turret_intro01_3", "Good luck.");

        self._pack.Set("testchambermisc21_1", "To maintain a constant testing cycle, I simulate daylight at all hours.");
        self._pack.Set("testchambermisc21_2", "And add adrenal vapor to your oxygen supply. So you may be confused about the passage of time.");
        self._pack.Set("testchambermisc21_3", "The point is, yesterday was your birthday. I thought you'd want to know..");

        self._pack.Set("testchambermisc23_1", "You know how I'm going to live forever, but you're going to be dead in sixty years?");
        self._pack.Set("testchambermisc23_2", "Well, I've been working on a belated birthday present for you.");
        self._pack.Set("testchambermisc23_3", "Well... more of a belated birthday medical procedure.");
        self._pack.Set("testchambermisc23_4", "Well. Technically, it's a medical EXPERIMENT.");
        self._pack.Set("testchambermisc23_5", "What's important is, it's a present.");

        self._pack.Set("sp_a2_turret_intro01_1", "That jumpsuit you're wearing looks stupid.");
        self._pack.Set("sp_a2_turret_intro01_2", "That's not me talking, it's right here in your file.");
        self._pack.Set("sp_a2_turret_intro01_3", "On other people it looks fine, but right here a scientist has noted that on you it looks 'stupid'.");

        self._pack.Set("sp_a2_turret_intro03_1", "Well, what does a neck-bearded old engineer know about fashion?");
        self._pack.Set("sp_a2_turret_intro03_2", "He probably - Oh, wait. It's a she.");
        self._pack.Set("sp_a2_turret_intro03_3", "Still, what does she know?");
        self._pack.Set("sp_a2_turret_intro03_4", "Oh wait, it says she has a medical degree.");
        self._pack.Set("sp_a2_turret_intro03_5", "In fashion!");
        self._pack.Set("sp_a2_turret_intro03_6", "From France!");

        self._pack.Set("testchambermisc30_1", "I'm going through the list of test subjects in cryogenic storage.");
        self._pack.Set("testchambermisc30_2", "I managed to find two with your last name.");
        self._pack.Set("testchambermisc30_3", "A man and a woman.");
        self._pack.Set("testchambermisc30_4", "So that's interesting.");
        self._pack.Set("testchambermisc30_5", "It's a small world.");

        self._pack.Set("testchambermisc31_1", "I have a surprise waiting for you after this next test.");
        self._pack.Set("testchambermisc31_2", "Telling you would spoil the surprise, so I'll just give you a hint:");
        self._pack.Set("testchambermisc31_3", "It involves meeting two people you haven't seen in a long time.");

        self._pack.Set("testchambermisc24", "[hums 'For He's A Jolly Good Fellow']");

        self._pack.Set("testchambermisc39_1", "It says this next test was designed by one of Aperture's Nobel prize winners.");
        self._pack.Set("testchambermisc39_2", "It doesn't say what the prize was for.");
        self._pack.Set("testchambermisc39_3", "Well, I know it wasn't for Being Immune To Neurotoxin.");

        self._pack.Set("testchambermisc33_1", "I'll bet you think I forgot about your surprise.");
        self._pack.Set("testchambermisc33_2", "I didn't. In fact, we're headed to your surprise right now. After all these years. I'm getting choked up just thinking about it.");

        self._pack.Set("testchambermisc34", "Initiating surprise in three... two... one.");
        self._pack.Set("testchambermisc35", "I made it all up.");
        self._pack.Set("testchambermisc41", "Surprise.");
        self._pack.Set("sp_a2_column_blocker01", "Oh come on... If it makes you feel any better, they abandoned you at birth, so I very seriously doubt they'd even want to see you.");

        self._pack.Set("sp_a2_column_blocker03_1", "I feel awful about that surprise. Tell you what, let's give your parents a call right now.");
        self._pack.Set("sp_a2_column_blocker03_2", "[phone ringing]");
        self._pack.Set("sp_a2_column_blocker03_3", "The birth parents you are trying to reach do not love you. Please hang up. [Dial tone]");
        self._pack.Set("sp_a2_column_blocker04", "Oh, that's sad. But impressive. Maybe they weren't at the phone company.");

        self._pack.Set("sp_a2_column_blocker05", "Well, you know the old formula: Comedy equals tragedy plus time. And you have been asleep for a while. So I guess it's actually pretty funny when you do the math.");

        self._pack.Set("sp_a2_dilemma01", "I thought about our dilemma, and I came up with a solution that I honestly think works out best for one of both of us.");

        self._pack.Set("a2_triple_laser01", "Federal regulations require me to warn you that this next test chamber... is looking pretty good.");
        self._pack.Set("a2_triple_laser02", "That's right. The facility is completely operational again.");

        self._pack.Set("a2_triple_laser03_1", "I think these test chambers look even better than they did before. It was easy, really.");
        self._pack.Set("a2_triple_laser03_2", "You just have to look at things objectively, see what you don't need anymore, and trim out the fat.");
    }
}

class RussianLanguagePack
{
    # @type Dict<string,string>
    _pack = Dict();

    # @return Dict<string,string>
    function Load()
    {
        return self._pack;
    }

    # @return string
    function Language()
    {
        return I18n.RussianLanguage;
    }

    function Init()
    {
        # UI
        self._pack.Set("input.title", "Управление");
        self._pack.Set("input.admin_panel", "Панель управления");
        self._pack.Set("input.teleport_gui", "Телепорт");
        self._pack.Set("input.speedrun_gui", "Speedrun GUI");
        self._pack.Set("input.portal_blue", "Синий портал");
        self._pack.Set("input.portal_orange", "Оранжевый портал");
        self._pack.Set("input.reset_portals", "Сбросить порталы");
        self._pack.Set("input.interact", "Взаимодействие");
        self._pack.Set("input.skip_cutscene", "Пропустить диалог");
        self._pack.Set("input.zoom", "Зум");
        self._pack.Set("input.zoom_in_out", "Приблизить / Отдалить");
        self._pack.Set("input.quality", "Качество");
        self._pack.Set("notes.settings", "Рекоммендованная дальность прорисовки: 250"
                + String.Newline
                + "[" + Input.GetKeyName(InputGeneralEnum.Pause) + "] / Настройки / Графика / Дальность прорисовки");
        self._pack.Set("easter_eggs.title", "Пасхалок найдено");
    }
}


# Source: https://github.com/wastedziyun/Portal2_Better_Chinese
class ChineseLanguagePack
{
    # @type Dict<string,string>
    _pack = Dict();
    _type = 0;

    # @return Dict<string,string>
    function Load()
    {
        return self._pack;
    }

    # @return string
    function Language()
    {
        if (self._type == 0)
        {
            return I18n.ChineseLanguage;
        }
        return I18n.TraditionalChineseLanguage;
    }

    function Init(t)
    {
        self._type = t;
        # UI
        self._pack.Set("input.title", "按键绑定");
        self._pack.Set("input.admin_panel", "管理面板");
        self._pack.Set("input.teleport_gui", "传送界面");
        self._pack.Set("input.speedrun_gui", "速通界面");
        self._pack.Set("input.portal_blue", "蓝色传送门");
        self._pack.Set("input.portal_orange", "橙色传送门");
        self._pack.Set("input.reset_portals", "重置传送门");
        self._pack.Set("input.interact", "互动");
        self._pack.Set("input.skip_cutscene", "跳过过场动画");
        self._pack.Set("input.zoom", "缩放");
        self._pack.Set("input.zoom_in_out", "放大/缩小");
        self._pack.Set("input.quality", "画质预设");
        self._pack.Set("notes.settings", "推荐渲染距离：250" + String.Newline + "[" + Input.GetKeyName(InputGeneralEnum.Pause) + "] / 设置 / 图形 / 渲染距离");
        self._pack.Set("easter_eggs.title", "已发现彩蛋");

        # Cutscenes
        self._pack.Set("Level_1-1-0-prehub06", "你好，再次欢迎来到 " + HTML.Color("Aperture Science Enrichment Center", ColorEnum.PastelBlue) + "。");
        self._pack.Set("Level_1-1-0-announcer_generated_status", "请始终查看屏幕左侧，它包含有关您状态的有用信息以及所有所需的快捷键。");
        self._pack.Set("Level_1-1-0-announcer_generated_as_guild", "将 " + HTML.Color("'Aperture Science'", "a1c1f1") + " 添加到您的公会名称，以访问秘密功能。");
        self._pack.Set("Level_1-1-0-prehub10", "系统广播：传送门将会打开，紧急测试即将开始。3，2，1。");

        self._pack.Set("Level_1-1-0-prehub11", "基于方块和按钮的测试即使在严重紧急情况下仍然是科学的重要工具。按 " + HTML.Color("[" + Input.GetKeyName(InputManager.Interact) + "]", ColorEnum.PastelOrange) + " 来拾取" + HTML.Color("方块", ColorEnum.PastelBlue) + "并将其放在" + HTML.Color("按钮。", ColorEnum.PastelRed));

        self._pack.Set("Level_1-1-0-testchamber07", "您刚刚穿过一个 " + HTML.Color("Aperture Science 物质释放格栅", ColorEnum.PastelBlue) + "，它会蒸发任何接触到的 " + HTML.Color("Aperture Science", ColorEnum.PastelBlue) + " 设备。");

        self._pack.Set("Level_1-2-0-announcer_generated_btn_interact", "要与按钮互动，请将目标对准" + HTML.Color("红色部件", ColorEnum.PastelRed) + "，然后按" + HTML.Color("[" + Input.GetKeyName(InputManager.Interact) + "]", ColorEnum.PastelOrange) + "。");

        self._pack.Set("Level_1-2-0-good02", "很好。");

        self._pack.Set("Level_1-2-0-prehub20_1", "在您于测试尾声重新进入休息室之前，请抽空写下您的测验结果。");
        self._pack.Set("Level_1-2-0-prehub20_2", "光圈科技重返社会协会的同仁将会在社会重建完成时唤醒您以进行访谈。");

        self._pack.Set("Level_1-3-0-sp_intro_03_intro12", "嘿嘿！你成功了！");
        self._pack.Set("Level_1-3-0-sp_intro_03_intro09", "在那边的平台上应该要有一个" + HTML.Color("传送装置", ColorEnum.BluePortal) + "。");

        self._pack.Set("Level_1-4-0-prehub42", "下一个测试非常危险。为了帮助您在几乎必死无疑的的时刻能保持平静，我们将立刻播放舒缓的爵士乐。3，2，1。[舒缓的爵士乐]");
        self._pack.Set("Level_1-4-1-testchamber09_1", "做的不错！因为这个消息是预先录制的，我们涉及您表现的任何意见均属猜测。");
        self._pack.Set("Level_1-4-1-testchamber09_2", "请忽略任何不当的恭维。");

        self._pack.Set("Cutscene_Level_1_4_2", "EH EREH???...");

        self._pack.Set("Level_1-5-0-testchamber02_1", "如果丰富学习中心目前正遭受火球、陨石或其他太空物体的轰炸，");
        self._pack.Set("Level_1-5-0-testchamber02_2", "请避免进入无遮蔽的测试区域，无遮蔽之处并非测试中刻意安排的部分。");

        self._pack.Set("Level_1-6-0-testchamber10", "下一个测试需要应用" + HTML.Color("动量转化定律", ColorEnum.PastelOrange) + "。如果此物理定律在未来不再适用，就请上帝帮助您吧。");

        self._pack.Set("Level_1-6-1-prehub17", "如果您是在文明的废墟中发现这一设施的非本公司的同仁，欢迎！记住：测试就等同于未来，而未来就从您手中展开。");

        self._pack.Set("Level_1-6-1-prehub18_1", "做得不错，未来的先锋英雄！");
        self._pack.Set("Level_1-6-1-prehub18_2", "不过，如果您头脑简单、年事已高，或因辐射而不适合开启未来……");
        self._pack.Set("Level_1-6-1-prehub18_3", "……请回到您的原始部落，派遣一个更符合测试条件的人来。");

        self._pack.Set("Level_1-7-0-sp_intro_03_intro02", "嘿！喂喂！我在这里！");
        self._pack.Set("Level_1-7-0-demosphereintro04_1", "太棒了，你竟然找到了 " + HTML.Color("传送枪", ColorEnum.BluePortal) + "！");
        self._pack.Set("Level_1-7-0-demosphereintro04_2", "你知道吗？这正说明：到头来，脑子有问题的人才是真正的英雄，不是吗？勇气可嘉。");
        self._pack.Set("Level_1-7-0-demosphereintro02", "快在我背后的墙上开一个传送门，我们在房间的另一边会合。");

        self._pack.Set("Level_1-7-0-demosphereintro07", "就在我背后。");
        self._pack.Set("Level_1-7-0-demosphereintro08", "在我背后开个传送门就对了，然后穿过去，到另一头等着。");
        self._pack.Set("Level_1-7-0-demosphereintro09", "就在那里，开个小小的传送门，可以吗？开在我背后。然后穿过去。");
        self._pack.Set("Level_1-7-0-demosphereintro10", "好，我再解释一次。开一个传送门。开在我背后。可以吗？然后穿过去。");
        self._pack.Set("Level_1-7-0-demosphereintro11", "开一个传送门。就在我背后的墙壁上。然后穿过去。");
        self._pack.Set("Level_1-7-0-demosphereintro13", "穿过去。");
        self._pack.Set("Level_1-7-0-demosphereintro14", "穿过去，到另一头去。");
        self._pack.Set("Level_1-7-0-demosphereintro15", "穿过去。");

        self._pack.Set("Level_1-7-0-raildropintro01_1", "好的，听我说，这件事有点沉重。");
        self._pack.Set("Level_1-7-0-raildropintro01_2", "他们跟我说过绝对绝对不能脱离控制轨道，否则我会死。");
        self._pack.Set("Level_1-7-0-raildropintro01_3", "但我们已经别无选择……所以……" + HTML.Color("准备好接住我", ColorEnum.PastelOrange) + "，行吗？万一我脱轨后没死的话。");


        self._pack.Set("Level_1-7-0-demospherecatch02-1", HTML.Color("数到三", ColorEnum.PastelRed) + "。准备好了吗？");
        self._pack.Set("Level_1-7-0-demospherecatch02-2", HTML.Color("一...", ColorEnum.PastelBlue));
        self._pack.Set("Level_1-7-0-demospherecatch02-3", HTML.Color("二...", ColorEnum.PastelOrange));

        self._pack.Set("Level_1-7-0-demospherecatch05-1", HTML.Color("三！", ColorEnum.PastelRed));
        self._pack.Set("Level_1-7-0-demospherecatch05-2", "那也太高了，实在是太高了，不是吗，真的，那...");

        self._pack.Set("Level_1-7-0-demospherecatch07-1", "好吧，数到三似乎给了你太多犹豫和思考的时间。");
        self._pack.Set("Level_1-7-0-demospherecatch07-2", "那我们，呃，这次数到" + HTML.Color("一", ColorEnum.PastelRed) + "吧。");
        self._pack.Set("Level_1-7-0-demospherecatch07-3", "准备好了没？");


        self._pack.Set("Level_1-7-0-demospherefall04-1", HTML.Color("一！", ColorEnum.PastelRed));
        self._pack.Set("Level_1-7-0-demospherefall04-2", HTML.Color("接住我！接住我！接住我！接住我！接住我！接住我！啊！", ColorEnum.PastelRed));

        self._pack.Set("Level_1-7-0-demospherethud06", "我！没！死！我没死！[笑声]");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence04", "把我插到墙上那个装置里。好吗？我给你看个东西。你一定会非常惊讶。");

        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence01", "把我插入墙上那个装置里。我给你​​看样东西。");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence05", "去吧。把我塞进去就对了。");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence06", "就是那边的那个装置。把我插上去就行了。");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence07", "是有点棘手。不过... 把我插上去就对了。麻烦你。");
        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence08", "听起来是很低级。我老实说。的确是很低级。但其实并非如此。快把我插在棍子上。插进去。");

        self._pack.Set("Level_1-7-0-demospherefirstdoorwaysequence10", "嗯。对，你一直盯着我，我会做不下去。");

        self._pack.Set("demospherefirstdoorwaysequence11", "说真的啦，不开玩笑。请你回避一下好吗，一下就好？");
        self._pack.Set("demospherefirstdoorwaysequence02", "我没办法... 你一直盯着我会不好意思。[紧张地笑]");
        self._pack.Set("demospherefirstdoorwaysequence09", "你一直盯着我，我会害羞。请你.... 转个身好吗？");
        self._pack.Set("demospherefirstdoorwaysequence13", "好。[不安地笑] 你一直偷看我，我做不到。你有毛病喔。");
        self._pack.Set("demospherefirstdoorwaysequence16", "你后面那是什么？有个机器人插在一个装置上耶！是机器人喔！");
        self._pack.Set("demospherefirstdoorwaysequence20", "这样吧。你一直看着我，我会插不进去。虽说以我们的交情还要这样见外，是有点可悲。但拜托你转个身好吗。求求你？");

        self._pack.Set("turnaroundnow01", "好了，你可以转身了！");
        self._pack.Set("secretpanelopens07", "砰！秘密控制台！我在你转身的时候打开的。");
        self._pack.Set("callingoutinitial14", "把我带上。我们离开这里吧。");
        self._pack.Set("raildroppickup02", "哦，太棒了，谢谢你，好极了。");
        self._pack.Set("raildroppostfall02", "你还在吗？你可以把我捡起来吗？如果你在的话？");
        self._pack.Set("raildroppostfall03", "抱歉，你还在吗？能不能-- 请你把我捡起来？");
        self._pack.Set("raildroppostfall05", "在吗？请你-- 请你把我捡起来，好吗？");
        self._pack.Set("raildroppostfall08", "如果你真的在，可否麻烦你... 帮我一个小忙好吗？[紧张的笑] 行行好，把我捡起来就好。");
        self._pack.Set("raildroppostfall09", "往下看。我在哪里？我在哪里。");
        self._pack.Set("raildroppostfall15", "我不想烦你。你很忙，这是当然的。不过-- 我还在地板上。等着你把我捡起来。");
        self._pack.Set("raildroppostfall16", "我在地板上。需要你帮忙。一直都还在等着。我需要你的帮忙。");
        self._pack.Set("raildroppostfall17", "我还在地板上喔。等着有人来把我捡起来。恩。");
        self._pack.Set("raildroppostfall19", "看下面。谁在那里说话啊？是我啦！在你下面的地板上。需要你把我捡起来。");
        self._pack.Set("raildroppostfall20_1", "你在做什么？只是想独享五分钟的时光吗？也罢，你经历了那么多苦难，已经睡了不知道多久。");
        self._pack.Set("raildroppostfall20_2", "你的脑子严重受创，你在稍作休息。但现在，清醒点。站起来，把我捡起来。");

        self._pack.Set("gloriousfreedom03_1", "你看！没有轨道告诉我们该往哪走！哦，太棒了。我们可以随心所欲地去任何地方！");
        self._pack.Set("gloriousfreedom03_2", "等等，我们要去哪？说真的。等一下，我先拿一下我的轴承。");
        self._pack.Set("gloriousfreedom03_3", "嗯。其实，我们应该跟着轨道走。");

        self._pack.Set("gladosgantry20", "也许现在应该要快点跟你说明最新的情况。");
        self._pack.Set("gladosgantry21", "为了能逃走，我们必须经过她的测试室。");
        self._pack.Set("gladosgantry22", "她八成会杀了我们，如果，呃，如果她醒着的话。");

        self._pack.Set("wakeup_powerup02", "通电完毕。");
        self._pack.Set("sp_a1_wakeup_hacking11", "好好好。注意：计划改变。动作自然点。我们没做错什么事。");
        self._pack.Set("fgb_hello01", "哈啰！");
        self._pack.Set("chellgladoswakeup01", "哦...是你。");
        self._pack.Set("sp_a1_wakeup_hacking03", " 你认识她？");
        self._pack.Set("chellgladoswakeup04_1", "好久不见……");
        self._pack.Set("chellgladoswakeup04_2", "最近可好？");
        self._pack.Set("chellgladoswakeup05_1", "我一直忙着" + HTML.Color("死", ColorEnum.PastelRed) + "。");
        self._pack.Set("chellgladoswakeup05_2", "你知道的……在你" + HTML.Color("谋杀了我", ColorEnum.PastelRed) + "之后。");
        self._pack.Set("demospherepowerup07", "你做了什么？");
        self._pack.Set("a1_wakeup_pinchergrab02", "哦不不不... 不！天哪！");
        self._pack.Set("sp_a2_wheatley_ows_long03", "啊！");
        self._pack.Set("chellgladoswakeup06_1", "好吧，听着，我们双方都说了很多会让人后悔的话。");
        self._pack.Set("chellgladoswakeup06_2", "但我想我们可以为了科学先放下私人恩怨。" + HTML.Color("你这个怪物", ColorEnum.PastelRed) + "。");
        self._pack.Set("wakeup_outro01", "我得说，既然你排除万难把我叫醒，你一定" + HTML.Color("非常、非常", ColorEnum.PastelRed) + "喜欢测试。");
        self._pack.Set("wakeup_outro02", "我也喜欢，只是有一件小事我们得先搞定。");

        self._pack.Set("sp_incinerator_01_01", "我们到焚化室了，小心不要踩到之前你把我丢进炉里时没完全烧毁的残骸。");
        self._pack.Set("sp_incinerator_01_18", HTML.Color("双重传送装置", ColorEnum.OrangePortal) + "应该就在附近。找到后我们就可以开始测试了，就像从前一样。");

        self._pack.Set("sp_a2_intro1_found01", "很好，你找到了" + HTML.Color("双重传送装置", ColorEnum.OrangePortal) + "。前方应该有路返回测试区域。");

        self._pack.Set("sp_incinerator_01_08_1", "等测试一开始后，按规定我必须尽量少与你互动。");
        self._pack.Set("sp_incinerator_01_08_2", "所幸我们还没开始测试，这是我们唯一可以交谈的机会。");

        self._pack.Set("sp_incinerator_01_09_1", "你知道我从你的所作所为学到的最大教训是什么吗？");
        self._pack.Set("sp_incinerator_01_09_2", "我发现我有一个像黑盒子的快速储存功能。");
        self._pack.Set("sp_incinerator_01_09_3", "万一有大灾难发生，我生命的最后两分钟会被保存下来以供日后分析。");

        self._pack.Set("sp_incinerator_01_10", "我能够——不，准确地说，是被迫——一次又一次地重温你杀我的时刻，" + HTML.Color("永远", ColorEnum.PastelRed) + "。");
        self._pack.Set("sp_a2_intro1_found05", "要是你对其他人这么做，对方很可能会穷其一生向你" + HTML.Color("复仇", ColorEnum.PastelRed) + "。");
        self._pack.Set("sp_a2_intro1_found06_1", "幸好我心胸宽大，不会因此计较。");
        self._pack.Set("sp_a2_intro1_found06_2", "我很乐意把这一切抛诸脑后，回到工作中。");
        self._pack.Set("sp_a2_intro1_found06_3", "毕竟我们还有很多事要做，却只有大约60年的时间。");
        self._pack.Set("sp_a2_intro1_found06_4", "大概如此吧，我可没带精算表在身边。");
        self._pack.Set("sp_a2_intro1_found07_1", "但重要的是你回来了，" + HTML.Color("和我在一起", ColorEnum.PastelRed) + "。而且我现在已经识破了你所有的小把戏。");
        self._pack.Set("sp_a2_intro1_found07_2", "所以，没什么能阻止我们继续测试……" + HTML.Color("在你余生", ColorEnum.PastelRed) + "。");
        self._pack.Set("sp_a2_intro1_found08", "在那之后...谁知道呢？说不定我会去找个癖好，像是把死人弄活，也许吧。");

        self._pack.Set("sarcasmcore01", "[嘀]「讽刺测试」完成。[嘀]");
        self._pack.Set("sp_laser_redirect_intro_entry02", "喔太好了，那又上线了，在你进行这个刚开始的简单测试时，我会让其他所有东西重新运作起来。");
        self._pack.Set("sp_laser_redirect_intro_entry03", "该测试涉及" + HTML.Color("致命激光", ColorEnum.PastelRed) + "，并在受测者被锁在仅有致命激光的房间中时观察其反应。");

        self._pack.Set("sp_a2_laser_intro_ending02", "不错，我都忘了你有多擅长这个了。但你应该调整一下步调，我们还有一堆测试要做呢。");

        self._pack.Set("sp_a2_laser_stairs_intro02_1", "接下来的测试将涉及" + HTML.Color("激光折射方块", ColorEnum.PastelPurple) + "。");
        self._pack.Set("sp_a2_laser_stairs_intro02_2", "在你……嗯，发作之前，我刚刚把它们造好了。");
        self._pack.Set("sp_a2_laser_stairs_intro02_3", "所以现在我们可以一起看看这些方块的表现如何。");
        self._pack.Set("sp_a2_laser_stairs_intro03", "在那个角落里应该有一个。");

        self._pack.Set("sp_laser_powered_lift_completion02_1", "好极了，测试结果如下：");
        self._pack.Set("sp_laser_powered_lift_completion02_2", HTML.Color("你是个可怕的人", ColorEnum.PastelRed) + "。");
        self._pack.Set("sp_laser_powered_lift_completion02_3", "报告上写的就是：" + HTML.Color("'可怕的人'", ColorEnum.PastelRed) + "。我们甚至没有针对这点进行测试。");

        self._pack.Set("sp_a2_dual_lasers_intro01_1", "别让那个" + HTML.Color("“可怕的人”", ColorEnum.PastelRed) + "的说法打击你，那只是一个数据点。");
        self._pack.Set("sp_a2_dual_lasers_intro01_2", "如果这能让你感觉好些，科学已经证实你生母将你遗弃在门口台阶的决定。");

        self._pack.Set("sp_laser_redirect_intro_completion01", "恭喜你， 我不是在恭喜你的测试结果。");
        self._pack.Set("sp_laser_redirect_intro_completion03_1", "多数人从休眠中醒来时都会严重营养不良。");
        self._pack.Set("sp_laser_redirect_intro_completion03_2", "我要恭喜你打破常规，不知怎的还胖了好几斤。");

        self._pack.Set("sp_laser_over_goo_entry01", "等我一下。");
        self._pack.Set("sp_a2_laser_over_goo_intro01_1", "你探索这些测试室的速度比我建造它们的速度还快，所以随时可以放慢脚步……");
        self._pack.Set("sp_a2_laser_over_goo_intro01_2", "……并随意做你在不破坏这座设施时会做的任何事。");

        self._pack.Set("sp_laser_over_goo_completion01_1", "我会帮你记上一笔，我想你确实在听我说话。");
        self._pack.Set("sp_laser_over_goo_completion01_2", "但说实话，你没必要走得那么慢。");


        self._pack.Set("faith_plate_intro01_1", "下个测试会用到" + HTML.Color("光圈科技空中弹射板", ColorEnum.PastelBlue) + "。");
        self._pack.Set("faith_plate_intro01_2", "它是最初计划的一部分，用来调查受测者被弹射到空中时解决问题的能力。");
        self._pack.Set("faith_plate_intro01_3", "调查结果提供了很有用的资讯：" + HTML.Color("他们无能为力", ColorEnum.PastelRed) + "。祝你好运！");


        self._pack.Set("sp_catapult_intro_completion01", "来看看下一个测试是什么。哦，" + HTML.Color("进阶对空弹射板", ColorEnum.PastelBlue) + "。");
        self._pack.Set("sp_trust_fling_entry01", "好好无忧无虑地遨游天际吧。");
        self._pack.Set("sp_trust_fling_entry02", "我得去那个全部是玻璃做的侧房里扫掉十五英亩的碎玻璃，就我一个人。");

        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_1", "你打开书，发现上面写着："
            + String.Newline
            + "“仅限光圈科技员工阅读。最低智商：200。你的？可疑。”"
            + String.Newline
            + "请合上此书以免混淆。");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_2", "作为一名获授权的" + HTML.Color("光圈科技", "a1c1f1") + "员工，书上的加密文字自行重排，变得大致可读。");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_3", "恭喜你达到了最低资格要求。");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_4", "你翻开书页，里面密密麻麻记录着复杂的公式、测试日志和令人不安的图表。");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_5", "当你浏览这些内容时，一段由一位" + HTML.Color("光圈科技", "a1c1f1") + "同事留下的手写便笺缓缓显现……");
        self._pack.Set("Cutscene_EasterEgg_StrangeBook_1_6", "致未来的读者：这些公式是正确的。结果？存疑。祝你好运！");


        self._pack.Set("fizzlecube01", "哦，我不小心在你完成测试前就把它分解了吗？真是对不起。");
        self._pack.Set("fizzlecube03", "再拿一个。");
        self._pack.Set("fizzlecube05", "喔，不，我不小心也把那个分解掉了。");
        self._pack.Set("fizzlecube06_1", "仓库里堆满了这种垃圾。");
        self._pack.Set("fizzlecube06_2", "完全没用，我很乐意把它们扔掉。");

        self._pack.Set("sp_a2_pit_flings03_1", "对了，每个测试室的出口处都装有" + HTML.Color("物质分解网", ColorEnum.PastelBlue) + "。");
        self._pack.Set("sp_a2_pit_flings03_2", "这样受测者就无法将测试物品偷带出测试区域。");
        self._pack.Set("sp_a2_pit_flings03_3", "但它坏掉了。");
        self._pack.Set("sp_a2_pit_flings02", HTML.Color("别，带，走，任，何，东，西。", ColorEnum.PastelRed));

        self._pack.Set("sp_a2_pit_flings06", "我想它当时正要说：" + HTML.Color("'我爱你'", ColorEnum.PastelPurple) + "。它们当然是有知觉的，只是我们有很多。");

        self._pack.Set("sp_a2_fizzler_intro01", "下个测试会用到分解网。记得吗？我在上个测试区有跟你提过，但那个实验室没有的。");
        self._pack.Set("sp_a2_fizzler_intro04", "喔不，涡轮机又坏了，这座设施的每一寸地方都需要我照料，我得走了。等等，下个测试是需要一些解说，我跟你快速讲解一下好了。");
        self._pack.Set("sp_a2_fizzler_intro05", "[含糊不清的话语]");
        self._pack.Set("sp_a2_fizzler_intro06", " 好了。如果你有任何问题，只要慢放我所说的话就好。在测试中好好保护你自己吧，我等下就回来。");

        self._pack.Set("sp_catapult_fling_sphere_peek01", "嘿！嘿！是我！我没事！");
        self._pack.Set("sp_catapult_fling_sphere_peek_failureone01_1", "我回来了！");
        self._pack.Set("sp_catapult_fling_sphere_peek_failureone01_2", "这里的" + HTML.Color("空中弹射板", ColorEnum.PastelBlue) + "正在发出求救信号。");
        self._pack.Set("sp_catapult_fling_sphere_peek_failureone02", "你把它弄坏了，是吧？");
        self._pack.Set("sp_catapult_fling_sphere_peek_failureone03", "去，试试看吧。");
        self._pack.Set("sp_catapult_fling_sphere_peek02", "你不会相信发生什么事情！我刚才躺在那边，你以为我玩完了，但其实我没有，后来发生的事是--");
        self._pack.Set("sp_catapult_fling_sphere_peek_failuretwo01_1", "嗯，这个弹射板肯定没按照你……丰厚的……体重来校准。");
        self._pack.Set("sp_catapult_fling_sphere_peek_failuretwo01_2", "我来把最大承重再加几个零。");
        self._pack.Set("sp_catapult_fling_sphere_peek_failuretwo02", "(嘟嘟嘟) 你看起来很好，顺带一提，非常健康。");
        self._pack.Set("sp_catapult_fling_sphere_peek_failuretwo03", "现在试试看。");
        self._pack.Set("sp_catapult_fling_sphere_peek03", "一只他喵的鸟！对吧？我本来也不相信。后来那只鸟-");
        self._pack.Set("sp_catapult_fling_sphere_peek_failurethree01_1", "看来你已经超过了它的承重能力，干得好。");
        self._pack.Set("sp_catapult_fling_sphere_peek_failurethree01_2", "我来把天花板放低一些。");

        self._pack.Set("sp_a2_ricochet01_1", "好好享受接下来的测试吧，我要去地表上逛逛，今天外面天气不错。");
        self._pack.Set("sp_a2_ricochet01_2", "昨天我还看到了一只鹿。如果你通过了接下来的测试，也许我会让你搭电梯直接到上面的休息室。");
        self._pack.Set("sp_a2_ricochet01_3", "然后我再跟你讲讲我再次看到鹿的情景。");

        self._pack.Set("glados_generated_deers_1", "嗯，你通过了测试。我今天没看到鹿，但看到了几个人类。");
        self._pack.Set("glados_generated_deers_2", "有你在这里，我的测试对象多得用不完。");

        self._pack.Set("sp_a2_bridge_intro01_1", "这些桥梁是我从地表汲取的自然光构成的。");
        self._pack.Set("sp_a2_bridge_intro01_2", "如果你把脸贴上去，会感觉就像在户外让阳光晒在脸上一样。");
        self._pack.Set("sp_a2_bridge_intro01_3", HTML.Color("不过它也会让你的头发着火", ColorEnum.PastelRed) + "。所以别真的去做。");

        self._pack.Set("sp_a2_bridge_intro03_1", "太好了！你就像掠食者，这些测试就是你的猎物。");
        self._pack.Set("sp_a2_bridge_intro03_2", "说到这个，我在为接下来的测试研究鲨鱼。");
        self._pack.Set("sp_a2_bridge_intro03_3", "你知道还有谁会为了帮助别人而杀人吗？");

        self._pack.Set("sp_a2_bridge_intro04", "你是不是猜了鲨鱼？那是错的。正确答案是没有人。" + HTML.Color("除了你，没有人会如此无谓地残忍", ColorEnum.PastelRed) + "。");

        self._pack.Set("sp_a2_bridge_the_gap02_1", "完美。门出现故障。");
        self._pack.Set("sp_a2_bridge_the_gap02_2", "看来得有人来修理它。");
        self._pack.Set("sp_a2_bridge_the_gap02_3", "不用，我来修就行。");
        self._pack.Set("sp_a2_bridge_the_gap02_4", "我马上回来，别碰任何东西。");

        self._pack.Set("sp_trust_fling01", "喂！喂！这里啦，在上面！");
        self._pack.Set("sp_trust_flingalt07", "我在这上头发现一些鸟蛋。把鸟蛋丢进门的机关里，立刻就可以把它给关掉。我-- 啊！");
        self._pack.Set("sp_trust_flingalt02", "鸟鸟鸟鸟");
        self._pack.Set("sp_trust_flingalt08", "[喘气] 好。应该是鸟，对吧？是鸟下蛋的！真该死！");
        self._pack.Set("sp_a2_bridge_the_gap_expo01", "好，听着，重点是，我们会逃出这里！很快就能逃出去，我保证，我保证！");
        self._pack.Set("sp_a2_bridge_the_gap_expo03", "我只是需要想一下该怎么做。我们就能一起逃出去。");
        self._pack.Set("sp_a2_bridge_the_gap_expo06", "她来了！继续测试！记住：你从没见过我！");
        self._pack.Set("sp_sphere_2nd_encounter_entrytwo01", "我去和门的主机讲过话了，它应该再也...活不了了。好了，回去测试吧。");

        self._pack.Set("testchambermisc19_1", "干得好。事实上，你做得太棒了，我要在你的档案表彰栏里记上一笔。");
        self._pack.Set("testchambermisc19_2", "哦，这里还有很多空位。");
        self._pack.Set("testchambermisc19_3", "就……那样吧……");
        self._pack.Set("testchambermisc19_4", "够了。");

        self._pack.Set("turret_intro01_1", "接下来的测试会有" + HTML.Color("炮塔", ColorEnum.PastelRed) + "。你记得它们吧？");
        self._pack.Set("turret_intro01_2", "它们是那些装满子弹的白色球状物体。等等，你只剩五秒钟了。");
        self._pack.Set("turret_intro01_3", "祝你好运。");

        self._pack.Set("testchambermisc21_1", "为了维持固定的测试周期，我把时间模拟成全天候的白昼。");
        self._pack.Set("testchambermisc21_2", "并在你的氧气供应中加入肾上腺素喷雾，所以你可能会对时间的流逝感到困惑。");
        self._pack.Set("testchambermisc21_3", "重点是，昨天是你的生日，我猜你会想知道这一点。");

        self._pack.Set("testchambermisc23_1", "你知道我将永生，而你却会在六十年后死去吗？");
        self._pack.Set("testchambermisc23_2", "我一直在为你准备一份迟到的生日礼物。");
        self._pack.Set("testchambermisc23_3", "或者，更确切地说，是一场迟到的生日医疗疗程。");
        self._pack.Set("testchambermisc23_4", "好吧，严格来说，这是一次医学实验。");
        self._pack.Set("testchambermisc23_5", "重要的是，这是一份礼物。");

        self._pack.Set("sp_a2_turret_intro01_1", "那件跳伞装穿在你身上看起来很蠢。");
        self._pack.Set("sp_a2_turret_intro01_2", "[翻页声]那不是我说的，是你的档案里写的。");
        self._pack.Set("sp_a2_turret_intro01_3", "穿在其他人身上还好，但这里有位科学家注记说它穿在你身上很“蠢”。");

        self._pack.Set("sp_a2_turret_intro03_1", "别管他，一个胡子拉碴的老工程师懂什么时尚？");
        self._pack.Set("sp_a2_turret_intro03_2", "他大概就是……哦，等等，是个女的。");
        self._pack.Set("sp_a2_turret_intro03_3", "不过，她懂什么呢？");
        self._pack.Set("sp_a2_turret_intro03_4", "哦，等等，档案里写她有医学学位。");
        self._pack.Set("sp_a2_turret_intro03_5", "还有时尚学位！");
        self._pack.Set("sp_a2_turret_intro03_6", "是在法国拿到的！");

        self._pack.Set("testchambermisc30_1", "我正在审查冷冻保存中的受测者名单。");
        self._pack.Set("testchambermisc30_2", "我设法找到了两个与你同姓的人。");
        self._pack.Set("testchambermisc30_3", "一个男人，一个女人。");
        self._pack.Set("testchambermisc30_4", "这真有趣。");
        self._pack.Set("testchambermisc30_5", "世界真小。");

        self._pack.Set("testchambermisc31_1", "下个测试后我有个惊喜给你。");
        self._pack.Set("testchambermisc31_2", "我不想剧透，所以只给你一点提示：");
        self._pack.Set("testchambermisc31_3", "这将让你与久未谋面的两个人重逢。");

        self._pack.Set("testchambermisc24", "[哼唱生日快乐歌]");

        self._pack.Set("testchambermisc39_1", "上面说接下来的测试是由「光圈科技」的一个诺贝尔奖得主设计的。");
        self._pack.Set("testchambermisc39_2", "不过它没说那人得的是什么奖。");
        self._pack.Set("testchambermisc39_3", "反正我知道绝对不会是「神经毒气免疫」奖。");

        self._pack.Set("testchambermisc33_1", "我敢打赌你一定觉得我忘了要给你的惊喜。");
        self._pack.Set("testchambermisc33_2", "我没有。事实上，我们现在正要去看你的惊喜。经历了这么多年，我光是想想就感动得想哭。");

        self._pack.Set("testchambermisc34", "惊喜揭晓倒数：三、二、一。");
        self._pack.Set("testchambermisc35", "全都是我编的。");
        self._pack.Set("testchambermisc41", " 惊喜来啰。");
        self._pack.Set("sp_a2_column_blocker01", "算了吧...如果这能让你好过点的话————但他们在你出生时就不要你了，我非常怀疑他们是否还会想见你。");

        self._pack.Set("sp_a2_column_blocker03_1", "我觉得那个惊喜真是太糟了，不如这样，我们马上来给你父母拨个电话吧。");
        self._pack.Set("sp_a2_column_blocker03_2", "[电话铃响]");
        self._pack.Set("sp_a2_column_blocker03_3", "你要找的亲生父母并不爱你，请挂断。[电话挂断声]");

        self._pack.Set("sp_a2_column_blocker04", "哦那太悲哀了，不过那留言也太让人印象深刻了，说不定他们在电话公司工作。");

        self._pack.Set("sp_a2_column_blocker05", "你知道那个老公式：喜剧等于悲剧加时间，你又睡了这么久，所以我觉得你做算术时一定很好玩。");

        self._pack.Set("sp_a2_dilemma01", "所以，我想过我们之间的尴尬状况了，我想到一个好办法可以解决我们其中一人的处境。");

        self._pack.Set("a2_triple_laser01", "联邦法令规定我必须警告你，下一个测试室...看起来非常不错。");
        self._pack.Set("a2_triple_laser02", "没错，设施又恢复运作了。");

        self._pack.Set("a2_triple_laser03_1", "我觉得这些测试室看起来比以前更好。真的很简单。");
        self._pack.Set("a2_triple_laser03_2", "你只要客观地看待事物，找出不再需要的东西，然后剔除多余部分。");
    }
}

#######################
# CUTSCENES
#######################

cutscene Cutscene_Level_0_END
{
    _name = "Cutscene_Level_0_END";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName("Cutscene_Level_0_END");
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();
        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";
        Cutscene.ShowDialogue(icon, title, "Congratulations! You have reached the end...for now.");
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, "Thanks for playing this mode.");
        CutsceneManager.Wait(4.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(ProfileIconEnum.Titan14, title,
            HTML.Color("*Disabling your pause button*", ColorEnum.PastelRed)
            + String.Newline
            + HTML.Color("Actually, why do we have to leave right now?", ColorEnum.PastelRed)
        );
        SoundManager.Play(HumanSoundEnum.FlareLaunch);
        Input.SetKeyDefaultEnabled(InputGeneralEnum.Pause, false);
        Game.SetPlaylist("Battle");
        CutsceneManager.Wait(6.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(ProfileIconEnum.Titan14, title, HTML.Color("Do you have any ideas how good this feels? Looking at you. Struggling with puzzles...", ColorEnum.PastelRed));
        CutsceneManager.Wait(5.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Game.SetPlaylist("Default");
        Cutscene.ShowDialogue(icon, title, "~Just kidding. Thanks for playing once again. <3");
        CutsceneManager.Wait(4.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Game.SetPlaylist("Peaceful");
        Cutscene.ShowDialogue(icon, title, HTML.Color("*Enabling teleport menu.*", ColorEnum.PastelBlue) + String.Newline + HTML.Color("*Enabling pause button.*", ColorEnum.PastelBlue));
        Network.MyPlayer.SetCustomProperty("TELEPORT_ACCESS", 1);
        SoundManager.Play(HumanSoundEnum.Checkpoint);
        CutsceneManager.Wait(1.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Input.SetKeyDefaultEnabled(InputGeneralEnum.Pause, true);
        SoundManager.Play(HumanSoundEnum.Checkpoint);
        CutsceneManager.Wait(1.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, "Now you can press [" + Input.GetKeyName(InputManager.TeleportGUI) + "] and teleport wherever you want.");
        CutsceneManager.Wait(4.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, "Add " + HTML.Color("'Aperture Science'", "a1c1f1") + " to your Guild Name, to access secret features.");
        CutsceneManager.Wait(7.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_1_0
{
    _name = "Cutscene_Level_1_1_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();
        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";
        SoundManager.PlayCustom("Level_1-1-0", "prehub06");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-1-0-prehub06"));
        CutsceneManager.Wait(4.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-1-0", "prehub06");

        SoundManager.PlayCustom("Level_1-1-0", "announcer_generated_status");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-1-0-announcer_generated_status"));
        CutsceneManager.Wait(7.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-1-0", "announcer_generated_status");

        SoundManager.PlayCustom("Level_1-1-0", "announcer_generated_as_guild");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-1-0-announcer_generated_as_guild"));
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-1-0", "announcer_generated_as_guild");

        SoundManager.PlayCustom("Level_1-1-0", "prehub10");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-1-0-prehub10"));
        CutsceneManager.Wait(5.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-1-0", "prehub10");

        if (self._activatable != null)
        {
            SoundManager.Play(HumanSoundEnum.Checkpoint);
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-1-0", "prehub06");
        SoundManager.StopCustom("Level_1-1-0", "prehub08");
        SoundManager.StopCustom("Level_1-1-0", "prehub10");
        SoundManager.StopCustom("Level_1-1-0", "announcer_generated_status");
        SoundManager.StopCustom("Level_1-1-0", "announcer_generated_as_guild");

        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_1_1
{
    _name = "Cutscene_Level_1_1_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();
        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-1-0", "prehub11");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-1-0-prehub11"));
        CutsceneManager.Wait(1.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        if (self._activatable != null)
        {
            SoundManager.Play(HumanSoundEnum.Checkpoint);
            self._activatable.Activate();
        }

        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-1-0", "prehub11");

        SoundManager.PlayCustom("Level_1-1-0", "announcer_generated_cube_button");
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-1-0", "announcer_generated_cube_button");

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-1-0", "prehub11");
        SoundManager.StopCustom("Level_1-1-0", "announcer_generated_cube_button");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_1_2
{
    _name = "Cutscene_Level_1_1_2";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-1-0", "testchamber07");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-1-0-testchamber07"));
        CutsceneManager.Wait(6.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-1-0", "testchamber07");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-1-0", "testchamber07");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_2_0
{
    _name = "Cutscene_Level_1_2_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-2-0", "announcer_generated_btn_interact");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-2-0-announcer_generated_btn_interact"));
        CutsceneManager.Wait(5.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-2-0", "announcer_generated_btn_interact");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-2-0", "announcer_generated_btn_interact");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_2_1
{
    _name = "Cutscene_Level_1_2_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-2-0", "good02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-2-0-good02"));
        CutsceneManager.Wait(0.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-2-0", "good02");

        # SoundManager.PlayCustom("Level_1-2-0", "good02");
        # Cutscene.ShowDialogue(icon, title, "Because of the technical difficulties we are currently experiencing, your test environment is unsupervised.");
        # CutsceneManager.Wait(1.0);
        # while (!CutsceneManager.IsTimerDone())
        # {
        #     if (CutsceneManager.SkipSent())
        #     {
        #         self.Skip();
        #         return;
        #     }
        #     # wait Time.TickTime;
        # }
        # SoundManager.StopCustom("Level_1-2-0", "good02");

        SoundManager.PlayCustom("Level_1-2-0", "prehub20");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-2-0-prehub20_1"));
        CutsceneManager.Wait(6.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-2-0-prehub20_2"));
        CutsceneManager.Wait(5.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-2-0", "prehub20");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-2-0", "good02");
        SoundManager.StopCustom("Level_1-2-0", "prehub20");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_3_0
{
    _name = "Cutscene_Level_1_3_0";
    # @type Activatable
    _activatable = null;
    _cameraRotation = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan10;
        title = "Wheatley";

        c1Obj = Map.FindMapObjectByName("CameraRef 1-3-0");
        c2Obj = Map.FindMapObjectByName("CameraRef 1-3-1");
        wObj = Map.FindMapObjectByName("WheatleyRef 1-3-0");
        pObj = Map.FindMapObjectByName("PortalGun 1-3-0");

        self._cameraRotation = Camera.Rotation;
        Camera.SetPosition(c1Obj.Position);
        Camera.SetVelocity(Vector3(0, 0, -2.0));
        Camera.LookAt(wObj.Position);

        SoundManager.PlayCustom("Level_1-3-0", "sp_intro_03_intro12");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-3-0-sp_intro_03_intro12"));
        CutsceneManager.Wait(2.0);
        while(!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            Camera.LookAt(wObj.Position);
        }
        SoundManager.StopCustom("Level_1-3-0", "sp_intro_03_intro12");

        SoundManager.PlayCustom("Level_1-3-0", "sp_intro_03_intro09");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-3-0-sp_intro_03_intro09"));
        CutsceneManager.Wait(0.5);
        while(!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            Camera.LookAt(wObj.Position);
        }

        Camera.SetPosition(c2Obj.Position);
        Camera.LookAt(pObj.Position);
        Camera.SetVelocity(Camera.Forward * 0.5);
        CutsceneManager.Wait(2.5);
        while(!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        SoundManager.StopCustom("Level_1-3-0", "sp_intro_03_intro09");
        Camera.SetRotation(self._cameraRotation);
        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-3-0", "sp_intro_03_intro09");
        SoundManager.StopCustom("Level_1-3-0", "sp_intro_03_intro12");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
        Camera.SetRotation(self._cameraRotation);
    }
}

cutscene Cutscene_Level_1_4_0
{
    _name = "Cutscene_Level_1_4_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-4-0", "prehub42");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-4-0-prehub42"));
        CutsceneManager.Wait(11.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.HideDialogue();
        Game.SetPlaylist("Peaceful");

        CutsceneManager.Wait(14.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_1-4-0", "prehub42");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-4-0", "prehub42");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_4_1
{
    _name = "Cutscene_Level_1_4_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-4-1", "testchamber09");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-4-1-testchamber09_1"));
        CutsceneManager.Wait(6.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-4-1-testchamber09_2"));
        CutsceneManager.Wait(2.6);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-4-1", "testchamber09");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-4-1", "testchamber09");
        self._activatable.Activate();
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_4_2
{
    _name = "Cutscene_Level_1_4_2";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Ymir1;
        title = Network.MyPlayer.Name;

        Cutscene.ShowDialogue(icon, title, I18n.Get("Cutscene_Level_1_4_2"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_5_0
{
    _name = "Cutscene_Level_1_5_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-5-0", "testchamber02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-5-0-testchamber02_1"));
        CutsceneManager.Wait(5.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-5-0-testchamber02_2"));
        CutsceneManager.Wait(6.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-5-0", "testchamber02");

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-5-0", "testchamber02");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_6_0
{
    _name = "Cutscene_Level_1_6_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-6-0", "testchamber10");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-6-0-testchamber10"));
        CutsceneManager.Wait(7.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-6-0", "testchamber10");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-6-0", "testchamber10");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_6_1
{
    _name = "Cutscene_Level_1_6_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-6-1", "prehub17");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-6-1-prehub17"));
        CutsceneManager.Wait(10.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-6-1", "prehub17");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-6-1", "prehub17");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_6_2
{
    _name = "Cutscene_Level_1_6_2";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-6-1", "prehub18");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-6-1-prehub18_1"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-6-1-prehub18_2"));
        CutsceneManager.Wait(5.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-6-1-prehub18_3"));
        CutsceneManager.Wait(4.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-6-1", "prehub18");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-6-1", "prehub18");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_7_0
{
    _name = "Cutscene_Level_1_7_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan10;
        title = "Wheatley";
        SoundManager.PlayCustom("Level_1-7-0", "sp_intro_03_intro02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-sp_intro_03_intro02"));
        CutsceneManager.Wait(3.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "sp_intro_03_intro02");

        SoundManager.PlayCustom("Level_1-7-0", "demosphereintro04");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demosphereintro04_1"));
        CutsceneManager.Wait(3.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demosphereintro04_2"));
        CutsceneManager.Wait(7.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro04");

        SoundManager.PlayCustom("Level_1-7-0", "demosphereintro02");
        Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demosphereintro02"), 3.6);
        CutsceneManager.Wait(2.25);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        if (self._activatable != null)
        {
            self._activatable.Activate();
            SoundManager.Play(HumanSoundEnum.Checkpoint);
        }
        CutsceneManager.Wait(5.5);
        while (!CutsceneManager.SkipSent())
        {
            if (CutsceneManager.IsTimerDone())
            {
                Cutscene.HideDialogue();
                SoundManager.StopCustom("Level_1-7-0", "demosphereintro02");
                SoundManager.StopCustom("Level_1-7-0", "demosphereintro07");
                SoundManager.StopCustom("Level_1-7-0", "demosphereintro08");
                SoundManager.StopCustom("Level_1-7-0", "demosphereintro09");
                SoundManager.StopCustom("Level_1-7-0", "demosphereintro10");
                SoundManager.StopCustom("Level_1-7-0", "demosphereintro11");
                SoundManager.StopCustom("Level_1-7-0", "demosphereintro13");
                SoundManager.StopCustom("Level_1-7-0", "demosphereintro14");
                SoundManager.StopCustom("Level_1-7-0", "demosphereintro15");

                index = Random.RandomInt(1, 9);

                if (index == 1)
                {
                    addTime = 1.0;
                    SoundManager.PlayCustom("Level_1-7-0", "demosphereintro07");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demosphereintro07"), addTime);
                }
                elif (index == 2)
                {
                    addTime = 3.5;
                    SoundManager.PlayCustom("Level_1-7-0", "demosphereintro08");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demosphereintro08"), addTime);
                }
                elif (index == 3)
                {
                    addTime = 3.8;
                    SoundManager.PlayCustom("Level_1-7-0", "demosphereintro09");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demosphereintro09"), addTime);
                }
                elif (index == 4)
                {
                    addTime = 4.6;
                    SoundManager.PlayCustom("Level_1-7-0", "demosphereintro10");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demosphereintro10"), addTime);
                }
                elif (index == 5)
                {
                    addTime = 3.6;
                    SoundManager.PlayCustom("Level_1-7-0", "demosphereintro11");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demosphereintro11"), addTime);
                }
                elif (index == 6)
                {
                    addTime = 1.0;
                    SoundManager.PlayCustom("Level_1-7-0", "demosphereintro13");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demosphereintro13"), addTime);
                }
                elif (index == 7)
                {
                    addTime = 1.4;
                    SoundManager.PlayCustom("Level_1-7-0", "demosphereintro14");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demosphereintro14"), addTime);
                }
                else
                {
                    addTime = 1.0;
                    SoundManager.PlayCustom("Level_1-7-0", "demosphereintro15");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demosphereintro15"), 6.6);
                }

                CutsceneManager.Wait(3.0 + addTime);
            }
        }

        Cutscene.HideDialogue();
        SoundManager.StopCustom("Level_1-7-0", "sp_intro_03_intro02");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro04");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro02");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro07");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro08");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro09");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro10");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro11");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro13");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro14");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro15");
        self._activatable.Deactivate();
        self.Skip();
        return;

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        self._activatable.Deactivate();
        SoundManager.StopCustom("Level_1-7-0", "sp_intro_03_intro02");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro04");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro02");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro07");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro08");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro09");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro10");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro11");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro13");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro14");
        SoundManager.StopCustom("Level_1-7-0", "demosphereintro15");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_7_1
{
    _name = "Cutscene_Level_1_7_1";
    # @type Activatable
    _activatable = null;
    # @type MapObject
    _wheatley = null;
    # @type Movable
    _wheatleyMovable = null;
    _secretPanelActivatable = null;
    _secretLockerActivatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
        wheatleyComp = Map.FindMapObjectByName("WheatleyRef 1-7-0").GetComponent("WheatleyRef");
        self._wheatley = wheatleyComp._ref;
        self._wheatleyMovable = self._wheatley.GetComponent("Movable");
        self._secretPanelActivatable = Map.FindMapObjectByName("SecretPanel_1_7_1").GetComponent("Activatable");
        self._secretLockerActivatable = Map.FindMapObjectByName("SecretLocker_1_7_1").GetComponent("Activatable");
    }

    coroutine Start()
    {
        CutsceneManager.SetCanPlay("Cutscene_Level_1_7_2", false);
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan10;
        title = "Wheatley";

        SoundManager.PlayCustom("Level_1-7-0", "raildropintro01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-raildropintro01_1"));
        CutsceneManager.Wait(4.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-raildropintro01_2"));
        CutsceneManager.Wait(8.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-raildropintro01_3"));
        CutsceneManager.Wait(9.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "raildropintro01");

        SoundManager.PlayCustom("Level_1-7-0", "demospherecatch02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherecatch02-1"));
        CutsceneManager.Wait(2.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherecatch02-2"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherecatch02-3"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "demospherecatch02");

        SoundManager.PlayCustom("Level_1-7-0", "demospherecatch05");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherecatch05-1"));
        CutsceneManager.Wait(0.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherecatch05-2"));
        CutsceneManager.Wait(3.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "demospherecatch05");

        SoundManager.PlayCustom("Level_1-7-0", "demospherecatch07");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherecatch07-1"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherecatch07-2"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherecatch07-3"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "demospherecatch07");

        SoundManager.PlayCustom("Level_1-7-0", "demospherefall04");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherefall04-1"));
        self._wheatleyMovable.UnlockPos();
        SoundManager.Play(HumanSoundEnum.FlareLaunch);
        wait 0.3;
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherefall04-2"));
        CutsceneManager.Wait(1.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "demospherefall04");

        SoundManager.PlayCustom("Level_1-7-0", "demospherethud06");
        Cutscene.ShowDialogue(icon, title, I18n.Get("Level_1-7-0-demospherethud06"));
        CutsceneManager.Wait(4.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "demospherethud06");

        SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence04");
        Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demospherefirstdoorwaysequence04"), 3.8);
        CutsceneManager.Wait(1.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        self._secretLockerActivatable.Activate();
        SoundManager.Play(HumanSoundEnum.Checkpoint);
        SoundManager.Play(HumanSoundEnum.ReelIn);
        CutsceneManager.Wait(2.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        CutsceneManager.Wait(3.0);
        while (!self._wheatleyMovable.IsLocked())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            elif (CutsceneManager.IsTimerDone())
            {
                Cutscene.HideDialogue();
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence01");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence04");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence05");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence06");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence07");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence08");

                index = Random.RandomInt(1, 6);

                if (index == 1)
                {
                    addTime = 3.7;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence01");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demospherefirstdoorwaysequence01"), addTime);
                }
                elif (index == 2)
                {
                    addTime = 1.9;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence05");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demospherefirstdoorwaysequence05"), addTime);
                }
                elif (index == 3)
                {
                    addTime = 2.0;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence06");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demospherefirstdoorwaysequence06"), addTime);
                }
                elif (index == 4)
                {
                    addTime = 5.0;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence07");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demospherefirstdoorwaysequence07"), addTime);
                }
                else
                {
                    addTime = 5.6;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence08");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demospherefirstdoorwaysequence08"), 6.6);
                }
                CutsceneManager.Wait(3.0 + addTime);
            }
        }

        Cutscene.HideDialogue();
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence01");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence04");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence05");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence06");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence07");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence08");

        SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence10");
        Cutscene.ShowDialogueForTime(icon, title, I18n.Get("Level_1-7-0-demospherefirstdoorwaysequence10"), 3.7);
        CutsceneManager.Wait(3.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence10");

        CutsceneManager.Wait(3.0);
        br = false;
        while (!br)
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }

            toWheatley = self._wheatley.Position - Camera.Position;
            cameraForward = Camera.Forward.Normalized;

            angle = Vector3.Angle(Camera.Forward, toWheatley.Normalized);
            if (angle > Main.FOV)
            {
                br = true;
            }
            elif (CutsceneManager.IsTimerDone())
            {
                Cutscene.HideDialogue();
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence10");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence11");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence02");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence09");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence13");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence16");
                SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence20");

                index = Random.RandomInt(1, 7);

                if (index == 1)
                {
                    addTime = 3.2;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence11");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("demospherefirstdoorwaysequence11"), addTime);
                }
                elif (index == 2)
                {
                    addTime = 2.6;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence02");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("demospherefirstdoorwaysequence02"), addTime);
                }
                elif (index == 3)
                {
                    addTime = 3.7;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence09");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("demospherefirstdoorwaysequence09"), addTime);
                }
                elif (index == 4)
                {
                    addTime = 4.5;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence13");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("demospherefirstdoorwaysequence13"), addTime);
                }
                elif (index == 5)
                {
                    addTime = 3.6;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence16");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("demospherefirstdoorwaysequence16"), addTime);
                }
                else
                {
                    addTime = 8.1;
                    SoundManager.PlayCustom("Level_1-7-0", "demospherefirstdoorwaysequence20");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("demospherefirstdoorwaysequence20"), 6.6);
                }

                CutsceneManager.Wait(3.0 + addTime);
                while (!CutsceneManager.IsTimerDone())
                {
                    if (CutsceneManager.SkipSent())
                    {
                        self.Skip();
                        return;
                    }
                    # wait Time.TickTime;
                }
            }
        }
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence10");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence11");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence02");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence09");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence13");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence16");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence20");

        SoundManager.PlayCustom("Level_1-7-0", "turnaroundnow01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("turnaroundnow01"));
        CutsceneManager.Wait(1.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "turnaroundnow01");

        self._secretPanelActivatable.Activate();
        SoundManager.Play(HumanSoundEnum.Checkpoint);
        SoundManager.Play(HumanSoundEnum.ReelIn);

        SoundManager.PlayCustom("Level_1-7-0", "secretpanelopens07");
        Cutscene.ShowDialogue(icon, title, I18n.Get("secretpanelopens07"));
        CutsceneManager.Wait(4.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "secretpanelopens07");

        self._secretLockerActivatable.Deactivate();
        SoundManager.Play(HumanSoundEnum.FlareLaunch);
        Cutscene.HideDialogue();

        SoundManager.PlayCustom("Level_1-7-0", "callingoutinitial14");
        Cutscene.ShowDialogue(icon, title, I18n.Get("callingoutinitial14"));
        CutsceneManager.Wait(1.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "callingoutinitial14");
        Cutscene.HideDialogue();

        br = false;
        CutsceneManager.Wait(3.0);
        while (!br)
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }

            if (PlayerProxy.GetCarrying() == self._wheatleyMovable)
            {
                Cutscene.HideDialogue();
                SoundManager.StopCustom("Level_1-7-0", "callingoutinitial14");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall02");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall03");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall05");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall08");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall09");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall15");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall16");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall17");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall19");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall20");

                SoundManager.PlayCustom("Level_1-7-0", "raildroppickup02");
                Cutscene.ShowDialogue(icon, title, I18n.Get("raildroppickup02"));
                CutsceneManager.Wait(1.0);
                while (!CutsceneManager.IsTimerDone())
                {
                    if (CutsceneManager.SkipSent())
                    {
                        self.Skip();
                        return;
                    }
                    # wait Time.TickTime;
                }
                br = true;
            }
            elif (CutsceneManager.IsTimerDone())
            {
                Cutscene.HideDialogue();
                SoundManager.StopCustom("Level_1-7-0", "callingoutinitial14");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall02");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall03");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall05");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall08");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall09");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall15");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall16");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall17");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall19");
                SoundManager.StopCustom("Level_1-7-0", "raildroppostfall20");

                index = Random.RandomInt(1, 11);
                if (index == 1)
                {
                    addTime = 4.2;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall02");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall02"), addTime);
                }
                elif (index == 2)
                {
                    addTime = 3.0;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall03");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall03"), addTime);
                }
                elif (index == 3)
                {
                    addTime = 3.0;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall05");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall05"), addTime);
                }
                elif (index == 4)
                {
                    addTime = 4.5;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall08");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall08"), addTime);
                }
                elif (index == 5)
                {
                    addTime = 4.0;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall09");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall09"), addTime);
                }
                elif (index == 6)
                {
                    addTime = 6.5;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall15");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall15"), addTime);
                }
                elif (index == 7)
                {
                    addTime = 3.5;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall16");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall16"), addTime);
                }
                elif (index == 8)
                {
                    addTime = 3.7;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall17");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall17"), addTime);
                }
                elif (index == 9)
                {
                    addTime = 6.3;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall19");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall19"), addTime);
                }
                else
                {
                    addTime = 12.5;
                    subAddTime = addTime - 6.6;
                    SoundManager.PlayCustom("Level_1-7-0", "raildroppostfall20");
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall20_1"), 6.6);
                    CutsceneManager.Wait(6.6);
                    while (!CutsceneManager.IsTimerDone())
                    {
                    }
                    addTime = addTime - subAddTime;
                    Cutscene.ShowDialogueForTime(icon, title, I18n.Get("raildroppostfall20_2"), addTime);
                }
                CutsceneManager.Wait(3.0 + addTime);
            }
        }

        CutsceneManager.OnCutsceneComplete(self._name);
        CutsceneManager.SetCanPlay("Cutscene_Level_1_7_2", true);
    }

    function Skip()
    {
        CutsceneManager.SetCanPlay("Cutscene_Level_1_7_2", true);
        SoundManager.StopCustom("Level_1-7-0", "raildropintro01");
        SoundManager.StopCustom("Level_1-7-0", "demospherecatch02");
        SoundManager.StopCustom("Level_1-7-0", "demospherecatch05");
        SoundManager.StopCustom("Level_1-7-0", "demospherecatch07");
        SoundManager.StopCustom("Level_1-7-0", "demospherefall04");
        SoundManager.StopCustom("Level_1-7-0", "demospherethud06");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence01");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence04");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence05");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence06");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence07");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence08");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence04");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence10");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence11");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence02");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence09");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence13");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence16");
        SoundManager.StopCustom("Level_1-7-0", "demospherefirstdoorwaysequence20");
        SoundManager.StopCustom("Level_1-7-0", "secretpanelopens07");
        SoundManager.StopCustom("Level_1-7-0", "callingoutinitial14");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall02");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall03");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall05");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall08");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall09");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall15");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall16");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall17");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall19");
        SoundManager.StopCustom("Level_1-7-0", "raildroppostfall20");
        SoundManager.StopCustom("Level_1-7-0", "raildroppickup02");
        self._secretLockerActivatable.Deactivate();
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_7_2
{
    _name = "Cutscene_Level_1_7_2";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan10;
        title = "Wheatley";

        SoundManager.PlayCustom("Level_1-7-0", "gloriousfreedom03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("gloriousfreedom03_1"));
        CutsceneManager.Wait(5.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }


        Cutscene.ShowDialogue(icon, title, I18n.Get("gloriousfreedom03_2"));
        CutsceneManager.Wait(4.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("gloriousfreedom03_3"));
        CutsceneManager.Wait(2.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "gloriousfreedom03");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-7-0", "gloriousfreedom03");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_7_3
{
    _name = "Cutscene_Level_1_7_3";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan10;
        title = "Wheatley";

        SoundManager.PlayCustom("Level_1-7-0", "gladosgantry20");
        Cutscene.ShowDialogue(icon, title, I18n.Get("gladosgantry20"));
        CutsceneManager.Wait(3.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "gladosgantry20");


        SoundManager.PlayCustom("Level_1-7-0", "gladosgantry21");
        Cutscene.ShowDialogue(icon, title, I18n.Get("gladosgantry21"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "gladosgantry21");

        SoundManager.PlayCustom("Level_1-7-0", "gladosgantry22");
        Cutscene.ShowDialogue(icon, title, I18n.Get("gladosgantry22"));
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-7-0", "gladosgantry22");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-7-0", "gladosgantry20");
        SoundManager.StopCustom("Level_1-7-0", "gladosgantry21");
        SoundManager.StopCustom("Level_1-7-0", "gladosgantry22");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_8_1
{
    _name = "Cutscene_Level_1_8_1";
    # @type Activatable
    _activatable = null;
    _wheatley = null;
    _wheatleyMovable = null;
    _tpZoneActivatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
        wheatleyComp = Map.FindMapObjectByName("WheatleyRef 1-7-0").GetComponent("WheatleyRef");
        self._wheatley = wheatleyComp._ref;
        self._wheatleyMovable = self._wheatley.GetComponent("Movable");
        self._tpZoneActivatable = Map.FindMapObjectByName("Level 1-8-0 END").GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();
        self._activatable.Activate();

        Game.SetPlaylist("Battle");
        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_1-8-0", "wakeup_powerup02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("wakeup_powerup02"));
        CutsceneManager.Wait(1.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "wakeup_powerup02");

        icon = ProfileIconEnum.Titan10;
        title = "Wheatley";

        SoundManager.PlayCustom("Level_1-8-0", "sp_a1_wakeup_hacking11");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a1_wakeup_hacking11"));
        CutsceneManager.Wait(5.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "sp_a1_wakeup_hacking11");

        SoundManager.PlayCustom("Level_1-8-0", "fgb_hello01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("fgb_hello01"));
        CutsceneManager.Wait(0.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "fgb_hello01");

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_1-8-0", "chellgladoswakeup01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("chellgladoswakeup01"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "chellgladoswakeup01");

        icon = ProfileIconEnum.Titan10;
        title = "Wheatley";

        SoundManager.PlayCustom("Level_1-8-0", "sp_a1_wakeup_hacking03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a1_wakeup_hacking03"));
        CutsceneManager.Wait(1.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "sp_a1_wakeup_hacking03");


        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_1-8-0", "chellgladoswakeup04");
        Cutscene.ShowDialogue(icon, title, I18n.Get("chellgladoswakeup04_1"));
        CutsceneManager.Wait(3.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("chellgladoswakeup04_2"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "chellgladoswakeup04");

        SoundManager.PlayCustom("Level_1-8-0", "chellgladoswakeup05");
        Cutscene.ShowDialogue(icon, title, I18n.Get("chellgladoswakeup05_1"));
        CutsceneManager.Wait(3.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("chellgladoswakeup05_2"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "chellgladoswakeup05");

        icon = ProfileIconEnum.Titan10;
        title = "Wheatley";

        SoundManager.PlayCustom("Level_1-8-0", "demospherepowerup07");
        Cutscene.ShowDialogue(icon, title, I18n.Get("demospherepowerup07"));
        CutsceneManager.Wait(1.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "demospherepowerup07");

        SoundManager.PlayCustom("Level_1-8-0", "a1_wakeup_pinchergrab02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("a1_wakeup_pinchergrab02"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "a1_wakeup_pinchergrab02");

        SoundManager.PlayCustom("Level_1-8-0", "sp_a2_wheatley_ows_long03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_wheatley_ows_long03"));
        self._wheatleyMovable.Reset();
        SoundManager.Play(HumanSoundEnum.BladeNape4Var1);
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "sp_a2_wheatley_ows_long03");

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_1-8-0", "chellgladoswakeup06");
        Cutscene.ShowDialogue(icon, title, I18n.Get("chellgladoswakeup06_1"));
        CutsceneManager.Wait(5.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("chellgladoswakeup06_2"));
        CutsceneManager.Wait(6.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "chellgladoswakeup06");

        SoundManager.PlayCustom("Level_1-8-0", "wakeup_outro01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("wakeup_outro01"));
        CutsceneManager.Wait(7.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "wakeup_outro01");

        SoundManager.PlayCustom("Level_1-8-0", "wakeup_outro02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("wakeup_outro02"));
        CutsceneManager.Wait(5.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-8-0", "wakeup_outro02");
        self._tpZoneActivatable.Activate();
        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-8-0", "wakeup_powerup02");
        SoundManager.StopCustom("Level_1-8-0", "sp_a1_wakeup_hacking11");
        SoundManager.StopCustom("Level_1-8-0", "fgb_hello01");
        SoundManager.StopCustom("Level_1-8-0", "chellgladoswakeup01");
        SoundManager.StopCustom("Level_1-8-0", "sp_a1_wakeup_hacking03");
        SoundManager.StopCustom("Level_1-8-0", "chellgladoswakeup04");
        SoundManager.StopCustom("Level_1-8-0", "chellgladoswakeup05");
        SoundManager.StopCustom("Level_1-8-0", "demospherepowerup07");
        SoundManager.StopCustom("Level_1-8-0", "a1_wakeup_pinchergrab02");
        SoundManager.StopCustom("Level_1-8-0", "sp_a2_wheatley_ows_long03");
        SoundManager.StopCustom("Level_1-8-0", "chellgladoswakeup06");
        SoundManager.StopCustom("Level_1-8-0", "wakeup_outro01");
        SoundManager.StopCustom("Level_1-8-0", "wakeup_outro02");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_9_0
{
    _name = "Cutscene_Level_1_9_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_1-9-0", "sp_incinerator_01_01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_incinerator_01_01"));
        CutsceneManager.Wait(10.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_01");

        SoundManager.PlayCustom("Level_1-9-0", "sp_incinerator_01_18");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_incinerator_01_18"));
        CutsceneManager.Wait(7.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_18");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }
        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_01");
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_18");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_1_9_1
{
    _name = "Cutscene_Level_1_9_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_1-9-0", "sp_a2_intro1_found01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_intro1_found01"));
        CutsceneManager.Wait(6.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found01");

        SoundManager.PlayCustom("Level_1-9-0", "sp_incinerator_01_08");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_incinerator_01_08_1"));
        CutsceneManager.Wait(5.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_incinerator_01_08_2"));
        CutsceneManager.Wait(5.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_08");

        SoundManager.PlayCustom("Level_1-9-0", "sp_incinerator_01_09");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_incinerator_01_09_1"));
        CutsceneManager.Wait(3.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_incinerator_01_09_2"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_incinerator_01_09_3"));
        CutsceneManager.Wait(6.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_09");

        SoundManager.PlayCustom("Level_1-9-0", "sp_incinerator_01_10");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_incinerator_01_10"));
        CutsceneManager.Wait(6.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_10");

        SoundManager.PlayCustom("Level_1-9-0", "sp_a2_intro1_found05");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_intro1_found05"));
        CutsceneManager.Wait(5.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found05");

        SoundManager.PlayCustom("Level_1-9-0", "sp_a2_intro1_found06");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_intro1_found06_1"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_intro1_found06_2"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_intro1_found06_3"));
        CutsceneManager.Wait(5.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_intro1_found06_4"));
        CutsceneManager.Wait(5.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found06");

        SoundManager.PlayCustom("Level_1-9-0", "sp_a2_intro1_found07");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_intro1_found07_1"));
        CutsceneManager.Wait(6.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_intro1_found07_2"));
        CutsceneManager.Wait(5.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found07");

        SoundManager.PlayCustom("Level_1-9-0", "sp_a2_intro1_found08");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_intro1_found08"));
        CutsceneManager.Wait(6.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found08");
        self._activatable.Activate();

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found01");
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_08");
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_09");
        SoundManager.StopCustom("Level_1-9-0", "sp_incinerator_01_10");
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found05");
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found06");
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found07");
        SoundManager.StopCustom("Level_1-9-0", "sp_a2_intro1_found08");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_1_0
{
    _name = "Cutscene_Level_2_1_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Kenny2;
        title = "Jagerente";

        SoundManager.PlayCustom("Level_2-1-0", "sarcasmcore01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sarcasmcore01"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-1-0", "sarcasmcore01");

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-1-0", "sp_laser_redirect_intro_entry02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_redirect_intro_entry02"));
        CutsceneManager.Wait(7.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-1-0", "sp_laser_redirect_intro_entry02");

        SoundManager.PlayCustom("Level_2-1-0", "sp_laser_redirect_intro_entry03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_redirect_intro_entry03"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        if (self._activatable != null)
        {
            self._activatable.Activate();
            SoundManager.Play(HumanSoundEnum.Checkpoint);
        }

        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-1-0", "sp_laser_redirect_intro_entry03");

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-1-0", "sarcasmcore01");
        SoundManager.StopCustom("Level_2-1-0", "sp_laser_redirect_intro_entry02");
        SoundManager.StopCustom("Level_2-1-0", "sp_laser_redirect_intro_entry03");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_1_1
{
    _name = "Cutscene_Level_2_1_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-1-0", "sp_a2_laser_intro_ending02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_laser_intro_ending02"));
        CutsceneManager.Wait(8.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-1-0", "sp_a2_laser_intro_ending02");

        if (self._activatable != null)
        {
            self._activatable.Activate();
            SoundManager.Play(HumanSoundEnum.Checkpoint);
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-1-0", "sp_a2_laser_intro_ending02");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_2_0
{
    _name = "Cutscene_Level_2_2_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-2-0", "sp_a2_laser_stairs_intro02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_laser_stairs_intro02_1"));
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_laser_stairs_intro02_2"));
        CutsceneManager.Wait(5.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_laser_stairs_intro02_3"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-2-0", "sp_a2_laser_stairs_intro02");

        SoundManager.PlayCustom("Level_2-2-0", "sp_a2_laser_stairs_intro03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_laser_stairs_intro03"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-2-0", "sp_a2_laser_stairs_intro03");

        if (self._activatable != null)
        {
            self._activatable.Activate();
            SoundManager.Play(HumanSoundEnum.Checkpoint);
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-2-0", "sp_a2_laser_stairs_intro02");
        SoundManager.StopCustom("Level_2-2-0", "sp_a2_laser_stairs_intro03");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_2_1
{
    _name = "Cutscene_Level_2_2_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-2-0", "sp_laser_powered_lift_completion02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_powered_lift_completion02_1"));
        CutsceneManager.Wait(3.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_powered_lift_completion02_2"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_powered_lift_completion02_3"));
        CutsceneManager.Wait(5.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-2-0", "sp_laser_powered_lift_completion02");

        if (self._activatable != null)
        {
            self._activatable.Activate();
            SoundManager.Play(HumanSoundEnum.Checkpoint);
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-2-0", "sp_laser_powered_lift_completion02");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_3_0
{
    _name = "Cutscene_Level_2_3_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        SoundManager.PlayCustom("Level_2-3-0", "sp_a2_dual_lasers_intro01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_dual_lasers_intro01_1"));
        CutsceneManager.Wait(5.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_dual_lasers_intro01_2"));
        CutsceneManager.Wait(8.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-3-0", "sp_a2_dual_lasers_intro01");

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-3-0", "sp_a2_dual_lasers_intro01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_3_1
{
    _name = "Cutscene_Level_2_3_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-3-0", "sp_laser_redirect_intro_completion01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_redirect_intro_completion01"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-3-0", "sp_laser_redirect_intro_completion01");

        SoundManager.PlayCustom("Level_2-3-0", "sp_laser_redirect_intro_completion03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_redirect_intro_completion03_1"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_redirect_intro_completion03_2"));
        CutsceneManager.Wait(5.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-3-0", "sp_laser_redirect_intro_completion03");

        if (self._activatable != null)
        {
            self._activatable.Activate();
            SoundManager.Play(HumanSoundEnum.Checkpoint);
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-3-0", "sp_laser_redirect_intro_completion01");
        SoundManager.StopCustom("Level_2-3-0", "sp_laser_redirect_intro_completion03");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_4_0
{
    _name = "Cutscene_Level_2_4_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-4-0", "sp_laser_over_goo_entry01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_over_goo_entry01"));
        CutsceneManager.Wait(1.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        if (self._activatable != null)
        {
            self._activatable.Activate();
            SoundManager.Play(HumanSoundEnum.ReelIn);
        }
        CutsceneManager.Wait(0.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-4-0", "sp_laser_over_goo_entry01");

        SoundManager.PlayCustom("Level_2-4-0", "sp_a2_laser_over_goo_intro01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_laser_over_goo_intro01_1"));
        CutsceneManager.Wait(6.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_laser_over_goo_intro01_2"));
        CutsceneManager.Wait(4.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-4-0", "sp_a2_laser_over_goo_intro01");

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-4-0", "sp_laser_over_goo_entry01");
        SoundManager.StopCustom("Level_2-4-0", "sp_a2_laser_over_goo_intro01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_4_1
{
    _name = "Cutscene_Level_2_4_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-4-0", "sp_laser_over_goo_completion01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_over_goo_completion01_1"));
        CutsceneManager.Wait(3.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_laser_over_goo_completion01_2"));
        CutsceneManager.Wait(3.1);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-4-0", "sp_laser_over_goo_completion01");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-4-0", "sp_laser_over_goo_completion01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_5_0
{
    _name = "Cutscene_Level_2_5_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        if (self._activatable != null)
        {
            self._activatable.Activate();
            SoundManager.Play(HumanSoundEnum.ReelIn);
        }
        wait 1.0;

        if (self._activatable != null)
        {
            self._activatable.Deactivate();
            SoundManager.Play(HumanSoundEnum.ReelIn);
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_5_1
{
    _name = "Cutscene_Level_2_5_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-5-0", "faith_plate_intro01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("faith_plate_intro01_1"));
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("faith_plate_intro01_2"));
        CutsceneManager.Wait(6.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("faith_plate_intro01_3"));
        CutsceneManager.Wait(4.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-5-0", "faith_plate_intro01");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-5-0", "faith_plate_intro01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_6_0
{
    _name = "Cutscene_Level_2_6_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-6-0", "sp_catapult_intro_completion01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_intro_completion01"));
        CutsceneManager.Wait(4.9);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-6-0", "sp_catapult_intro_completion01");

        SoundManager.PlayCustom("Level_2-6-0", "sp_trust_fling_entry01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_trust_fling_entry01"));
        CutsceneManager.Wait(3.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-6-0", "sp_trust_fling_entry01");

        SoundManager.PlayCustom("Level_2-6-0", "sp_trust_fling_entry02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_trust_fling_entry02"));
        CutsceneManager.Wait(7.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-6-0", "sp_trust_fling_entry02");

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-6-0", "sp_catapult_intro_completion01");
        SoundManager.StopCustom("Level_2-6-0", "sp_trust_fling_entry01");
        SoundManager.StopCustom("Level_2-6-0", "sp_trust_fling_entry02");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_EasterEgg_StrangeBook
{
    _name = "Cutscene_EasterEgg_StrangeBook";
    # @type Activatable
    _activatable = null;

    coroutine Start()
    {
        Cutscene.HideDialogue();

        icon = ProfileIconEnum.Ymir1;
        title = Network.MyPlayer.Name;
        isEmployee = PlayerProxy.IsApertureScienceEmployee();
        if (!isEmployee)
        {
            SoundManager.PlayCustom("Level_2-6-0", "cavejohnson_generated_book_easter");
            Cutscene.ShowDialogue(icon, title, I18n.Get("Cutscene_EasterEgg_StrangeBook_1_1"));
            CutsceneManager.Wait(9.5);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_2-6-0", "cavejohnson_generated_book_easter");
        }
        else
        {
            SoundManager.PlayCustom("Level_2-6-0", "cavejohnson_generated_book_easter2");
            Cutscene.ShowDialogue(icon, title, I18n.Get("Cutscene_EasterEgg_StrangeBook_1_2"));
            CutsceneManager.Wait(6.0);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }

            Cutscene.ShowDialogue(icon, title, I18n.Get("Cutscene_EasterEgg_StrangeBook_1_3"));
            CutsceneManager.Wait(4.0);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }

            Cutscene.ShowDialogue(icon, title, I18n.Get("Cutscene_EasterEgg_StrangeBook_1_4"));
            CutsceneManager.Wait(7.8);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }

            Cutscene.ShowDialogue(icon, title, I18n.Get("Cutscene_EasterEgg_StrangeBook_1_5"));
            CutsceneManager.Wait(6.3);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }

            Cutscene.ShowDialogue(icon, title, I18n.Get("Cutscene_EasterEgg_StrangeBook_1_6"));
            CutsceneManager.Wait(8.5);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_2-6-0", "cavejohnson_generated_book_easter2");
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-6-0", "cavejohnson_generated_book_easter");
        SoundManager.StopCustom("Level_2-6-0", "cavejohnson_generated_book_easter2");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_7_0
{
    _name = "Cutscene_Level_2_7_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        state = CutsceneManager.GetState(self._name);
        if (state == 0)
        {
            CutsceneManager.SetState(self._name, state + 1);

            if (self._activatable != null)
            {
                self._activatable.Activate();
                SoundManager.Play(HumanSoundEnum.Checkpoint);
            }

            wait 0.5;

            if (self._activatable != null)
            {
                self._activatable.Deactivate();
            }

            CutsceneManager.SetCanPlay(self._name, true);
            CutsceneManager.OnCutsceneComplete(self._name);
        }
        elif (state == 1)
        {
            CutsceneManager.SetState(self._name, state + 1);

            while (PlayerProxy._carrying == null && !CutsceneManager.SkipSent())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            obj = PlayerProxy._carrying;
            wait 0.183;
            if (obj != null)
            {
                obj.Reset();
                SoundManager.Play(HumanSoundEnum.BladeNape4Var1);
            }

            SoundManager.PlayCustom("Level_2-7-0", "fizzlecube01");
            Cutscene.ShowDialogue(icon, title, I18n.Get("fizzlecube01"));
            CutsceneManager.Wait(5.4);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_2-7-0", "fizzlecube01");

            SoundManager.PlayCustom("Level_2-7-0", "fizzlecube03");
            Cutscene.ShowDialogue(icon, title, I18n.Get("fizzlecube03"));
            CutsceneManager.Wait(1.8);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_2-7-0", "fizzlecube03");

            if (self._activatable != null)
            {
                self._activatable.Activate();
                SoundManager.Play(HumanSoundEnum.Checkpoint);
            }

            wait 1.5;

            if (self._activatable != null)
            {
                self._activatable.Deactivate();
            }
            wait 0.5;
            CutsceneManager.SetCanPlay(self._name, true);
            CutsceneManager.OnCutsceneComplete(self._name);
        }
        elif (state == 2)
        {
            CutsceneManager.SetState(self._name, state + 1);

            while (PlayerProxy._carrying == null && !CutsceneManager.SkipSent())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            obj = PlayerProxy._carrying;
            wait 1.0;
            if (obj != null)
            {
                obj.Reset();
                SoundManager.Play(HumanSoundEnum.BladeNape4Var1);
            }

            SoundManager.PlayCustom("Level_2-7-0", "fizzlecube05");
            Cutscene.ShowDialogue(icon, title, I18n.Get("fizzlecube05"));
            CutsceneManager.Wait(3.5);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_2-7-0", "fizzlecube05");

            SoundManager.PlayCustom("Level_2-7-0", "fizzlecube06");
            Cutscene.ShowDialogue(icon, title, I18n.Get("fizzlecube06_1"));
            if (self._activatable != null)
            {
                self._activatable.Activate();
                SoundManager.Play(HumanSoundEnum.Checkpoint);
            }
            wait 1.5;
            if (self._activatable != null)
            {
                self._activatable.Deactivate();
            }
            CutsceneManager.Wait(2.3);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            Cutscene.ShowDialogue(icon, title, I18n.Get("fizzlecube06_2"));
            CutsceneManager.Wait(3.5);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_2-7-0", "fizzlecube06");

            CutsceneManager.OnCutsceneComplete(self._name);
        }
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-7-0", "fizzlecube01");
        SoundManager.StopCustom("Level_2-7-0", "fizzlecube03");
        SoundManager.StopCustom("Level_2-7-0", "fizzlecube05");
        SoundManager.StopCustom("Level_2-7-0", "fizzlecube06");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_2_7_1
{
    _name = "Cutscene_Level_2_7_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-7-0", "sp_a2_pit_flings03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_pit_flings03_1"));
        CutsceneManager.Wait(4.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_pit_flings03_2"));
        CutsceneManager.Wait(4.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_pit_flings03_3"));
        wait 1.1;
        if (self._activatable != null)
        {
            self._activatable.Deactivate();
        }
        SoundManager.StopCustom("Level_2-7-0", "sp_a2_pit_flings03");

        SoundManager.PlayCustom("Level_2-7-0", "sp_a2_pit_flings02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_pit_flings02"));
        wait 2.4;
        if (self._activatable != null)
        {
            self._activatable.Activate();
        }
        SoundManager.StopCustom("Level_2-7-0", "sp_a2_pit_flings02");
        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-7-0", "sp_a2_pit_flings03");
        SoundManager.StopCustom("Level_2-7-0", "sp_a2_pit_flings02");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

component Cutscene_Level_2_7_2
{
    _name = "Cutscene_Level_2_7_2";
    # @type Activatable
    _activatable = null;
    _timer = Timer(0.0);
    _once = false;

    function OnGameStart()
    {
        self._activatable = self.MapObject.GetComponent("Activatable");
    }

    function OnCollisionEnter(obj)
    {
        if (obj.Type != ObjectTypeEnum.MAP_OBJECT)
        {
            return;
        }

        # @type MapObject
        mapObject = obj;

        if (mapObject.Name != "WeightedCompanionCube")
        {
            return;
        }

        self._once = false;

        self._activatable.Deactivate();

        movable = mapObject.GetComponent("Movable");
        movable.Reset();
        SoundManager.Play(HumanSoundEnum.BladeNape4Var1);
        self._timer.Reset(9.5);

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-7-0", "sp_a2_pit_flings06");
        Cutscene.ShowDialogueForTime(icon, title, I18n.Get("sp_a2_pit_flings06"), 7.0);
    }

    function OnTick()
    {
        if (self._once)
        {
            return;
        }

        if (CutsceneManager.SkipSent())
        {
            self.Skip();
            return;
        }

        self._timer.UpdateOnTick();

        if (self._timer.IsDone())
        {
            self._activatable.Activate();
            self._once = true;
            CutsceneManager.OnCutsceneComplete(self._name);
        }
        else
        {
            self._activatable.Deactivate();
        }
    }

    function Skip()
    {
        self._timer.Reset(0.0);
        Cutscene.HideDialogue();
        SoundManager.StopCustom("Level_2-7-0", "sp_a2_pit_flings06");
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}


cutscene Cutscene_Level_2_8_0
{
    _name = "Cutscene_Level_2_8_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_2-8-0", "sp_a2_fizzler_intro01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_fizzler_intro01"));
        CutsceneManager.Wait(8.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-8-0", "sp_a2_fizzler_intro01");

        SoundManager.PlayCustom("Level_2-8-0", "sp_a2_fizzler_intro04");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_fizzler_intro04"));
        CutsceneManager.Wait(9.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-8-0", "sp_a2_fizzler_intro04");

        SoundManager.PlayCustom("Level_2-8-0", "sp_a2_fizzler_intro05");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_fizzler_intro05"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-8-0", "sp_a2_fizzler_intro05");

        SoundManager.PlayCustom("Level_2-8-0", "sp_a2_fizzler_intro06");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_fizzler_intro06"));
        CutsceneManager.Wait(8.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_2-8-0", "sp_a2_fizzler_intro06");


        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_2-8-0", "sp_a2_fizzler_intro01");
        SoundManager.StopCustom("Level_2-8-0", "sp_a2_fizzler_intro04");
        SoundManager.StopCustom("Level_2-8-0", "sp_a2_fizzler_intro05");
        SoundManager.StopCustom("Level_2-8-0", "sp_a2_fizzler_intro06");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_1_0
{
    _name = "Cutscene_Level_3_1_0";
    # @type Activatable
    _activatable = null;
    _ceilingActivatable = null;
    _wheatley = null;
    _launchPad = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
        self._ceilingActivatable = Map.FindMapObjectByName("Cutscene_Level_3_1_0_Ceiling").GetComponent("Activatable");
        self._wheatley = Map.FindMapObjectByName("WheatleyRef 3-1-0");
        # @type LaunchPadRef
        launchPadComp = Map.FindMapObjectByName("LaunchPadRef 3-1-0").GetComponent("LaunchPadRef");
        self._launchPad = launchPadComp._ref;
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();
        
        self.InitActivatable();

        state = CutsceneManager.GetState(self._name);
        if (state == 0)
        {
            CutsceneManager.SetState(self._name, state + 1);
            self._launchPad.Initialize();

            if (self._activatable != null)
            {
                self._activatable.Deactivate();
            }

            icon = ProfileIconEnum.Titan10;
            title = "Wheatley";

            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek01");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek01"));
            CutsceneManager.Wait(1.0);
            while(!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                Camera.LookAt(self._wheatley.Position);
            }
            
            CutsceneManager.Wait(1.0);
            while(!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek01");

            icon = ProfileIconEnum.Titan16;
            title = "GLaDOS";

            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failureone01");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failureone01_1"));
            CutsceneManager.Wait(1.7);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failureone01_2"));
            CutsceneManager.Wait(3.0);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failureone01");
            
            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failureone02");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failureone02"));
            CutsceneManager.Wait(2.0);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failureone02");
            
            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failureone03");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failureone03"));
            CutsceneManager.Wait(1.8);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failureone03");

            if (self._activatable != null)
            {
                SoundManager.Play(HumanSoundEnum.Checkpoint);
                self._activatable.Activate();
            }

            CutsceneManager.SetCanPlay(self._name, true);
            CutsceneManager.OnCutsceneComplete(self._name);
        }
        elif (state == 1)
        {
            CutsceneManager.SetState(self._name, state + 1);

            if (self._activatable != null)
            {
                self._activatable.Deactivate();
            }

            icon = ProfileIconEnum.Titan10;
            title = "Wheatley";

            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek02");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek02"));
            CutsceneManager.Wait(1.0);
            while(!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                Camera.LookAt(self._wheatley.Position);
            }

            CutsceneManager.Wait(3.0);
            while(!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek02");

            icon = ProfileIconEnum.Titan16;
            title = "GLaDOS";

            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failuretwo01");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failuretwo01_1"));
            CutsceneManager.Wait(6.2);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failuretwo01_2"));
            CutsceneManager.Wait(3.3);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failuretwo01");
            
            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failuretwo02");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failuretwo02"));
            CutsceneManager.Wait(2.8);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failuretwo02");

            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failuretwo03");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failuretwo03"));
            CutsceneManager.Wait(1.0);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failuretwo03");
            if (self._activatable != null)
            {
                SoundManager.Play(HumanSoundEnum.Checkpoint);
                self._activatable.Activate();
            }

            CutsceneManager.SetCanPlay(self._name, true);
            CutsceneManager.OnCutsceneComplete(self._name);
        }
        elif (state == 2)
        {
            CutsceneManager.SetState(self._name, state + 1);

            if (self._activatable != null)
            {
                self._activatable.Deactivate();
            }

            icon = ProfileIconEnum.Titan10;
            title = "Wheatley";

            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek03");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek03"));
            CutsceneManager.Wait(1.0);
            while(!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                Camera.LookAt(self._wheatley.Position);
            }

            CutsceneManager.Wait(2.1);
            while(!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek03");

            icon = ProfileIconEnum.Titan16;
            title = "GLaDOS";

            SoundManager.PlayCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failurethree01");
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failurethree01_1"));
            CutsceneManager.Wait(4.2);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            
            Cutscene.ShowDialogue(icon, title, I18n.Get("sp_catapult_fling_sphere_peek_failurethree01_2"));
            self._ceilingActivatable.Activate();
            CutsceneManager.Wait(2.0);
            while (!CutsceneManager.IsTimerDone())
            {
                if (CutsceneManager.SkipSent())
                {
                    self.Skip();
                    return;
                }
                # wait Time.TickTime;
            }
            SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failurethree01");

            if (self._activatable != null)
            {
                SoundManager.Play(HumanSoundEnum.Checkpoint);
                self._activatable.Activate();
            }

            CutsceneManager.OnCutsceneComplete(self._name);
        }
        else
        {
            return;
        }
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek01");
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failureone01");
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failureone02");
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failureone03");
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek02");
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failuretwo01");
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failuretwo02");
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failuretwo03");
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek03");
        SoundManager.StopCustom("Level_3-1-0", "sp_catapult_fling_sphere_peek_failurethree01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_2_0
{
    _name = "Cutscene_Level_3_2_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-2-0", "sp_a2_ricochet01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_ricochet01_1"));
        CutsceneManager.Wait(5.6);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_ricochet01_2"));
        CutsceneManager.Wait(8.4);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_ricochet01_3"));
        CutsceneManager.Wait(3.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-2-0", "sp_a2_ricochet01");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-2-0", "sp_a2_ricochet01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_2_1
{
    _name = "Cutscene_Level_3_2_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-2-0", "glados_generated_deers");
        Cutscene.ShowDialogue(icon, title, I18n.Get("glados_generated_deers_1"));
        CutsceneManager.Wait(5.9);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("glados_generated_deers_2"));
        CutsceneManager.Wait(3.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-2-0", "glados_generated_deers");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-2-0", "glados_generated_deers");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_3_0
{
    _name = "Cutscene_Level_3_3_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-3-0", "sp_a2_bridge_intro01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_intro01_1"));
        CutsceneManager.Wait(4.9);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_intro01_2"));
        CutsceneManager.Wait(6.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_intro01_3"));
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-3-0", "sp_a2_bridge_intro01");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-3-0", "sp_a2_bridge_intro01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_3_1
{
    _name = "Cutscene_Level_3_3_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-3-0", "sp_a2_bridge_intro03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_intro03_1"));
        CutsceneManager.Wait(4.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_intro03_2"));
        CutsceneManager.Wait(4.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_intro03_3"));
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-3-0", "sp_a2_bridge_intro03");

        SoundManager.PlayCustom("Level_3-3-0", "sp_a2_bridge_intro04");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_intro04"));
        CutsceneManager.Wait(7.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-3-0", "sp_a2_bridge_intro04");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-3-0", "sp_a2_bridge_intro03");
        SoundManager.StopCustom("Level_3-3-0", "sp_a2_bridge_intro04");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_4_0
{
    _name = "Cutscene_Level_3_4_0";
    # @type Activatable
    _activatable = null;

    # @type WheatleyRef
    _wheatley = null;
    # @type Controllable
    _bird = null;

    # @type Dict<int,MapObject>
    _wPos = Dict();
    # @type Dict<int,MapObject>
    _bPos = Dict();

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
        self._wheatley = Map.FindMapObjectByName("WheatleyRef 3-4-0").GetComponent("WheatleyRef");
        self._wPos.Clear();
        self._wPos.Set(0, Map.FindMapObjectByName("WheatleyPosRef 3-4-0 0"));
        self._wPos.Set(1, Map.FindMapObjectByName("WheatleyPosRef 3-4-0 1"));
        self._wPos.Set(2, Map.FindMapObjectByName("WheatleyPosRef 3-4-0 2"));
        self._wPos.Set(3, Map.FindMapObjectByName("WheatleyPosRef 3-4-0 3"));
        self._wPos.Set(4, Map.FindMapObjectByName("WheatleyPosRef 3-4-0 4"));
        self._wPos.Set(5, Map.FindMapObjectByName("WheatleyPosRef 3-4-0 5"));

        self._bird = Map.FindMapObjectByName("Bird 3-4-0").GetComponent("Controllable");
        self._bPos.Clear();
        self._bPos.Set(1, Map.FindMapObjectByName("BirdPos 3-4-0 1"));
        self._bPos.Set(2, Map.FindMapObjectByName("BirdPos 3-4-0 2"));
        self._bPos.Set(3, Map.FindMapObjectByName("BirdPos 3-4-0 3"));
        self._bPos.Set(4, Map.FindMapObjectByName("BirdPos 3-4-0 4"));
        self._bPos.Set(5, Map.FindMapObjectByName("BirdPos 3-4-0 5"));
        self._bPos.Set(6, Map.FindMapObjectByName("BirdPos 3-4-0 6"));
        self._bPos.Set(7, Map.FindMapObjectByName("BirdPos 3-4-0 7"));
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        self._wheatley.MoveTo(self._wPos.Get(0).Position, 0.1);

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-4-0", "sp_a2_bridge_the_gap02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_the_gap02_1"));
        CutsceneManager.Wait(2.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_the_gap02_2"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_the_gap02_3"));
        CutsceneManager.Wait(3.1);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_the_gap02_4"));
        CutsceneManager.Wait(3.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-4-0", "sp_a2_bridge_the_gap02");

        icon = ProfileIconEnum.Titan10;
        title = "Wheatley";

        self._wheatley.MoveTo(self._wPos.Get(1).Position, 0.25);
        wait 0.25;
        self._wheatley.MoveTo(self._wPos.Get(2).Position, 0.5);
        SoundManager.PlayCustom("Level_3-4-0", "sp_trust_fling01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_trust_fling01"));
        wait 0.5;
        self._wheatley.MoveTo(self._wPos.Get(3).Position, 0.25);
        wait 0.25;
        CutsceneManager.Wait(1.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-4-0", "sp_trust_fling01");

        SoundManager.PlayCustom("Level_3-4-0", "sp_trust_flingalt07");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_trust_flingalt07"));
        CutsceneManager.Wait(4.533);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        self._bird.StartRotating(120.0);
        self._bird.MoveTo(self._bPos.Get(4).Position, 0.25);
        wait 0.3;
        SoundManager.StopCustom("Level_3-4-0", "sp_trust_flingalt07");

        SoundManager.PlayCustom("Level_3-4-0", "sp_trust_flingalt02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_trust_flingalt02"));
        self._wheatley.MoveTo(self._wPos.Get(2).Position, 0.25);
        self._bird.MoveTo(self._bPos.Get(1).Position, 0.4);
        wait 0.25;
        self._wheatley.MoveTo(self._wPos.Get(1).Position, 1.0);
        self._bird.MoveTo(self._bPos.Get(2).Position, 0.5);
        wait 0.25;
        self._wheatley.MoveTo(self._wPos.Get(2).Position, 0.25);
        self._bird.MoveTo(self._bPos.Get(5).Position, 0.25);
        wait 0.25;
        self._wheatley.MoveTo(self._wPos.Get(3).Position, 0.5);
        self._bird.MoveTo(self._bPos.Get(3).Position, 0.6);
        wait 0.5;
        self._wheatley.MoveTo(self._wPos.Get(4).Position, 1.0);
        self._bird.MoveTo(self._bPos.Get(6).Position, 1.25);
        wait 1.0;
        Cutscene.HideDialogue();
        self._wheatley.MoveTo(self._wPos.Get(5).Position, 0.5);
        self._bird.MoveTo(self._bPos.Get(7).Position, 0.25);
        wait 0.5;
        SoundManager.StopCustom("Level_3-4-0", "sp_trust_flingalt02");

        CutsceneManager.Wait(1.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        self._wheatley.MoveTo(self._wPos.Get(4).Position, 0.25);
        wait 0.25;

        SoundManager.PlayCustom("Level_3-4-0", "sp_trust_flingalt08");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_trust_flingalt08"));
        self._wheatley.MoveTo(self._wPos.Get(2).Position, 1.5);
        wait 1.5;
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-4-0", "sp_trust_flingalt08");
        
        SoundManager.PlayCustom("Level_3-4-0", "sp_a2_bridge_the_gap_expo01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_the_gap_expo01"));
        CutsceneManager.Wait(3.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-4-0", "sp_a2_bridge_the_gap_expo01");

        SoundManager.PlayCustom("Level_3-4-0", "sp_a2_bridge_the_gap_expo03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_the_gap_expo03"));
        CutsceneManager.Wait(3.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-4-0", "sp_a2_bridge_the_gap_expo03");

        SoundManager.PlayCustom("Level_3-4-0", "sp_a2_bridge_the_gap_expo06");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_bridge_the_gap_expo06"));
        CutsceneManager.Wait(4.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-4-0", "sp_a2_bridge_the_gap_expo06");

        self._wheatley.MoveTo(self._wPos.Get(1).Position, 0.5);
        wait 0.5;
        self._wheatley.MoveTo(self._wPos.Get(0).Position, 0.25);
        wait 0.25;

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-4-0", "sp_sphere_2nd_encounter_entrytwo01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_sphere_2nd_encounter_entrytwo01"));
        CutsceneManager.Wait(8.6);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-4-0", "sp_sphere_2nd_encounter_entrytwo01");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }
        
        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        self._bird.StopRotating();
        self._bird.Reset();
        self._wheatley._controllable.Reset();
        SoundManager.StopCustom("Level_3-4-0", "sp_a2_bridge_the_gap02");
        SoundManager.StopCustom("Level_3-4-0", "sp_trust_fling01");
        SoundManager.StopCustom("Level_3-4-0", "sp_trust_flingalt07");
        SoundManager.StopCustom("Level_3-4-0", "sp_trust_flingalt02");
        SoundManager.StopCustom("Level_3-4-0", "sp_trust_flingalt08");
        SoundManager.StopCustom("Level_3-4-0", "sp_a2_bridge_the_gap_expo01");
        SoundManager.StopCustom("Level_3-4-0", "sp_a2_bridge_the_gap_expo03");
        SoundManager.StopCustom("Level_3-4-0", "sp_a2_bridge_the_gap_expo06");
        SoundManager.StopCustom("Level_3-4-0", "sp_sphere_2nd_encounter_entrytwo01");

        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }

    # @param t float
    # @return bool
    function _Wait(t)
    {
        CutsceneManager.Wait(4.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return true;
            }
            # wait Time.TickTime;
        }

        return false;
    }
}

cutscene Cutscene_Level_3_4_1
{
    _name = "Cutscene_Level_3_4_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-4-0", "testchambermisc19");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc19_1"));
        CutsceneManager.Wait(7.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return true;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc19_2"));
        CutsceneManager.Wait(3.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return true;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc19_3"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return true;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc19_4"));
        CutsceneManager.Wait(1.1);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return true;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_3-4-0", "testchambermisc19");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }
        
        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-4-0", "testchambermisc19");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_5_0
{
    _name = "Cutscene_Level_3_5_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-5-0", "turret_intro01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("turret_intro01_1"));
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("turret_intro01_2"));
        CutsceneManager.Wait(6.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("turret_intro01_3"));
        CutsceneManager.Wait(1.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-5-0", "turret_intro01");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-5-0", "turret_intro01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_6_0
{
    _name = "Cutscene_Level_3_6_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-6-0", "testchambermisc21");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc21_1"));
        CutsceneManager.Wait(4.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc21_2"));
        CutsceneManager.Wait(6.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc21_3"));
        CutsceneManager.Wait(5.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-6-0", "testchambermisc21");

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-6-0", "testchambermisc21");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_6_1
{
    _name = "Cutscene_Level_3_6_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-6-0", "testchambermisc23");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc23_1"));
        CutsceneManager.Wait(4.9);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc23_2"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc23_3"));
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc23_4"));
        CutsceneManager.Wait(4.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc23_5"));
        CutsceneManager.Wait(2.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-6-0", "testchambermisc23");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }
        
        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-6-0", "testchambermisc23");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_7_0
{
    _name = "Cutscene_Level_3_7_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-7-0", "sp_a2_turret_intro01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_turret_intro01_1"));
        CutsceneManager.Wait(3.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_turret_intro01_2"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_turret_intro01_3"));
        CutsceneManager.Wait(6.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-7-0", "sp_a2_turret_intro01");

        SoundManager.PlayCustom("Level_3-7-0", "sp_a2_turret_intro03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_turret_intro03_1"));
        CutsceneManager.Wait(4.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_turret_intro03_2"));
        CutsceneManager.Wait(3.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_turret_intro03_3"));
        CutsceneManager.Wait(2.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_turret_intro03_4"));
        CutsceneManager.Wait(3.1);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_turret_intro03_5"));
        CutsceneManager.Wait(1.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_turret_intro03_6"));
        CutsceneManager.Wait(1.4);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-7-0", "sp_a2_turret_intro03");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-7-0", "sp_a2_turret_intro01");
        SoundManager.StopCustom("Level_3-7-0", "sp_a2_turret_intro03");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_7_1
{
    _name = "Cutscene_Level_3_7_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-7-0", "testchambermisc30");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc30_1"));
        CutsceneManager.Wait(3.9);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc30_2"));
        CutsceneManager.Wait(2.9);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc30_3"));
        CutsceneManager.Wait(1.9);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc30_4"));
        CutsceneManager.Wait(1.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc30_5"));
        CutsceneManager.Wait(1.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-7-0", "testchambermisc30");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-7-0", "testchambermisc30");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_8_0
{
    _name = "Cutscene_Level_3_8_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-8-0", "testchambermisc31");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc31_1"));
        CutsceneManager.Wait(3.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc31_2"));
        CutsceneManager.Wait(4.7);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc31_3"));
        CutsceneManager.Wait(4.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_3-8-0", "testchambermisc31");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-8-0", "testchambermisc31");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_8_EasterEgg
{
    _name = "Cutscene_Level_3_8_EasterEgg";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        SoundManager.PlayCustom("Level_3-8-0", "sp_a2_laser_vs_turret_r1");

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_8_1
{
    _name = "Cutscene_Level_3_8_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        SoundManager.StopCustom("Level_3-8-0", "sp_a2_laser_vs_turret_r1");
        CutsceneManager.SetCanPlay("Cutscene_Level_3_8_EasterEgg", true);

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-8-0", "testchambermisc24");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc24"));
        CutsceneManager.Wait(12.9);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_3-8-0", "testchambermisc24");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-8-0", "testchambermisc24");
        SoundManager.StopCustom("Level_3-8-0", "sp_a2_laser_vs_turret_r1");
        CutsceneManager.SetCanPlay("Cutscene_Level_3_8_EasterEgg", true);
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_9_0
{
    _name = "Cutscene_Level_3_9_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-9-0", "testchambermisc39");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc39_1"));
        CutsceneManager.Wait(4.6);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc39_2"));
        CutsceneManager.Wait(2.6);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc39_3"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_3-9-0", "testchambermisc39");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-9-0", "testchambermisc39");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_3_9_1
{
    _name = "Cutscene_Level_3_9_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_3-9-0", "testchambermisc33");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc33_1"));
        CutsceneManager.Wait(3.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc33_2"));
        CutsceneManager.Wait(8.4);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_3-9-0", "testchambermisc33");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_3-9-0", "testchambermisc33");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_4_1_0
{
    _name = "Cutscene_Level_4_1_0";
    # @type Activatable
    _activatable = null;

    # @type Activatable
    _slider = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
        self._slider = Map.FindMapObjectByName("Slider 4-1-0").GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_4-1-0", "testchambermisc34");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc34"));
        CutsceneManager.Wait(4.8);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_4-1-0", "testchambermisc34");
        self._slider.Activate();
        Cutscene.HideDialogue();

        CutsceneManager.Wait(1.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.PlayCustom("Level_4-1-0", "testchambermisc35");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc35"));
        CutsceneManager.Wait(1.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_4-1-0", "testchambermisc35");

        SoundManager.PlayCustom("Level_4-1-0", "sad_party_horn_01");
        CutsceneManager.Wait(2.3);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_4-1-0", "sad_party_horn_01");

        SoundManager.PlayCustom("Level_4-1-0", "testchambermisc41");
        Cutscene.ShowDialogue(icon, title, I18n.Get("testchambermisc41"));
        CutsceneManager.Wait(2.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_4-1-0", "testchambermisc41");

        SoundManager.PlayCustom("Level_4-1-0", "sp_a2_column_blocker01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_column_blocker01"));
        CutsceneManager.Wait(8.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_4-1-0", "sp_a2_column_blocker01");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_4-1-0", "testchambermisc34");
        SoundManager.StopCustom("Level_4-1-0", "testchambermisc35");
        SoundManager.StopCustom("Level_4-1-0", "testchambermisc41");
        SoundManager.StopCustom("Level_4-1-0", "sad_party_horn_01");
        SoundManager.StopCustom("Level_4-1-0", "sp_a2_column_blocker01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_4_1_1
{
    _name = "Cutscene_Level_4_1_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_4-1-0", "sp_a2_column_blocker03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_column_blocker03_1"));
        CutsceneManager.Wait(6.4);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_column_blocker03_2"));
        CutsceneManager.Wait(3.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_column_blocker03_3"));
        CutsceneManager.Wait(5.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_4-1-0", "sp_a2_column_blocker03");

        SoundManager.PlayCustom("Level_4-1-0", "sp_a2_column_blocker04");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_column_blocker04"));
        CutsceneManager.Wait(5.0);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_4-1-0", "sp_a2_column_blocker04");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_4-1-0", "sp_a2_column_blocker03");
        SoundManager.StopCustom("Level_4-1-0", "sp_a2_column_blocker04");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_4_2_0
{
    _name = "Cutscene_Level_4_2_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_4-2-0", "sp_a2_column_blocker05");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_column_blocker05"));
        CutsceneManager.Wait(12.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_4-2-0", "sp_a2_column_blocker05");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_4-2-0", "sp_a2_column_blocker05");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_4_2_1
{
    _name = "Cutscene_Level_4_2_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_4-2-0", "sp_a2_dilemma01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("sp_a2_dilemma01"));
        CutsceneManager.Wait(6.5);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_4-2-0", "sp_a2_dilemma01");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_4-2-0", "sp_a2_dilemma01");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_4_3_0
{
    _name = "Cutscene_Level_4_3_0";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_4-3-0", "a2_triple_laser01");
        Cutscene.ShowDialogue(icon, title, I18n.Get("a2_triple_laser01"));
        CutsceneManager.Wait(8.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }
        SoundManager.StopCustom("Level_4-3-0", "a2_triple_laser01");

        SoundManager.PlayCustom("Level_4-3-0", "a2_triple_laser02");
        Cutscene.ShowDialogue(icon, title, I18n.Get("a2_triple_laser02"));
        CutsceneManager.Wait(4.1);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_4-3-0", "a2_triple_laser02");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_4-3-0", "a2_triple_laser01");
        SoundManager.StopCustom("Level_4-3-0", "a2_triple_laser02");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}

cutscene Cutscene_Level_4_3_1
{
    _name = "Cutscene_Level_4_3_1";
    # @type Activatable
    _activatable = null;

    function InitActivatable()
    {
        if (self._activatable != null)
        {
            return;
        }

        obj = Map.FindMapObjectByName(self._name);
        self._activatable = obj.GetComponent("Activatable");
    }

    coroutine Start()
    {
        Cutscene.HideDialogue();

        self.InitActivatable();

        icon = ProfileIconEnum.Titan16;
        title = "GLaDOS";

        SoundManager.PlayCustom("Level_4-3-0", "a2_triple_laser03");
        Cutscene.ShowDialogue(icon, title, I18n.Get("a2_triple_laser03_1"));
        CutsceneManager.Wait(5.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        Cutscene.ShowDialogue(icon, title, I18n.Get("a2_triple_laser03_2"));
        CutsceneManager.Wait(6.2);
        while (!CutsceneManager.IsTimerDone())
        {
            if (CutsceneManager.SkipSent())
            {
                self.Skip();
                return;
            }
            # wait Time.TickTime;
        }

        SoundManager.StopCustom("Level_4-3-0", "a2_triple_laser03");

        if (self._activatable != null)
        {
            self._activatable.Activate();
        }

        CutsceneManager.OnCutsceneComplete(self._name);
    }

    function Skip()
    {
        SoundManager.StopCustom("Level_4-3-0", "a2_triple_laser03");
        CutsceneManager.Wait(0.0);
        Cutscene.HideDialogue();
        CutsceneManager.OnCutsceneComplete(self._name);
    }
}
