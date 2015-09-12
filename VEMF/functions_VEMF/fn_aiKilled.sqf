/*
	VEMF AI Killed by Vampire, rewritten by IT07

	Description:
	removes launchers if desired and announces the kill if enabled in config.cpp

	Params:
	_this select 0: OBJECT - the killed AI
	_this select 1: OBJECT - killer

	Returns:
	nothing
*/

_target = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
if (damage _target isEqualto 1) then
{
	_target removeAllEventHandlers "HitPart";
	_killer = [_this, 1, objNull, [objNull]] call BIS_fnc_param;
	if not isNull _killer then
	{
		if (vehicle _killer isEqualTo _killer) then // No roadkills please
		{
			_giveRespectah = "giveKillerRespect" call VEMF_fnc_getSetting;
			if (_giveRespectah isEqualto 1) then
			{
				_respectToGive = "baseRespectGive" call VEMF_fnc_getSetting;
				if (_respectToGive > 0) then
				{
					_killMsg = ["AI WACKED","AI CLIPPED","AI DISABLED","AI DISQUALIFIED","AI WIPED","AI WIPED","AI ERASED","AI LYNCHED","AI WRECKED","AI NEUTRALIZED","AI SNUFFED","AI WASTED","AI ZAPPED"] call VEMF_fnc_random;
					_dist = _target distance _killer;
					_bonus = round (_dist / 3);
					[_killer, "showFragRequest", [[[_killMsg, _respectToGive + _bonus]]]] call ExileServer_system_network_send_to;
					_curRespect = _killer getVariable ["ExileScore", 0];
					_newRespect = _curRespect + _respectToGive + _bonus;
					_killer setVariable ["ExileScore", _newRespect];
					ExileClientPlayerScore = _newRespect;
					(owner _killer) publicVariableClient "ExileClientPlayerScore";
					ExileClientPlayerScore = nil;
					format["setAccountMoneyAndRespect:%1:%2:%3", _killer getVariable ["ExileMoney", 0], _newRespect, (getPlayerUID _killer)] call ExileServer_system_database_query_fireAndForget;
				};
			};

			if (("sayKilled" call VEMF_fnc_getSetting) isEqualTo 1) then // Send kill message if enabled
			{
				_dist = _target distance _killer;
				if (_dist > -1) then
				{
					if (isPlayer _killer) then // Should prevent Error:NoUnit
					{
						_curWeapon = currentWeapon _killer;
						_kMsg = format["[VEMF] %1 *poofed* an AI from %2m with %3", name _killer, round _dist, getText(configFile >> "CfgWeapons" >> _curWeapon >> "DisplayName")];
						_sent = [_kMsg, "sys"] call VEMF_fnc_broadCast;
					};
				};
			};
		};

		if not (vehicle _killer isEqualTo _killer) then
		{ // Send kill message if enabled
			if (("sayKilled" call VEMF_fnc_getSetting) isEqualTo 1) then
			{
				_dist = _target distance _killer;
				if (_dist < 5) then
				{
					if (isPlayer _killer) then // Should prevent Error:NoUnit
					{
						_kMsg = format["[VEMF] %1 road-killed an AI", name _killer];
						_sent = [_kMsg, "sys"] call VEMF_fnc_broadCast;
					};
				};
			};
		};
	};

	_settings = [["keepLaunchers","keepAIbodies"]] call VEMF_fnc_getSetting;
	_remLaunchers = _settings select 0;
	if (_remLaunchers isEqualTo -1) then
	{
		_secWeapon = secondaryWeapon _target;
		if not(_secWeapon isEqualTo "") then
		{
			_target removeWeaponGlobal _secWeapon;
			_missiles = getArray (configFile >> "cfgWeapons" >> _secWeapon >> "magazines");
			{
				if (_x in (magazines _target)) then
				{
					_target removeMagazine _x;
				};
			} forEach _missiles;
		};
	};

	if ((_settings select 1) isEqualTo -1) then // If killEffect enabled
	{
		playSound3D ["A3\Missions_F_Bootcamp\data\sounds\vr_shutdown.wss", _target, false, getPosASL _target, 2, 1, 60];
		for "_u" from 1 to 8 do
		{
			if not(isObjectHidden _target) then
			{
				_target hideObjectGlobal true;
			} else
			{
				_target hideObjectGlobal false;
			};
			uiSleep 0.15;
		};
		_target hideObjectGlobal true;
		removeAllWeapons _target;
		// Automatic cleanup yaaay
		deleteVehicle _target;
	};
};
