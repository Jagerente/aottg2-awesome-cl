# Realism

## How to integrate

1. Take existing game mode as base.  (You can find base logic here - https://github.com/AoTTG-2/Aottg2-Unity/tree/181a12d8a64420cd061740e5c46de6b58825e273/Assets/Resources/Data/Modes),
2. In the `realism.cl` copy everything except the entire `class Main{/**/}` block and paste it at the very bottom of your base logic.,
3. Inside your existing `class Main{/**/}` (aka base logic), add `RealismDeathVelocity = 100.0;` at the very top. (in the same way as inside `realism.cl`)
4. For each method in `class Main{/**/}` of `realism.cl` insert the corresponding code at the start of the matching method in your base logic. If the base logic doesn't have any of these methods, just paste the entire method from `realism.cl`.
