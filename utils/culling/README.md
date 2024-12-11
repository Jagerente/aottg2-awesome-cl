# Culling

Culling is a commonly used optimization technique that involves dynamically enabling or disabling objects based on their necessity at any given time. I've implemented a set of components to handle object culling easily.

## Overview

### Activatable
A base component for managing state.
It does not directly enable or disable objects. Instead, it provides a standardized interface for managing state changes.
- Attach this component to the same object as the `RegionButton` component.

### RegionButton
Automatically toggles the state of an `Activatable` component when specific objects collide with the attached object.
- Attach this component to the same object as the Activatable component.

### ActiveControl
Syncs the active state of an object with a specified `Activatable` component.
- Attach this component to the object you want to enable or disable dynamically
- Set the `ActivatableID` field to the ID of the object with the `Activatable` component.

## How to use these components together
1. Create a `Cube` with `Region` collision mode, disable visibility and cover with it active zone where you want player to be able see culled objects.
1. Add `RegionButton` component to that Cube. 
2. Add `Activatable` component to the same object as the `RegionButton`.
3. Add the` ActiveControl` component to objects you want to cull (enable or disable dynamically), and set the `ActivatableID` field to reference the object with the `Activatable` components.

## Where to put `ActiveControl` 
- `Light sources` your victims N1.
- `Effects` your victims N2.
- Dynamic/Complex objects made of multiple objects, anything with Rigidbody attached, objects with complex collisions, anything that is transparent or with animated textures.

You don't have to attach it to everything you see.