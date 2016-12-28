# PassiveZones
Adds PassiveZones where Passive is forced on using DaAlpha's ProperPassive.

The only included PassiveZone is at RaceTrack, to add more look at [client/cPassiveZones.lua line 16](https://github.com/Dbeast247/PassiveZones/blob/master/client/cPassiveZones.lua#L16)

## Requirements:
https://github.com/DaAlpha/ProperPassive

https://github.com/SinisterRectus/JC2MP-TimerExtension

## Setup
Add the [shared](https://github.com/SinisterRectus/JC2MP-TimerExtension/tree/master/shared) folder from SinisterRectus's TimerExtension to PassiveZones so you have PassiveZones/shared/Timer.lua.

For this to work with ProperPassive you must modify [ProperPassive/client/cPassive.lua](https://github.com/DaAlpha/ProperPassive/blob/master/client/cPassive.lua),
Add
```lua
if LocalPlayer:GetValue("ForcePassive") then
	Chat:Print("You are in a Passive Zone, you may not disable passive", Color.Red)
	return false
end	
```
at [line 39](https://github.com/DaAlpha/ProperPassive/blob/master/client/cPassive.lua#L39).