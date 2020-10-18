#!mainFile "bladezone.opy"

settings {
    "main": {
        "description": "Bladezone, by Provoxin#1418"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "spectatorSlots": 12,
        "team1Slots": 5,
        "team2Slots": 0
    },
    "gamemodes": {
        "skirmish": {
            "disabledMaps": [
                "workshopChamber",
                "workshopExpanse",
                "workshopExpanseNight",
                "workshopIsland",
                "workshopIslandNight"
            ]
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "respawnTime%": 0
        }
    },
    "heroes": {
        "team1": {
            "general": {
                "damageReceived%": 50
            }
        },
        "allTeams": {
            "genji": {
                "enableInfiniteUlt": true
            },
            "zenyatta": {
                "enableAbility1": false
            },
            "enabledHeroes": [
                "genji"
            ]
        }
    }
}