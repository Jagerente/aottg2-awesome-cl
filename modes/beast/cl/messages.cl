#######################
# Messages
#######################

extension BaseMessage
{
    KEY_TOPIC = "topic";
}

extension SetLocalizedLabelMessage
{
    TOPIC = "set_localized_label";
    
    KEY_POSITION = "position";
    KEY_LOCALIZED_KEY = "localized_key";
    KEY_PARAMS = "params";
    KEY_TIME = "time";

    function New(
        position,
        localizedKey,
        params,
        time
    )
    {
        msg = Dict();
        msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
        msg.Set(self.KEY_POSITION, position);
        msg.Set(self.KEY_LOCALIZED_KEY, localizedKey);
        msg.Set(self.KEY_PARAMS, params);
        msg.Set(self.KEY_TIME, time);
        return msg;
    }
}

extension PlayMusicMessage
{
    TOPIC = "play_music";
    
    KEY_CODE = "code";

    function New(code)
    {
        msg = Dict();
        msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
        msg.Set(self.KEY_CODE, code);
        return msg;
    }
}

extension RunCutsceneMessage
{
    TOPIC = "run_cutscene";
    
    KEY_ID = "id";

    function New(id)
    {
        msg = Dict();
        msg.Set(BaseMessage.KEY_TOPIC, self.TOPIC);
        msg.Set(self.KEY_ID, id);
        return msg;
    }
}
