// This script was developed by analysing AGN safe zones, maca safe zones, infistar safe zones, and others like them
// to create the best possible combination of them all.


/*************************** CONFIG ***************************/
	/* IMPORTANT */
	// You no longer need to choose your admin tools!
	// This script will now auto-detect and use the tool settings
	// Only for EAT and infistar
	
	EAT_szVehicleGod = true; // Protect vehicles in the safe zone
	EAT_szDetectTraders = true; // This can USUALLY detect the MAJOR THREE traders (no aircraft/bandit/hero)
	EAT_szUseCustomZones = false; // Allows you to set your own zone positions (Works with auto detect)
	EAT_szAntiTheft = true; // Disable stealing from inventory while in zone (allows interaction with friend inventory)
	EAT_szAiShield = false; // Remove AI in a radius around the zone
	EAT_szAiDistance = 100; // Distance to remove AI from players in a zone
	EAT_szZombieShield = true; // Remove zombies near players
	EAT_szZombieDistance = 20; // Distance to remove zombies from player in the zone
	EAT_szUseSpeedLimits = true; // Enforce a speed limit for vehicles to stop from pushing players out of zone
	EAT_szSpeedLimit = 35; // Max speed for vehicles inside the zones
	EAT_szUseHint = false; // Use hints for messages? (will display at bottom of screen instead if false)
	
	// You can find these in the sensors section of the mission.sqm for each map
	// Format: [[POSITION],RADIUS]
	EAT_szCustomZones = [
		// Cherno zones that can't be auto detected:
		[[1606.6443,289.70795,7803.5156],100], // Bandit
		[[12944.227,210.19823,12766.889],100], // Hero
		[[12060.471,158.85699,12638.533],100] // Aircraft (NO COMMA ON LAST LINE)
		// ALWAYS LEAVE OFF THE LAST "," OR THIS WILL BREAK
	];
/*************************** CONFIG ***************************/

	
private ["_fnc_enterZoneVehicle","_fnc_clearZombies","_fnc_enterZonePlayer","_fnc_exitZone","_EH_weaponFirePlayer","_EH_weaponFireVehicle","_enterMsg","_exitMsg"];
if (isNil "inZone") then {inZone = false;};
if (isNil "canbuild") then {canbuild = true;};
if (isNil "playerGod2") then {playerGod2 = false;};
if (isNil "vehicleGod2") then {vehicleGod2 = false;};
EAT_szSkipAdmin = false;
EAT_szSkipVeh = false;

_enterMsg = "*** PROTECTED ZONE! No stealing or shooting allowed ***";
_exitMsg = "*** GOD MODE DISABLED! You can now be damaged ***";
_EH_weaponFireVehicle = 1;
_EH_weaponFirePlayer = 1;


// handles players entering zone
_fnc_enterZonePlayer = {
	private["_player","_veh","_inZone"];

	inZone = true;
	_player = player;
	
	if(EAT_szUseHint) then {hint _enterMsg;} else { cutText[_enterMsg,"PLAIN DOWN"];};
	
	_EH_weaponFirePlayer = _player addEventHandler ["Fired", {deleteVehicle (nearestObject [_this select 0,_this select 4]);cutText ["***ALL weapons disabled inside Safe Zones***","WHITE IN",2];}];
	
	if (!playerGod2) then {
		player_zombieCheck = {};
		fnc_usec_damageHandler = {};
		_player removeAllEventHandlers "handleDamage";
		_player addEventHandler ["handleDamage", {false}];
		_player allowDamage false;
	};
};

// handles occupied vehicles in zone. This includes purchased ones.
// A player must enter the vehicle to enable god mode if it is purchased inside the zone.
_fnc_enterZoneVehicle = {
	private["_veh","_inZone"];
	_veh = vehicle player;
	if (player != _veh) then {
		_inZone = _veh getVariable ["inZone",0];
		if (_inZone == 0) then {
			_EH_weaponFireVehicle = _veh addEventHandler ["Fired", {deleteVehicle (nearestObject [_this select 0,_this select 4]);cutText ["***ALL weapons disabled inside Safe Zones***","WHITE IN",2];}];
			_veh setVariable ["inZone",1];
				
			if(EAT_szVehicleGod) then {
				vehicle_handleDamage = {};
				_veh removeAllEventHandlers "handleDamage";
				_veh addEventHandler ["handleDamage",{false}];
				_veh allowDamage false;
			};
		};
	};
};

