extension TitanManager
{
	_spawnFxSize = 5.0;
	_boomFxOffset = Vector3.Up * 100.0;
	_boomFxRotation = Vector3(0.0, 20.0, 0.0);
	_boomFxSize = 4.0;

	# @param type string
	# @param pos Vector3
	function Spawn(type, pos)
	{
		fxPos = pos;

		Game.SpawnTitanAt(type, pos);
		for (i in Range(1, 4, 1))
		{
			Game.SpawnEffect("ShifterThunder", fxPos, Vector3.Zero, i * 1.5);
		}
		Game.SpawnEffect("TitanSpawnEffect", fxPos, Vector3.Zero, self._spawnFxSize);
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

	function IdleAll(t)
	{
		for (titan in Game.AITitans)
		{
			titan.Idle(t);
		}
	}
}
