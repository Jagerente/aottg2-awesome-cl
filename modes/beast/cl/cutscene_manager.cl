# @import Timer
extension CutsceneManager
{
    _timers = Dict();
    _cutscenesState = Dict();
    _cutscenesCanPlay = Dict();
    _timer = Timer(0.0);
    _pendingTimer = Timer(0.0);
    _pendingCutsceneID = null;
    _pendingCutsceneFull = null;
    _isCutsceneRunning = false;
    _skipSignal = false;

    # @param id string
    # @param full bool
    function Start(id, full)
    {
        if (self._pendingCutsceneID == id || !self.GetCanPlay(id))
        {
            return;
        }

        if (self._isCutsceneRunning)
        {
            self._pendingCutsceneID = id;
            self._pendingCutsceneFull = full;
            self._skipSignal = true;
        }
        else
        {
            self.SetCanPlay(id, false);
            self._isCutsceneRunning = true;
            Cutscene.Start(id, full);
        }
    }

    # @param t float
    function Wait(t)
    {
        self._timer.Reset(t);
    }

    function ResetTimer()
    {
        self._timer.Reset(0.0);
    }

    function IsTimerDone()
    {
        return self._timer.IsDone();
    }

    function GetState(k)
    {
        return self._cutscenesState.Get(k, 0);
    }
    
    # @param k string
    # @param v int
    function SetState(k, v)
    {
        return self._cutscenesState.Set(k, v);
    }
    
    # @param k string
    function GetCanPlay(k)
    {
        return self._cutscenesCanPlay.Get(k, true);
    }
    
    # @param k string
    # @param v bool
    function SetCanPlay(k, v)
    {
        return self._cutscenesCanPlay.Set(k, v);
    }

    # @return bool
    function SkipSent()
    {
        return self._skipSignal;
    }

    function OnTick()
    {
        self._timer.UpdateOnTick();

        if (!self._isCutsceneRunning)
        {
            self._pendingTimer.UpdateOnTick();
            pID = self._pendingCutsceneID;
            pFull = self._pendingCutsceneFull;
            if (self._pendingTimer.IsDone() && pID != null)
            {
                # self._pendingTimer.Reset(0.25);
                self._isCutsceneRunning = true;
                self._pendingCutsceneID = null;
                self._pendingCutsceneFull = null;
                self.SetCanPlay(pID, false);
                Cutscene.Start(pID, pFull);
            }
        }
    }

    function ResetAll()
    {
        if (self._isCutsceneRunning)
        {
            self._skipSignal = true;
        }
        else
        {
            self._skipSignal = false;
        }
        self._pendingCutsceneID = null;
        self._pendingCutsceneFull = null;

        self._cutscenesState.Clear();
        self._cutscenesCanPlay.Clear();

        self._isCutsceneRunning = false;
    }

    # @param k string
    function OnCutsceneComplete(k)
    {
        self.Wait(0.0);
        self._isCutsceneRunning = false;
        self._skipSignal = false;
        if (self._pendingCutsceneID != null)
        {
            self._pendingTimer.Reset(0.1);
        }
    }
}