// Handles players/vehicles leaving the zone
_fnc_exitZone = {
	private["_veh","_inZone","_player"];
	
	if(EAT_szUseHint) then {hint _exitMsg;} else { cutText[_exitMsg,"PLAIN DOWN"];};
	
	_player = player;
	_veh = vehicle _player;
	_veh removeEventHandler ["Fired",_EH_weaponFireVehicle];
	
	if (!isNil "adminCarGodToggle") then {if(adminCarGodToggle == 1)then{EAT_szSkipVeh = true;}else{EAT_szSkipVeh = false;};};

	if (player != _veh && !vehicleGod2 && EAT_szVehicleGod && !EAT_szSkipVeh) then {
		vehicle_handleDamage = compile preprocessFileLineNumbers "\z\addons\dayz_code\compile\vehicle_handleDamage.sqf";
		_inZone = _veh getVariable ["inZone",0];
		if (_inZone == 1) then {
			_veh setVariable ["inZone",0];
			_veh removeAllEventHandlers "handleDamage";
			_veh addEventHandler ["handleDamage",{_this call vehicle_handleDamage}];
			_veh allowDamage true;
		};
	};
	
	_player removeEventHandler ["Fired", _EH_weaponFirePlayer];
	
	if (!isNil "gmadmin") then {if(gmadmin == 1)then{EAT_szSkipAdmin = true;}else{EAT_szSkipAdmin = false;};};
	if (!playerGod2 && !EAT_szSkipAdmin) then {
		_player allowDamage true;
		player_zombieCheck = compile preprocessFileLineNumbers "\z\addons\dayz_code\compile\player_zombieCheck.sqf";
		fnc_usec_damageHandler = compile preprocessFileLineNumbers "\z\addons\dayz_code\compile\fn_damageHandler.sqf";
		_player removeAllEventHandlers "handleDamage";
		_player addEventHandler ["handleDamage",{_this call fnc_usec_damageHandler}];
	};
	inZone = false;
};

// Deletes zombies near players
_fnc_clearZombies = {
	private["_zombies"];
	_zombies = (vehicle player) nearEntities ["zZombie_Base",EAT_szZombieDistance];
	
	// Kill and hide zombies
	if((count _zombies) > 0) then {
		{
			if (!isNull _x && !isPlayer _x) then {
				_x setDamage 1;
				hideObject _x;
			} else {
				_zombies = _zombies - [_x];
			};
		} forEach _zombies;

		if((count _zombies) > 0) then {
			// Failure to delay entity delete results in RPT spam of lost _agent
			Sleep 2;
			{
				deleteVehicle _x;
			} forEach _zombies;	
		};
	};
};

// Deletes AI near the zone
_fnc_clearAI = {
	private ["_aiUnits"];
	_aiUnits = player nearEntities ['Man',EAT_szAiDistance];
	
	if((count _aiUnits) > 0) then {
		{
			if ((!isNull group _x) && (getPlayerUID _x == '')) then
			{
				_x setDamage 1;
				hideObject _x;
			} else {
				_aiUnits = _aiUnits - [_x];
			};
		} forEach _aiUnits;
		
		if((count _aiUnits) > 0) then {
			Sleep 2;
			{
				deleteVehicle _x;
			}forEach _aiUnits;
		};
	};
};

// Forces speed limit on LAND vehicles
_fnc_speedLimitEnforcer = {
	private["_veh","_speed","_slowPercent"];
	while {inZone} do {
		_veh = vehicle player;
		_speed = speed _veh;
		if(_veh != player && !(_veh isKindOf "Air") && (_speed > EAT_szSpeedLimit)) then {
			_vel = velocity _veh;
			_slowPercent = 0.8;
			if(_speed > 70) then {_slowPercent = 0.4;}else{if(_speed>50)then{_slowPercent = 0.6;};};
			_veh setVelocity [(_vel select 0) * _slowPercent,(_vel select 1) * _slowPercent,(_vel select 2) * _slowPercent];
		};
		Sleep 0.3;
	};
};
	
_fnc_antiTheft = {
	private["_friend","_ct","_dist","_ctPlayerID","_friendlies"];
	while{inZone} do {
		_friend = false;
		_ct = cursorTarget;
			if(!isNull _ct && isPlayer _ct) then {
				_dist = _ct distance player;
			if(_dist < 7) then {
				_ctPlayerID = _ct getVariable["CharacterID","0"];
				_friendlies	= player getVariable ["friendlyTo",[]];
				if(_ctPlayerID in _friendlies) then {_friend = true;};
			} else {
				_ct = nil;
			};
		};
		if(!isNull (FindDisplay 106) && (!isNull _ct && !_friend)) then {
			(findDisplay 106) closeDisplay 1;
			waitUntil {isNull (FindDisplay 106)};
			createGearDialog [(player), 'RscDisplayGear'];
			systemChat("Redirecting to your inventory...");
			systemChat("To enter a player's gear add them as a friend");
		};
		waitUntil {isNull (FindDisplay 106)};
	};
};

while {true} do	{
	private["_veh","_inZone"];
	
	_inZone = false;
	
	if (EAT_szUseCustomZones) then {
		{
			_z = _x select 0;
			_z = [_z select 0, _z select 2, 0];
			_r = _x select 1;
			if ((vehicle player) distance _z < _r) then {_inZone = true;};
		} forEach EAT_szCustomZones;
	};
	
	if (EAT_szDetectTraders) then {
		if (!canbuild) then {_inZone = true;};
	};

	if (_inZone) then {
		if(!inZone) then {
			call _fnc_enterZonePlayer;
			if(EAT_szAntiTheft)then{[_fnc_antiTheft]spawn {call (_this select 0);};};
			if(EAT_szUseSpeedLimits)then{[_fnc_speedLimitEnforcer] spawn {call (_this select 0);};};
		};
		call _fnc_enterZoneVehicle; // Must be called continuously to god mode purchased vehicles
		if(EAT_szZombieShield) then {call _fnc_clearZombies;};
		if(EAT_szAiShield) then {call _fnc_clearAI;};
	} else {
		if(inZone) then {call _fnc_exitZone;};
	};
	Sleep 1;
};
