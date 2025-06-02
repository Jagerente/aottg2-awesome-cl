class Timer
{
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
		self.UpdateOn(Time.FrameTime);
	}

	function UpdateOnTick()
	{
		self.UpdateOn(Time.TickTime);
	}

	# @param t float
	function UpdateOn(t)
	{
		self._time -= t;
	}
}
