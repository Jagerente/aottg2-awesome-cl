extension TitanSpawner
{
    _thunderFxOffset = Vector3.Up * 120.0 + Vector3(0.0, 20.0, -15.0);
    _spawnFxOffset = Vector3.Up * 120.0 + Vector3(0.0, 20.0, -15.0);
    _spawnFxSize = 2.0;
    _boomFxOffset = Vector3.Up * 150.0;
    _boomFxRotation = Vector3(0.0, 20.0, 0.0);
    _boomFxSize = 4.0;

    # @param type string
    # @param pos Vector3
    function Spawn(type, pos)
    {
        fxPos = pos;
        fxPos.Y = -50;

        Game.SpawnTitanAt(type, pos);
        for (i in Range(1, 3, 1))
        {
            Game.SpawnEffect("ShifterThunder", fxPos + self._thunderFxOffset, Vector3.Zero, i);
        }
        Game.SpawnEffect("TitanSpawnEffect", fxPos + self._spawnFxOffset, Vector3.Zero, self._spawnFxSize);
        Game.SpawnEffect("Boom7", fxPos + self._boomFxOffset, self._boomFxRotation, self._boomFxSize);
    }

    # @param type string
    # @param pos Vector3
    # @param delay float
    coroutine SpawnAsync(type, pos, delay)
    {
        wait delay;
        self.Spawn(type, pos);
    }
}
