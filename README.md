# WAC-Spawn-Tweaks-and-More
For Garry's Mod, fixes occasional spawn bug and adds configurable tweaks to how WAC Aircraft fly.
 
 
From the workshop page:  
 (https://steamcommunity.com/sharedfiles/filedetails/?id=2984355144)


The old but objectively awesome WAC Aircraft addons sometimes spawn aircraft underground and/or cause them to explode immediately.

This addon fixes that and places the spawned WAC just above the ground using a path trace.

It also adds a ton of config options for singleplayer and server owners! Want to tweak power, stability, lift, drag, and more? This addon will let you do all that and works for all WAC Aircraft!

**Bonus Features:**
- Health regen when spawned!
- Engine Performance modifier. (defaults to 1.5x original power)
- Angular Drag modifier. (defaults to 2x for more relaxed control)
- Works in single and multiplayer.
- It's just one small LUA file.


**General Console Config Settings:**
- _WACspawnTweaks_Spawn_Frozen 0_  
    Spawn WAC frozen? (0-1)

- _WACspawnTweaks_Regen_Seconds 10_  
    Force self-repair for this many seconds after WAC is spawned. (1-999999)

- _WACspawnTweaks_EnginePerf_Multiplier 1.5_  
    Universal Engine power multiplier for newly spawned WAC.  
    (1=Original, 1.5=Good, 3=Arcade, 10=Kerbal)

- _WACspawnTweaks_AngleDrag_Multiplier 2_  
    Modify a newly spawned WAC's angular drag.  
    (1=Original, 2=More realistic, 10=Cruse ship)


Advanced Config Settings:

- _WACspawnTweaks_Rail_Multiplier 1_  
    Modify how stable newly spawned WAC is on its path (aka Rail). Higher means less drift.  
    (1=Original, 2=Casual, 100=Flying in honey)

- _WACspawnTweaks_PointForward_Ratio 1_  
    Modify a newly spawned WAC's desire to point forward while moving.  
    (0.5=Top Gun Maverick, 1=Original)

- _WACspawnTweaks_Self-Lift_Ratio 1_  
    Modify a newly spawned WAC's desire to lift while moving.  
    (0.5=Top Gun Maverick, 1=Original)
