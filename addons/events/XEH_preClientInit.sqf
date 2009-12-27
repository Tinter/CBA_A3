//#define DEBUG_MODE_FULL
#include "script_component.hpp"

LOG(MSG_INIT);

["CBA_loadGame",
{
	[] spawn FUNC(attach_handler);
}] call CBA_fnc_addEventHandler;

["CBA_playerSpawn", { LOG("Player spawn detected!") }] call CBA_fnc_addEventHandler;

[] spawn
{
	private ["_lastPlayer", "_newPlayer"];
	waitUntil {player == player};
	_lastPlayer = objNull;
	while {true} do
	{
		waitUntil {player != _lastPlayer};
		waitUntil {!(isNull player)};
		_newPlayer = player; // Cumbersome but ensures refering to the same object
		["CBA_playerSpawn", [_newPlayer, _lastPlayer]] call CBA_fnc_localEvent;
		_lastPlayer = _newPlayer;
	};
};


// Display Eventhandlers - Higher level API specially for keyDown/Up and Action events
// Workaround , in macros
#define UP [_this, 1]
#define DOWN [_this, 0]

[] spawn
{
	waitUntil { !(isNull (findDisplay 46)) };
	// IMPORTANT: Case Sensitive Strings!
	["keyUp", QUOTE(UP call FUNC(keyHandler))] call CBA_fnc_addDisplayHandler;
	["keyDown", QUOTE(DOWN call FUNC(keyHandler))] call CBA_fnc_addDisplayHandler;
	["keyDown", QUOTE(_this call FUNC(actionHandler))] call CBA_fnc_addDisplayHandler;

	// Workaround for displayEventhandlers falling off at gameLoad
	// Once the last registered keypress is longer than 10 seconds ago, re-attach the handler.
	GVAR(keypressed) = time;
	while {true} do
	{
		waitUntil {(time - GVAR(keypressed)) > 10};
		call FUNC(attach_handler);
		GVAR(keypressed) = time;
	};
};
