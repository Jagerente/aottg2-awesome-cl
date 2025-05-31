extension SupplyStationSwitcher
{
	# @type List<MapObject>
	_supplyStations = null;

	function Initialize()
	{
		self._supplyStations = Map.FindMapObjectsByComponent("SupplyStation");
	}

	function Activate()
	{
		for (s in self._supplyStations)
		{
			s.SetComponentEnabled("SupplyStation", true);
		}
	}

	function Deactivate()
	{
		for (s in self._supplyStations)
		{
			s.SetComponentEnabled("SupplyStation", false);
		}
	}
}
