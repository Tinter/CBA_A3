#include "script_component.hpp"

LOG(MSG_INIT);

// NOTE: Due to activateAddons being overwritten by eachother (only the last executed command will be active), we apply this bandaid
[] call compile preProcessFileLineNumbers QUOTE(PATHTO_F(init_addons));

// NOTE: Due to the way the BIS functions initializations work, and the requirement of BIS_functions_mainscope to be a unit (in a group)
//       the logic is created locally on MP dedicated client, to still allow this early, called precompilation of the functions.
//       But initialization doesn't officially finish until the official (server created / mission.sqm included) logic is available.
//		 In SP or as server (dedicated or clientServer), the logic is created with group and createUnit.
private ["_group", "_logic"];
if (isNil "BIS_functions_mainscope") then
{
	if (isServer) then
	{
		// CREATE_CENTER sideLogic; // Handled in function
		_group = [sideLogic] call CBA_fnc_getSharedGroup;
		_logic = _group createUnit ["FunctionsManager", [0,0,0], [], 0, "none"];
		TRACE_2("Created FunctionsManager Logic",_group,_logic);
	} else {
		// TODO: Evaluate cleanup for this one
		_logic = "LOGIC" createVehicleLocal [0, 0];
		TRACE_1("Created FunctionsManager Logic (local)",_logic);
	};
} else {
	_logic = BIS_functions_mainscope;
	TRACE_1("Using already available BIS_functions_mainscope",_logic);
};

if (isnil "RE") then
{
	LOG("Initialising the MP module early.");
	_this call compile preprocessFileLineNumbers "\ca\Modules\MP\data\scripts\MPframework.sqf";
};
