# WAC-Spawn-Tweaks-and-More
For Garry's Mod, fixes occasional spawn bug and adds configurable tweaks to how WAC Aircraft fly.
 
 
From the workshop page:  
 (https://steamcommunity.com/sharedfiles/filedetails/?id=2984355144)


The old but objectively awesome WAC Aircraft addons sometimes spawn aircraft underground and/or cause them to explode immediately.

This addon fixes that and places the spawned WAC just above the ground using a path trace.

**Bonus Features:**
- Health regen when spawned! (defaults to just 10 seconds)
- Engine Performance modifier. (defaults to 2x original power)
- Works in single and multiplayer on all surfaces.
- It's just one small LUA file.

**Console Variable Config Settings:**
- _WACspawnTweaks_Spawn_Frozen 0_  
Spawn WAC frozen? (0-1)

- _WACspawnTweaks_Regen_Seconds 10_  
Force self-repair for this many seconds after WAC is spawned. (1-999)

- _WACspawnTweaks_EnginePerf_Multiplier 2_  
Universal Engine power multiplier for newly spawned WAC. (1=Original, [2]=Good, 5=Arcade, 10=Pain)
