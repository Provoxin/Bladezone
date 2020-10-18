#!mainFile "bladezone.opy"

#!define menuPageNames [\
"GENERAL",\
"MODIFIERS",\
"RING SPAWNING",\
"PRESET POINTS SPAWNING"\
]

#!define menuPageTexts [\
[\
"{0} CREATE BOT {1}".format(buttonString(Button.PRIMARY_FIRE), heroIcon(botHeroes.exclude([player.getCurrentHero() for player in getPlayers(Team.2)])[0]) if getNumberOfPlayers(Team.2) < len(botHeroes) else "(NONE LEFT)"),\
"{0} GRAB BOT".format(buttonString(Button.SECONDARY_FIRE)),\
"[{0}] CHANGE BOT HERO".format(buttonString(Button.ABILITY_2)),\
"[{0}] REMOVE BOT".format(buttonString(Button.ULTIMATE)),\
"[{0}] + [{1}] REMOVE ALL BOTS".format(buttonString(Button.ABILITY_1), buttonString(Button.ULTIMATE)),\
"[{0}] PLACE RESET MARKER".format(buttonString(Button.RELOAD)),\
"[{0}] + [{1}] REMOVE RESET MARKER".format(buttonString(Button.ABILITY_1), buttonString(Button.RELOAD)),\
"[{0}] INCREASE PLACEMENT DISTANCE".format(buttonString(Button.MELEE)),\
"[{0}] + [{1}] DECREASE PLACEMENT DISTANCE".format(buttonString(Button.ABILITY_1), buttonString(Button.MELEE))\
],\
[\
"[{0}] {1} NANOBOOST DAMAGE".format(buttonString(Button.ULTIMATE), "DISABLE" if eventPlayer.nanoEnabled else "ENABLE"),\
"[{0}] + [{1}] {2} NANOBOOST VFX".format(buttonString(Button.ABILITY_1), buttonString(Button.ULTIMATE), "DISABLE" if eventPlayer.nanoVFXEnabled else "ENABLE"),\
"[{0}] {1} UNLIMITED DASHES".format(buttonString(Button.ABILITY_2), "DISABLE" if eventPlayer.infiniteDashEnabled else "ENABLE"),\
"[{0}] {1} INSTAKILL".format(buttonString(Button.MELEE), "DISABLE" if eventPlayer.instakillEnabled else "ENABLE")\
],\
[\
"CURRENT SPAWNING MODE: {0}{1}".format(["DEFAULT", "RING", "PRESET POINTS"][spawningMode], " ([{0}] TO SWITCH TO RING)".format(buttonString(Button.RELOAD)) if spawningMode != SpawnMode.RING else ""),\
"{0} PLACE RING".format(buttonString(Button.PRIMARY_FIRE)),\
"{0} REMOVE RING".format(buttonString(Button.SECONDARY_FIRE)),\
"[{0}] INCREASE RING RADIUS".format(buttonString(Button.ULTIMATE)),\
"[{0}] + [{1}] DECREASE RING RADIUS".format(buttonString(Button.ABILITY_1), buttonString(Button.ULTIMATE)),\
"[{0}] INCREASE RING HEIGHT".format(buttonString(Button.ABILITY_2)),\
"[{0}] + [{1}] DECREASE RING HEIGHT".format(buttonString(Button.ABILITY_1), buttonString(Button.ABILITY_2)),\
"[{0}] RESHUFFLE BOTS / SET SPAWN MODE".format(buttonString(Button.RELOAD)),\
"[{0}] {1} RESPAWN AT NEAREST WALKABLE POSITION".format(buttonString(Button.MELEE), "DISABLE" if respawnAtNearestWalkable else "ENABLE")\
],\
[\
"CURRENT SPAWNING MODE: {0}{1}".format(["DEFAULT", "RING", "PRESET POINTS"][spawningMode], " ([{0}] TO SWITCH TO PRESET POINTS)".format(buttonString(Button.RELOAD)) if spawningMode != SpawnMode.PRESETS else ""),\
"{0} PLACE SPAWN POINT".format(buttonString(Button.PRIMARY_FIRE)),\
"{0} REMOVE SPAWN POINT".format(buttonString(Button.SECONDARY_FIRE)),\
"[{0}] REMOVE ALL SPAWN POINTS".format(buttonString(Button.ULTIMATE)),\
"[{0}] INCREASE SPAWN VARIANCE (CURRENTLY {1})".format(buttonString(Button.ABILITY_2), presetPointVariance),\
"[{0}] + [{1}] DECREASE SPAWN VARIANCE".format(buttonString(Button.ABILITY_1), buttonString(Button.ABILITY_2)),\
"[{0}] RESHUFFLE BOTS / SET SPAWN MODE".format(buttonString(Button.RELOAD))\
]\
]