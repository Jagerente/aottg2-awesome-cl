extension GameState
{	
	GameStarted = false;

	# @type List<TitanProxy>
	Titans = List();

	# @type Dict<int, bool>
	Players = Dict();

	function IsAllPlayersLoaded()
	{
		return self.Players.Count >= Network.Players.Count;
	}

	function AddPlayer(id)
	{
		self.Players.Set(id, true);
	}

	function RemovePlayer(id)
	{
		self.Players.Remove(id);
	}
}
