# @import messages
# @import i18n
# @import music_manager
# @import cutscene_manager

#######################
# Message Handlers
#######################

class SetLocalizedLabelMessageHandler
{
	function Handle(sender, msg)
	{
		position = msg.Get(SetLocalizedLabelMessage.KEY_POSITION);
		localizedKey = msg.Get(SetLocalizedLabelMessage.KEY_LOCALIZED_KEY);
		params = msg.Get(SetLocalizedLabelMessage.KEY_PARAMS, null);
		time = msg.Get(SetLocalizedLabelMessage.KEY_TIME, null);

		if (localizedKey == "")
		{
			UI.SetLabel(position, "");
			return;
		}

		if (params != null)
		{
			label = String.FormatFromList(I18n.Get(localizedKey), params);
		}
		else
		{
			label = I18n.Get(localizedKey);
		}

		if (time != null)
		{
			UI.SetLabelForTime(position, label, time);
		}
		else
		{
			UI.SetLabel(position, label);
		}
	}
}

class PlayMusicMessageHandler
{
	function Handle(sender, msg)
	{
		code = msg.Get(PlayMusicMessage.KEY_CODE);

		MusicManager.Play(code);
	}
}

class RunCutsceneMessageHandler
{
	function Handle(sender, msg)
	{
		id = msg.Get(RunCutsceneMessage.KEY_ID);
		full = msg.Get(RunCutsceneMessage.KEY_FULL);

		CutsceneManager.Start("Cutscene_" + id, full);
	}
}
