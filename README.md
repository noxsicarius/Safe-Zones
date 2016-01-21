Safe-Zones
==========

#### IMPORTANT: This is built into Epoch Admin Tools (test branch v 1.10.5 and above)
#### If you do not know if you have the test branch, you most likely do not.

## Installation Instructions

1. Click ***[Download Zip](https://github.com/noxsicarius/Safe-Zones/archive/master.zip)*** on the right sidebar of this Github page.

1. Extract the downloaded folder to your desktop
1. Navigate to your ***MPMissions\\[mission]*** folder.
1. Copy the ***custom*** folder to this mission
1. Open the ***init.sqf***

	And past the following code ***at the bottom*** of it:
	
	~~~~java
	[] ExecVM "custom\safeZones.sqf";
	~~~~

1. Save the file