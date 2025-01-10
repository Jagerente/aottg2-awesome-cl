## Components

## Core

#### Portal

This component is required for both portals to enable teleportation of your character and objects with the Movable component.
Do not use it.

#### PortalSurfacable

This component designates objects as valid surfaces for portal placement.
It contains no logic and functions solely as a tag to identify objects that can interact with the portal system.

Attach it to objects where portal placement should be allowed.

#### TargetPassThrough

This component allows specific types of rays to pass through the object. When a ray encounters an object with this component, it continues through the object without being blocked.

The component serves as a tag for identifying objects that should not obstruct ray casting and contains no additional logic.

#### LaserSource

This component is attached to a LaserSource object and emits a laser beam that can damage the player and activate a LaserReceiver.

It is not intended for direct use. Instead, use the LaserSourceRef object with the attached LaserSourceRef component, which serves as a proxy.

#### LaserReceiver

This component is attached to a LaserReceiver object and is required to be activated by a LaserSource.

It is not intended for direct use. Instead, use the LaserReceiverRef object with the attached LaserReceiverRef component, which serves as a proxy.

#### LaunchPad

This component launches objects in a specified direction with a configurable force.

It is not intended for direct use. Instead, use the LaunchPadRef object with the attached LaunchPadRef component, which serves as a proxy.

LockMovementFor MUST be equal to or greater than the flight duration, to prevent custom physics forces apply to the player during flight.

#### HardLightBridgeSource

This component is attached to a HardLightBridgeSource object and emits light bridge.

It is not intended for direct use. Instead, use the HardLightBridgeSourceRef object with the attached HardLightBridgeRef component, which serves as a proxy.

#### Turret

This component is attached to a Turret object and contains all Turret-related AI.

It is not intended for direct use. Instead, use the TurretRef object with the attached TurretRef component, which serves as a proxy.

Set static to True if you need non-functional map object.

#### TurretFOV

This component is attached to the Turret_FOV object, which is linked to a turret and serves as a  players detection region.
It is not intended for direct use.

#### WireMonitor

This component is attached to WireMonitor object and controls its visual state based on provided activatable.

It is not intended for direct use. Instead, use the WireMonitorRef object with the attached WireMonitorRef component, which serves as a proxy.

#### Wire

This component is attached to Wire objects and dynamically controls their color based on the status of the associated ActivatableID.

For better performance, apply ActiveControl to wires to enable culling.

#### PortalGunModifier

This component configures the player's PortalGun state upon collision.

It should be placed at the beginning of each level to ensure proper PortalGun functionality.

#### LevelReset

This component manages resets all registered objects within the specified group.

It should be placed at the beginning of each level.

#### EmancipationGrill

This component fizzles all objects that come into contact with it, resets the player's active portals, and prevents the player from placing portals while within its collision area.

For better performance, apply ActiveControl to the same object to enable culling.

#### CubeDispencer

The CubeDispencer component is used to dispense specific types of cubes in the game. It can be controlled via an Activatable component and supports reverse activation behavior.

It is not intended for direct use. Instead, use the CubeDispencerRef object with the attached WireMonitorRef component, which serves as a proxy.

#### Radio

Just a radio.

#### WheatleyPositionLocker

This component is required for some cutscenes.

### Refs

#### ObjectRef & LampRef

Just creates a copy of referenced object with culling attached.
LampRef also has child object with PointLight.

#### PortalReference

Creates a portal on the object it is attached to. It can optionally create a portal that is independent of the player's portals if Separate is set to true and a GroupID is provided.

### Buttons

#### Activatable

This component is a core component used in many other components. It acts as a simple activation state manager, allowing to be either activated or deactivated.

ResetGroup: Allows resetting the Active state to its initial value. For example, if Active is initially set to true, and later changed to false, resetting it will return Active to true.

#### Button

The Button component provides interactive functionality, enabling activation and deactivation behavior with optional grouping, timing, and cooldown settings.

Character interaction relies on this component. If an object has it, players can activate it by pressing the interact hotkey.

For infinite activation time (ActiveTime <= 0), the active state will not reset automatically. To deactivate the button, you must handle it manually, such as setting a Reset Group in an Activatable component linked to the button and resetting it when needed.

#### WeightedButton

#### RegionButton

#### MultiButton

### Other

#### CheckpointRegion

#### SmartTeleport

#### SpeedRunCheck

#### Slider

#### Elevator

#### Follower

#### Movable

#### Controllable

#### EasterEgg

#### TileAnimator

#### ObjLogger
