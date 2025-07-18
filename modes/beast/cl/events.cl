# @import game_state
# @import router
# @import i18n
# @import messages
# @import beast_titan
# @import html
# @import enums

#######################
# Events
#######################

class KillTitansEvent
{
	CODE_IN_PROGRESS = -1;
	CODE_COMPLETED = 0;
	CODE_ALL_DIED = 1;
	CODE_OUT_OF_TIME = 2;

	_status = -1;
	_cutscene1Once = false;
	_cutscene2Once = false;

	_timeLeft = 0.0;
	_playersReady = false;
	_titansNumForPhase2 = 0;
	_timeout = 15.0;

	# @param time float|null
	# @param titans int
	function Init(time, titans, timeout)
	{
		self._timeLeft = time;
		self._titansNumForPhase2 = titans;
		self._timeout = timeout;
	}

	# @param t float
	function Update(t)
	{
		if (self.IsDone())
		{
			return;
		}

		self._playersReady = self._playersReady || Game.Humans.Count > 0;
		if (!self._playersReady)
		{
			Game.SpawnPlayerAll(false);
			return;
		}

		if (!GameState.IsAllPlayersLoaded() && Time.GameTime <= self._timeout)
		{
			return;
		}

		if (!self._cutscene1Once)
		{
			self._cutscene1Once = true;
			Dispatcher.SendAll(RunCutsceneMessage.New(1, false));
		}

		if (!GameState.GameStarted)
		{
			return;
		}

		if (self._timeLeft != null) {
			self._timeLeft -= t;
		}

		if (Game.Humans.Count == 0)
		{
			Dispatcher.SendAll(RunCutsceneMessage.New(4, false));
			Dispatcher.SendAll(SetLocalizedLabelMessage.New(
				"MiddleCenter",
				"ui.lose",
				null,
				10.0
			));

			Game.End(10.0);

			for(t in Game.Titans)
			{
				t.Emote("Laugh");
			}

			self._status = self.CODE_ALL_DIED;
			return;
		}
		elif(Game.Titans.Count <= 3)
		{
			self._status = self.CODE_COMPLETED;
			return;
		}
		elif (self._timeLeft != null && self._timeLeft <= 0)
		{
			Game.End(10.0);

			Dispatcher.SendAll(RunCutsceneMessage.New(5, false));
			Dispatcher.SendAll(SetLocalizedLabelMessage.New(
				"MiddleCenter",
				"ui.lose.2",
				null,
				10.0
			));

			self._status = self.CODE_OUT_OF_TIME;
			return;
		}
		elif (!self._cutscene2Once && Game.Titans.Count <= self._titansNumForPhase2)
		{
			self._cutscene2Once = true;
			Dispatcher.SendAll(RunCutsceneMessage.New(2, false));
		}
	}

	# @return string
	function Goal()
	{
		if (self.IsDone())
		{
			return "";
		}

		params = List();
		params.Add(Convert.ToString(Game.Titans.Count));
		if (self._timeLeft == null)
		{
			return String.FormatFromList(I18n.Get("ui.goal.kill_titans"), params);
		}
		else
		{
			params.Add(String.FormatFloat(self._timeLeft, 0));

			return String.FormatFromList(I18n.Get("ui.goal.kill_titans_time"), params);
		}
	}

	# @return string
	function GoalKey()
	{
		if (!GameState.GameStarted)
		{
			return "";
		}

		if (self._timeLeft == null)
		{
			return "ui.goal.kill_titans";
		}
		else
		{
			return "ui.goal.kill_titans_time";
		}
	}

	# @return List<string>
	function GoalParams()
	{
		params = List();
		params.Add(Convert.ToString(Game.Titans.Count));
		if (self._timeLeft != null)
		{
			params.Add(String.FormatFloat(self._timeLeft, 0));
		}
		return params;
	}

	# @return boolean
	function IsDone(){
		return self._status != self.CODE_IN_PROGRESS;
	}

	# @return string
	function Outcome(){
		return self._status;
	}
}

class KillBeastEvent
{
	CODE_IN_PROGRESS = -1;
	CODE_COMPLETED = 0;
	CODE_ALL_DIED = 1;
	CODE_OUT_OF_TIME = 2;

	_status = -1;
	_beastKilled = false;

	# @type ZekeShifter
	_beastTitan = null;

	_timeLeft = 0.0;

	_once = false;

	# @param time float|null
	# @param beastTitan ZekeShifter
	function Init(time, beastTitan)
	{
		self._timeLeft = time;
		self._beastTitan = beastTitan;
		self._beastTitan.RegisterOnDieHandler(self);
	}

	# @param t float
	function Update(t)
	{
		if (self.IsDone())
		{
			return;
		}

		if (!self._once)
		{
			Dispatcher.SendAll(RunCutsceneMessage.New(3, false));
			self._once = true;
		}

		if (self._timeLeft != null) {
			self._timeLeft -= t;
		}

		if (Game.Titans.Count == 0)
		{
			self._beastTitan.SetNapeProtected(true);
		}

		if (Game.Humans.Count == 0)
		{
			Dispatcher.SendAll(RunCutsceneMessage.New(4, false));
			Dispatcher.SendAll(SetLocalizedLabelMessage.New(
				"MiddleCenter",
				"ui.lose",
				null,
				10.0
			));

			Game.End(10.0);

			for(t in Game.Titans)
			{
				t.Emote("Laugh");
			}

			self._status = self.CODE_ALL_DIED;
			return;
		}
		elif (self._beastKilled)
		{
			if(Network.IsMasterClient)
			{
				Dispatcher.SendAll(RunCutsceneMessage.New(6, false));
				Dispatcher.SendAll(SetLocalizedLabelMessage.New(
					"MiddleCenter",
					"ui.zeke_defeated",
					null,
					10.0
				));
				Game.End(10.0);
			}
			self._status = self.CODE_COMPLETED;
		}
		elif (self._timeLeft != null && self._timeLeft <= 0)
		{
			Game.End(10.0);

			Dispatcher.SendAll(RunCutsceneMessage.New(5, false));
			Dispatcher.SendAll(SetLocalizedLabelMessage.New(
				"MiddleCenter",
				"ui.lose.2",
				null,
				10.0
			));

			self._status = self.CODE_OUT_OF_TIME;
			return;
		}
	}

	# Callback for Beast
	function Handle(character, damage)
	{
		self._beastKilled = true;
	}

	# @return string
	function Goal()
	{
		if (self.IsDone())
		{
			return "";
		}

		if (self._beastTitan._enabled)
		{
			monkey1Text = HTML.Size(I18n.Get("general.beast.sentencecase"), 25);
			monkeyText = HTML.Color(monkey1Text, ColorEnum.Brown);

			params = List();
			params.Add(monkeyText);

			return String.FormatFromList(I18n.Get("ui.goal.kill_beast"), params);
		}
	}

	# @return string
	function GoalKey()
	{
		if (self.IsDone())
		{
			return "";
		}

		return "ui.goal.kill_beast";
	}

	# @return List<string>
	function GoalParams()
	{
		return null;
	}

	# @return boolean
	function IsDone(){
		return self._status != self.CODE_IN_PROGRESS;
	}

	# @return string
	function Outcome(){
		return self._status;
	}
}
