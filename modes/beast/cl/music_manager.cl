extension MusicManager
{
    BGM_1_2_CODE = "BGM1-BGM2";
    BGM_3_4_CODE = "BGM3-BGM4";
    BGM_5_6_CODE = "BGM5-BGM6";

    _collection = Dict();

    # @type MapObject
    _currentlyPlaying = null;

    function Initialize()
    {
        for (obj in Map.FindMapObjectsByTag("BGM"))
        {
            self._collection.Set(obj.Name, obj);
        }
    }

    # @param code string
    function Play(code)
    {
        self.Stop();

        if (!self._collection.Contains(code))
        {
            Game.SetPlaylist(code);
            return;
        }
        
        self._currentlyPlaying = self._collection.Get(code);
        self._currentlyPlaying.Active = true;
    }

    # @param code string
    # @param fadeInDelay float
    # @param fadeOutDelay float
    coroutine CrossFade(code, fadeInDelay, fadeOutDelay)
    {
        if (!self._collection.Contains(code))
        {
            Game.SetPlaylist(code);
            wait fadeOutDelay;
            self.Stop();
            return;
        }
        
        toStop = self._currentlyPlaying;

        wait fadeInDelay;
        self._currentlyPlaying = self._collection.Get(code);
        self._currentlyPlaying.Active = true;

        if (toStop == null)
        {
            return;
        }
        
        wait fadeOutDelay;
        toStop.Active = false;
    }

    function Stop()
    {
        Game.SetPlaylist("None");
        if (self._currentlyPlaying == null)
        {
            return;
        }

        self._currentlyPlaying.Active = false;
        self._currentlyPlaying = null;
    }
}
