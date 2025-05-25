# @import timer

class TitanProxy
{
	# @type Titan
	Titan = null;

	_locking = false;
	_lockingPos = Vector3();
	_lockingTimer = Timer(0.0);

	function Init(t)
	{
		self.Titan = t;
	}

	function IdleRoar()
	{
		self.Titan.Emote("Roar");
		self.Titan.Idle(5.0);
	}

	# @param c Character
	# @param t float
	function Target(c, t)
	{
		self.Titan.Target(c, t);
		self.Titan.Emote("Roar");
	}

	# @param pos Vector3
	# @param time float
	function Lock(pos, time)
	{
		self._lockingPos = pos;
		self._lockingTimer.Reset(time);
		self._locking = true;
	}

	function OnTick()
	{
		self._UpdateLocking(Time.TickTime);
	}

	function _UpdateLocking(t)
	{
		if (!self._locking)
		{
			return;
		}

		self._lockingTimer.UpdateOnTick();
		if (self._lockingTimer.IsDone())
		{
			self._locking = false;
			return;
		}

		self.Titan.Position = self._lockingPos;
	}
}
