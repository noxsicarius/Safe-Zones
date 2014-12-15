Safe-Zones
==========

## Installation Instructions

1. Click ***[Download Zip](https://github.com/noxsicarius/Safe-Zones/archive/master.zip)*** on the right sidebar of this Github page.

1. Extract the downloaded folder to your desktop
1. Navigate to your ***MPMissions\[mission]*** folder.
1. Copy the ***custom*** folder to this mission
1. Open the ***init.sqf***

	And past the following code ***at the bottom*** of it:
	
	~~~~java
	[] ExecVM "custom\safeZoneCars.sqf";
	[] ExecVM "custom\safeZoneCommander.sqf";
	~~~~

1. Save the file