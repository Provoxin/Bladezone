settings
{
	main
	{
		Description: "Bladezone, by Provoxin#1418"
	}
	lobby
	{
		Allow Players Who Are In Queue: Yes
		Max Spectators: 12
		Max Team 1 Players: 5
		Max Team 2 Players: 0
	}
	modes
	{
		Skirmish
		{
			disabled maps
			{
				Workshop Chamber
				Workshop Expanse
				Workshop Expanse Night
				Workshop Island
				Workshop Island Night
			}
		}
		General
		{
			Game Mode Start: Immediately
			Hero Limit: Off
			Respawn Time Scalar: 0%
		}
	}
	heroes
	{
		Team 1
		{
			Damage Received: 50%
		}
		General
		{
			Genji
			{
				Infinite Ultimate Duration: On
			}
			enabled heroes
			{
				Genji
			}
		}
	}
}
variables {
    global:
        0: botHeroes
        1: nanoBot
        2: runnerData
        3: spawningMode
        4: spawnRingPos
        5: spawnRingRadius
        6: spawnRingHeight
        7: respawnAtNearestWalkable
        8: i
        9: bot
        10: botLoopIndex
        11: spawnPointPositions
        12: chosenSpawnPointPositions
        13: spawnPointEffectIDs
        14: presetPointVariance
    player:
        0: isEditing
        1: noclipPosition
        2: grabbedBot
        3: targetedDummy
        4: resetPos
        5: placementDistance
        6: menuPage
        7: menuPageTextIDs
        8: i
        9: pageTextIndex
        10: modifierSettings
        11: currentRunTime
        12: lastRunTime
        13: bestRunTime
        14: changingPage
        15: randomSpawnData
        16: buttonsHeld
        17: isChangingBot
        18: prevFacing
}
subroutines {
    0: giveNano
    1: loadPage
    2: unloadPage
    3: setBotPositions
}
rule ("​                                                                 Made by Provoxin - Contact me on Discord @Provoxin#5368") {
    event {
        Ongoing - Global;
    }
}

rule ("/// Default bot heroes") {
    event {
        Ongoing - Global;
    }
    actions {
        Set Global Variable(botHeroes, Empty Array);
        Modify Global Variable(botHeroes, Append To Array, Hero(Ana));
        Modify Global Variable(botHeroes, Append To Array, Hero(Ashe));
        Modify Global Variable(botHeroes, Append To Array, Hero(Baptiste));
        Modify Global Variable(botHeroes, Append To Array, Hero(Echo));
        Modify Global Variable(botHeroes, Append To Array, Hero(Sigma));
        Modify Global Variable(botHeroes, Append To Array, Hero(Zarya));
    }
}

disabled rule ("----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------") {
    event {
        Ongoing - Global;
    }
}

rule ("sub_giveNano") {
    event {
        Subroutine;
        giveNano;
    }
    actions {
        "teleport behind genji"
        Teleport(Global.nanoBot, Ray Cast Hit Position(Position Of(Event Player), Add(Position Of(Event Player), Multiply(Normalize(Multiply(Facing Direction Of(Event Player), Vector(True, False, True))), -2)), All Players(Team 1), Empty Array, False));
        "face towards the center of genji"
        Start Facing(Global.nanoBot, Direction Towards(Eye Position(Global.nanoBot), Divide(Add(Position Of(Event Player), Eye Position(Event Player)), 2)), 5000, To World, Direction and Turn Rate);
        "press nano"
        Press Button(Global.nanoBot, Ultimate);
        "wait for casting time"
        Wait(0.145, Ignore Condition);
        "if didn't cast, retry"
        Loop If(Not(Is Using Ultimate(Global.nanoBot)));
        "let ult line play out"
        Wait(1.5, Ignore Condition);
        Teleport(Global.nanoBot, Multiply(Up, 10000));
        "start facing the same way as the genji to make future nanos more consistent"
        Start Facing(Global.nanoBot, Multiply(Facing Direction Of(Value In Array(Global.runnerData, True)), Vector(True, False, True)), 5000, To World, Direction and Turn Rate);
    }
}

rule ("sub_loadPage") {
    event {
        Subroutine;
        loadPage;
    }
    actions {
        "set a flag to prevent interference"
        Set Player Variable(Event Player, changingPage, True);
        "switch menuPage:"
        If(True);
        Skip(Value In Array(Array(91, Null, 28, 41, 69), Add(True, Index Of Array Value(Array(Null, 1, 2, 3), (Event Player).menuPage))));
        //__label_switch_2_0__:
        "case 0:
\n create menuPageTexts[0][0]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("{0} CREATE BOT {1}", Input Binding String(Button(Primary Fire)), If-Then-Else(Compare(Number of Players(Team 2), <, Count Of(Global.botHeroes)), Hero Icon String(First Of(Remove From Array(Global.botHeroes, Mapped Array(All Players(Team 2), Hero Of(Current Array Element))))), Custom String("(NONE LEFT)", Null, Null, Null)), Null), Left, False, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[0][1]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("{0} GRAB BOT", Input Binding String(Button(Secondary Fire)), Null, Null), Left, True, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[0][2]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] CHANGE BOT HERO", Input Binding String(Button(Ability 2)), Null, Null), Left, 2, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[0][3]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] REMOVE BOT", Input Binding String(Button(Ultimate)), Null, Null), Left, 3, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[0][4]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] + [{1}] REMOVE ALL BOTS", Input Binding String(Button(Ability 1)), Input Binding String(Button(Ultimate)), Null), Left, 4, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[0][5]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] PLACE RESET MARKER", Input Binding String(Button(Reload)), Null, Null), Left, 5, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[0][6]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] + [{1}] REMOVE RESET MARKER", Input Binding String(Button(Ability 1)), Input Binding String(Button(Reload)), Null), Left, 6, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[0][7]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] INCREASE PLACEMENT DISTANCE", Input Binding String(Button(Melee)), Null, Null), Left, 7, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[0][8]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] + [{1}] DECREASE PLACEMENT DISTANCE", Input Binding String(Button(Ability 1)), Input Binding String(Button(Melee)), Null), Left, 8, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        Else;
        //__label_switch_2_1__:
        "case 1:
\n create menuPageTexts[1][0]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] {1} NANOBOOST DAMAGE", Input Binding String(Button(Ultimate)), If-Then-Else(First Of((Event Player).modifierSettings), Custom String("DISABLE", Null, Null, Null), Custom String("ENABLE", Null, Null, Null)), Null), Left, False, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[1][1]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] + [{1}] {2} NANOBOOST VFX", Input Binding String(Button(Ability 1)), Input Binding String(Button(Ultimate)), If-Then-Else(Value In Array((Event Player).modifierSettings, True), Custom String("DISABLE", Null, Null, Null), Custom String("ENABLE", Null, Null, Null))), Left, True, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[1][2]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] {1} UNLIMITED DASHES", Input Binding String(Button(Ability 2)), If-Then-Else(Value In Array((Event Player).modifierSettings, 2), Custom String("DISABLE", Null, Null, Null), Custom String("ENABLE", Null, Null, Null)), Null), Left, 2, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[1][3]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] {1} INSTAKILL", Input Binding String(Button(Melee)), If-Then-Else(Value In Array((Event Player).modifierSettings, 3), Custom String("DISABLE", Null, Null, Null), Custom String("ENABLE", Null, Null, Null)), Null), Left, 3, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        Else;
        //__label_switch_2_2__:
        "case 2:
\n create menuPageTexts[2][0]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("CURRENT SPAWNING MODE: {0}{1}", Value In Array(Array(Custom String("DEFAULT", Null, Null, Null), Custom String("RING", Null, Null, Null), Custom String("PRESET POINTS", Null, Null, Null)), Global.spawningMode), If-Then-Else(Compare(Global.spawningMode, !=, 1), Custom String(" ([{0}] TO SWITCH TO RING)", Input Binding String(Button(Reload)), Null, Null), Custom String("", Null, Null, Null)), Null), Left, False, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[2][1]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("{0} PLACE RING", Input Binding String(Button(Primary Fire)), Null, Null), Left, True, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[2][2]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("{0} REMOVE RING", Input Binding String(Button(Secondary Fire)), Null, Null), Left, 2, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[2][3]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] INCREASE RING RADIUS", Input Binding String(Button(Ultimate)), Null, Null), Left, 3, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[2][4]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] + [{1}] DECREASE RING RADIUS", Input Binding String(Button(Ability 1)), Input Binding String(Button(Ultimate)), Null), Left, 4, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[2][5]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] INCREASE RING HEIGHT", Input Binding String(Button(Ability 2)), Null, Null), Left, 5, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[2][6]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] + [{1}] DECREASE RING HEIGHT", Input Binding String(Button(Ability 1)), Input Binding String(Button(Ability 2)), Null), Left, 6, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[2][7]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] RESHUFFLE BOTS / SET SPAWN MODE", Input Binding String(Button(Reload)), Null, Null), Left, 7, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[2][8]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] {1} RESPAWN AT NEAREST WALKABLE POSITION", Input Binding String(Button(Melee)), If-Then-Else(Global.respawnAtNearestWalkable, Custom String("DISABLE", Null, Null, Null), Custom String("ENABLE", Null, Null, Null)), Null), Left, 8, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        Else;
        //__label_switch_2_3__:
        "case 3:
\n create menuPageTexts[3][0]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("CURRENT SPAWNING MODE: {0}{1}", Value In Array(Array(Custom String("DEFAULT", Null, Null, Null), Custom String("RING", Null, Null, Null), Custom String("PRESET POINTS", Null, Null, Null)), Global.spawningMode), If-Then-Else(Compare(Global.spawningMode, !=, 2), Custom String(" ([{0}] TO SWITCH TO PRESET POINTS)", Input Binding String(Button(Reload)), Null, Null), Custom String("", Null, Null, Null)), Null), Left, False, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[3][1]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("{0} PLACE SPAWN POINT", Input Binding String(Button(Primary Fire)), Null, Null), Left, True, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[3][2]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("{0} REMOVE SPAWN POINT", Input Binding String(Button(Secondary Fire)), Null, Null), Left, 2, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[3][3]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] REMOVE ALL SPAWN POINTS", Input Binding String(Button(Ultimate)), Null, Null), Left, 3, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[3][4]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] INCREASE SPAWN VARIANCE (CURRENTLY {1})", Input Binding String(Button(Ability 2)), Global.presetPointVariance, Null), Left, 4, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[3][5]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] + [{1}] DECREASE SPAWN VARIANCE", Input Binding String(Button(Ability 1)), Input Binding String(Button(Ability 2)), Null), Left, 5, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        "create menuPageTexts[3][6]"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("[{0}] RESHUFFLE BOTS / SET SPAWN MODE", Input Binding String(Button(Reload)), Null, Null), Left, 6, White, White, White, Visible To and String, Default Visibility);
        Modify Player Variable(Event Player, menuPageTextIDs, Append To Array, Last Text ID);
        Wait(False, Ignore Condition);
        Else;
        //__label_switch_2_default__:
        End;
        "clear flag"
        Set Player Variable(Event Player, changingPage, False);
    }
}

rule ("sub_unloadPage") {
    event {
        Subroutine;
        unloadPage;
    }
    actions {
        "set a flag to prevent interference"
        Set Player Variable(Event Player, changingPage, True);
        "go from last text to first"
        For Player Variable(Event Player, pageTextIndex, Subtract(Count Of((Event Player).menuPageTextIDs), True), -1, -1);
            "destroy text"
            Destroy HUD Text(Value In Array((Event Player).menuPageTextIDs, (Event Player).pageTextIndex));
            Modify Player Variable(Event Player, menuPageTextIDs, Remove From Array By Index, (Event Player).pageTextIndex);
            "if editing"
            If((Event Player).isEditing);
                "wait for a tick to make an animation"
                Wait(False, Ignore Condition);
            End;
        End;
        "clear flag"
        Set Player Variable(Event Player, changingPage, False);
    }
}

rule ("sub_setBotPositions") {
    event {
        Subroutine;
        setBotPositions;
    }
    actions {
        "currents spawning mode is ring spawning"
        If(Compare(Global.spawningMode, ==, 1));
            "foreach bot"
            For Global Variable(botLoopIndex, 0, Number of Players(Team 2), True);
                "store relevant bot to make referncing them easier"
                Set Global Variable(bot, Value In Array(All Players(Team 2), Global.botLoopIndex));
                "random point in a circle the size of the spawn ring"
                Set Player Variable(Global.bot, randomSpawnData, Multiply(Multiply(Direction From Angles(Random Real(0, 360), 0), Square Root(Random Real(0, 1))), Global.spawnRingRadius));
                "raycast from top of ring to bottom to find ground"
                Set Player Variable(Global.bot, randomSpawnData, Ray Cast Hit Position(Add(Add(Global.spawnRingPos, Multiply(Up, Subtract(30, Global.spawnRingHeight))), (Global.bot).randomSpawnData), Add(Add(Global.spawnRingPos, Multiply(Up, Global.spawnRingHeight)), (Global.bot).randomSpawnData), Empty Array, Empty Array, False));
                "teleport to nearest walkable position if it's enabled, otherwise use the raw raycast value"
                Teleport(Global.bot, If-Then-Else(Global.respawnAtNearestWalkable, Nearest Walkable Position((Global.bot).randomSpawnData), (Global.bot).randomSpawnData));
            End;
        "current spawning mode is preset points"
        Else If(Compare(Global.spawningMode, ==, 2));
            "there's enough spawn points for each dummy"
            If(Compare(Count Of(Global.spawnPointPositions), >=, Number of Players(Team 2)));
                "choose randomly from the spawn ponts"
                Set Global Variable(chosenSpawnPointPositions, Array Slice(Randomized Array(Global.spawnPointPositions), False, Number of Players(Team 2)));
                "foreach bot"
                For Global Variable(botLoopIndex, 0, Number of Players(Team 2), True);
                    "store relevant bot to make referencing them easier"
                    Set Global Variable(bot, Value In Array(All Players(Team 2), Global.botLoopIndex));
                    "store an offset from the point's position for random variance"
                    Set Player Variable(Global.bot, randomSpawnData, Multiply(Multiply(Direction From Angles(Random Real(0, 360), 0), Square Root(Random Real(0, 1))), Global.presetPointVariance));
                    "teleport to a raycast from the point to the point + its offset to avoid clipping into walls"
                    Teleport(Value In Array(All Players(Team 2), Global.botLoopIndex), Subtract(Ray Cast Hit Position(Add(Value In Array(Global.chosenSpawnPointPositions, Global.botLoopIndex), Multiply(Up, 0.1)), Add(Add(Value In Array(Global.chosenSpawnPointPositions, Global.botLoopIndex), (Global.bot).randomSpawnData), Multiply(Normalize((Global.bot).randomSpawnData), 0.5)), Empty Array, Empty Array, False), Multiply(Normalize((Global.bot).randomSpawnData), 0.5)));
                End;
    }
}

disabled rule ("----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------") {
    event {
        Ongoing - Global;
    }
}

rule ("==================================================SETUP / GENERAL==================================================") {
    event {
        Ongoing - Global;
    }
}

rule ("Global setup") {
    event {
        Ongoing - Global;
    }
    actions {
        Pause Match Time;
        Set Match Time(False);
        Set Objective Description(All Players(All Teams), Custom String("KILL {0} BOTS", Number of Living Players(Team 2), Null, Null), Visible To and String);
        Set Global Variable(spawnRingRadius, 10);
        Set Global Variable(spawnRingHeight, -15);
        Set Global Variable(respawnAtNearestWalkable, True);
        Set Global Variable(runnerData, Array(Null, Null));
        Set Global Variable(spawnPointPositions, Empty Array);
        Set Global Variable(spawnPointEffectIDs, Empty Array);
        "create an ana in the sky to nano"
        Create Dummy Bot(Hero(Ana), Team 1, 5, Multiply(Up, 10000), Forward);
        Create HUD Text(Filtered Array(All Players(Team 1), (Current Array Element).isEditing), Null, Null, Custom String(" \n\n\n\n\n[{0}] LEAVE EDIT MODE", Input Binding String(Button(Interact)), Null, Null), Left, -10, White, White, Yellow, Visible To and String, Default Visibility);
        Create HUD Text(Filtered Array(All Players(Team 1), And(And((Current Array Element).isEditing, Compare((Current Array Element).menuPage, ==, Null)), Not(Number of Players(Team 2)))), Null, Null, Custom String(" \n\n\n\n\n\n\n\n\n\n\n\n\n{0} CREATE BOT", Input Binding String(Button(Primary Fire)), Null, Null), Top, 10, White, White, White, Visible To and String, Default Visibility);
        Create HUD Text(Filtered Array(All Players(Team 1), And(And((Current Array Element).isEditing, Compare((Current Array Element).menuPage, ==, 2)), Compare(Global.spawningMode, !=, 1))), Null, Null, Custom String(" \n\n\n\n\n\n\n\n\n\n\n\n\n{0} PLACE RING", Input Binding String(Button(Primary Fire)), Null, Null), Top, 10, White, White, White, Visible To and String, Default Visibility);
        Create HUD Text(Filtered Array(All Players(Team 1), And((Current Array Element).isEditing, Compare((Current Array Element).menuPage, ==, 3))), Null, Null, Custom String(" \n\n\n\n\n\n\n\n\n\n\n\n\n{0}", If-Then-Else(Count Of(Global.spawnPointPositions), If-Then-Else(Compare(Global.spawningMode, !=, 2), Custom String("[{0}] CHANGE TO PRESET POINTS SPAWNING", Input Binding String(Button(Reload)), Null, Null), Custom String("", Null, Null, Null)), Custom String("{0} PLACE SPAWN POINT", Input Binding String(Button(Primary Fire)), Null, Null)), Null, Null), Top, 10, White, White, White, Visible To and String, Default Visibility);
        Create Effect(Filtered Array(All Players(Team 1), And((Current Array Element).isEditing, Compare(Global.spawningMode, ==, 1))), Light Shaft, Red, Add(Global.spawnRingPos, Multiply(Up, Global.spawnRingHeight)), Add(Global.spawnRingRadius, True), Visible To Position and Radius);
        Create HUD Text(Filtered Array(All Players(All Teams), (Current Array Element).isEditing), Null, Custom String("{0} GrandeurHammers.com/discord", Ability Icon String(Hero(Torbjörn), Button(Ability 2)), Null, Null), Null, Right, -1000, White, Orange, White, Visible To, Visible Always);
    }
}

rule ("Player Setup") {
    event {
        Ongoing - Each Player;
        Team 1;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
    }
    actions {
        "IDs for the text on each menu page"
        Set Player Variable(Event Player, menuPageTextIDs, Empty Array);
        "booleans for the modifiers"
        Set Player Variable(Event Player, modifierSettings, Array(True, True, False, False));
        "the distance from the camera at which multiple things are placed"
        Set Player Variable(Event Player, placementDistance, 16);
        "show page number, page name, and controls for navigating pages"
        Create HUD Text(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Null, Null, Custom String("PAGE {0} - {1}\n[{2}", Add((Event Player).menuPage, True), Value In Array(Array(Custom String("GENERAL", Null, Null, Null), Custom String("MODIFIERS", Null, Null, Null), Custom String("RING SPAWNING", Null, Null, Null), Custom String("PRESET POINTS SPAWNING", Null, Null, Null)), (Event Player).menuPage), Custom String("{0}] + {1} NEXT PAGE\n[{0}] + {2} PREVIOUS PAGE", Input Binding String(Button(Ability 1)), Input Binding String(Button(Secondary Fire)), Input Binding String(Button(Primary Fire)))), Left, -9, White, White, Orange, Visible To and String, Default Visibility);
        "show last run's time and best run time"
        Create HUD Text(If-Then-Else(Or((Event Player).isEditing, Not((Event Player).currentRunTime)), Event Player, Empty Array), Null, Null, Custom String("LAST TIME: {0}\nBEST TIME: {1}", If-Then-Else(Compare((Event Player).lastRunTime, !=, Null), (Event Player).lastRunTime, Custom String("N/A", Null, Null, Null)), If-Then-Else(Compare((Event Player).bestRunTime, !=, Null), (Event Player).bestRunTime, Custom String("N/A", Null, Null, Null)), Null), Top, 5, White, White, White, Visible To and String, Default Visibility);
        "the player is switched between these two heroes to cancel blade"
        Preload Hero(Event Player, Array(Hero(Genji), Hero(Torbjörn)));
        "deal a lot of damage if instakill is enabled"
        Start Damage Modification(All Players(Team 2), Event Player, If-Then-Else(Value In Array((Event Player).modifierSettings, 3), 10000, 100), Receivers Damagers and Damage Percent);
        Start Damage Modification(All Players(Team 2), Event Player, If-Then-Else(Value In Array((Event Player).modifierSettings, 3), 10000, 100), Receivers Damagers and Damage Percent);
        "when using blade with nano enabled, if ana isn't using ult, give same damage as nano would. works as a failsafe as well as allowing the player to disable nano VFX while keeping the damage"
        Start Damage Modification(All Players(Team 2), Event Player, If-Then-Else(And(And(Is Using Ultimate(Event Player), First Of((Event Player).modifierSettings)), Or(Not(Value In Array((Event Player).modifierSettings, True)), And(Not(Is Using Ultimate(Global.nanoBot)), First Of((Event Player).modifierSettings)))), 150, 100), Receivers Damagers and Damage Percent);
        "don't allow damage while in edit mode (it's possible to sneak in a shuriken"
        Start Damage Modification(All Players(Team 2), Event Player, If-Then-Else((Event Player).isEditing, Null, 100), Receivers Damagers and Damage Percent);
        "show where objects will be placed"
        Create Effect(If-Then-Else((Event Player).isEditing, Event Player, Empty Array), Sphere, Green, Ray Cast Hit Position((Event Player).noclipPosition, Add((Event Player).noclipPosition, Multiply(Facing Direction Of(Event Player), (Event Player).placementDistance)), All Players(All Teams), Event Player, True), 0.1, Visible To Position and Radius);
        "show where the player's reset point is"
        Create Effect(If-Then-Else(And((Event Player).isEditing, Compare((Event Player).resetPos, !=, Null)), Event Player, Empty Array), Sphere, Blue, (Event Player).resetPos, 0.25, Visible To Position and Radius);
        "show controls to manipulate the nearest bot to crosshair"
        Create In-World Text(If-Then-Else(And(And(And(And((Event Player).isEditing, Compare((Event Player).grabbedBot, ==, Null)), Not(Is Button Held(Event Player, Ability 1))), Compare((Event Player).menuPage, ==, Null)), Is True For Any(All Players(Team 2), Is In Line of Sight((Event Player).noclipPosition, Current Array Element, Barriers Do Not Block LOS))), Event Player, Empty Array), Custom String("      {0} PICK UP\n[{1}] CHANGE HERO\n     [{2}] REMOVE", Input Binding String(Button(Secondary Fire)), Input Binding String(Button(Ability 2)), Input Binding String(Button(Ultimate))), First Of(Sorted Array(Filtered Array(All Players(Team 2), Is In Line of Sight((Event Player).noclipPosition, Eye Position(Current Array Element), Barriers Do Not Block LOS)), Angle Between Vectors(Facing Direction Of(Event Player), Direction Towards((Event Player).noclipPosition, Eye Position(Current Array Element))))), True, Do Not Clip, Visible To Position and String, White, Default Visibility);
        "show how to drop a bot when one is held"
        Create In-World Text(If-Then-Else(And(And((Event Player).isEditing, Compare((Event Player).grabbedBot, !=, Null)), Not(Is Button Held(Event Player, Ability 1))), Event Player, Empty Array), Custom String("{0} DROP", Input Binding String(Button(Primary Fire)), Null, Null), (Event Player).grabbedBot, True, Do Not Clip, Visible To Position and String, White, Default Visibility);
        "create a nameplate for other editors to see"
        Create In-World Text(If-Then-Else((Event Player).isEditing, Filtered Array(Remove From Array(All Players(Team 1), Event Player), (Current Array Element).isEditing), Empty Array), Event Player, (Event Player).noclipPosition, True, Clip Against Surfaces, Visible To Position and String, White, Default Visibility);
        "show other editors where player is looking"
        Create Beam Effect(If-Then-Else((Event Player).isEditing, Filtered Array(Remove From Array(All Players(Team 1), Event Player), (Current Array Element).isEditing), Empty Array), Bad Beam, (Event Player).noclipPosition, Ray Cast Hit Position((Event Player).noclipPosition, Add((Event Player).noclipPosition, Multiply(Facing Direction Of(Event Player), (Event Player).placementDistance)), Empty Array, Empty Array, True), Green, Visible To Position and Radius);
        "show how to remove a preset point"
        Create In-World Text(If-Then-Else(And(And(And(And((Event Player).isEditing, Not(Is Button Held(Event Player, Ability 1))), Compare((Event Player).menuPage, ==, 3)), Compare(Global.spawningMode, ==, 2)), Compare(Count Of(Global.spawnPointPositions), >, False)), Event Player, Empty Array), Custom String("{0} REMOVE", Input Binding String(Button(Secondary Fire)), Null, Null), First Of(Sorted Array(Filtered Array(Global.spawnPointPositions, Is In Line of Sight((Event Player).noclipPosition, Current Array Element, Barriers Do Not Block LOS)), Angle Between Vectors(Facing Direction Of(Event Player), Direction Towards((Event Player).noclipPosition, Current Array Element)))), True, Do Not Clip, Visible To Position and String, White, Default Visibility);
    }
}

rule ("Player spawned setup") {
    event {
        Ongoing - Each Player;
        Team 1;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        Has Spawned(Event Player) == True;
    }
    actions {
        Wait(0.128, Abort When False);
        "enter noclip on spawn TODO unless preset spawns are setup"
        Set Player Variable(Event Player, isEditing, True);
    }
}

rule ("Bot setup") {
    event {
        Ongoing - Each Player;
        Team 2;
        All;
    }
    conditions {
        Has Spawned(Event Player) == True;
    }
    actions {
        "start facing towards player's camera"
        Start Facing(Event Player, Vector Towards(Eye Position(Event Player), If-Then-Else((Value In Array(Global.runnerData, True)).isEditing, (Value In Array(Global.runnerData, True)).noclipPosition, Eye Position(Value In Array(Global.runnerData, True)))), 10000, To World, Direction and Turn Rate);
        Disable Built-In Game Mode Respawning(Event Player);
        "just in case disable respawn doesn't work"
        Set Respawn Max Time(Event Player, 9999);
    }
}

rule ("Ana bot setup") {
    event {
        Ongoing - Each Player;
        Team 1;
        Ana;
    }
    conditions {
        Is Dummy Bot(Event Player) == True;
    }
    actions {
        Set Global Variable(nanoBot, Event Player);
        Teleport(Event Player, Multiply(Up, 10000));
        "make ana a genie who magically gives nano while out of sight"
        Set Invisible(Event Player, All);
        "don't collide with players"
        Set Status(Event Player, Null, Phased Out, 9999);
        "falling can mess up nano"
        Set Gravity(Event Player, False);
        "face the same direction as genji, but disregard vertical component (because looking up/down can get werid)"
        Start Facing(Event Player, Multiply(Facing Direction Of(Value In Array(Global.runnerData, True)), Vector(True, False, True)), 5000, To World, Direction and Turn Rate);
    }
}

rule ("Set match time to time elapsed") {
    event {
        Ongoing - Global;
    }
    actions {
        Wait(True, Ignore Condition);
        Set Match Time(Add(Match Time, True));
        Loop;
    }
}

rule ("Give ult") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        Has Spawned(Event Player) == True;
        Is Using Ultimate(Event Player) == False;
        Ultimate Charge Percent(Event Player) < 100;
        (Event Player).isEditing == False;
    }
    actions {
        Set Ultimate Charge(Event Player, 100);
        Wait(False, Ignore Condition);
        Loop If Condition Is True;
    }
}

rule ("Repeatedly nano player while blading") {
    event {
        Ongoing - Each Player;
        Team 1;
        Genji;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        First Of((Event Player).modifierSettings) == True;
        Value In Array((Event Player).modifierSettings, True) == True;
        (Event Player).isEditing == False;
        Is Using Ultimate(Event Player) == True;
    }
    actions {
        "make sure bots aren't resetting"
        If(Compare(Number of Living Players(Team 2), >, False));
            Call Subroutine(giveNano);
            "nano duration + casting time"
            Wait(6.5, Abort When False);
        End;
        Loop If Condition Is True;
    }
}

rule ("Update currentRunner when a valid runner exists") {
    event {
        Ongoing - Global;
    }
    conditions {
        "no runner is set"
        Value In Array(Global.runnerData, True) == Null;
        "there's a valid runner"
        Number of Heroes(Hero(Genji), Team 1) > Null;
    }
    actions {
        "update runner"
        Set Global Variable At Index(runnerData, False, Modulo(Add(Index Of Array Value(Sorted Array(Players On Hero(Hero(Genji), Team 1), Slot Of(Current Array Element)), Value In Array(Global.runnerData, True)), True), Number of Heroes(Hero(Genji), Team 1)));
        Set Global Variable At Index(runnerData, True, Value In Array(Sorted Array(Players On Hero(Hero(Genji), Team 1), Slot Of(Current Array Element)), First Of(Global.runnerData)));
        Wait(False, Ignore Condition);
        Loop If Condition Is True;
    }
}

rule ("Update currentRunner when the current runner doesn't exist") {
    event {
        Ongoing - Global;
    }
    conditions {
        Entity Exists(Value In Array(Global.runnerData, True)) == False;
    }
    actions {
        "allow previous rule to pick up a new runner"
        Set Global Variable At Index(runnerData, True, Null);
    }
}

rule ("When not the current runner") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        Has Spawned(Event Player) == True;
        Value In Array(Global.runnerData, True) != Null;
        Value In Array(Global.runnerData, True) != Event Player;
    }
    actions {
        "force player to spectate when they're not the current runner"
        Set Player Variable(Event Player, isEditing, True);
    }
}

rule ("When current runner") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        Has Spawned(Event Player) == True;
        Value In Array(Global.runnerData, True) == Event Player;
        (Event Player).isChangingBot == False;
    }
    actions {
        "force player to drop out of edit mode and teleport to their reset point if it exists"
        Set Player Variable(Event Player, isEditing, False);
    }
}

rule ("Toggle edit mode") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        Is Button Held(Event Player, Interact) == True;
        "only allow the current runner to toggle edit"
        Value In Array(Global.runnerData, True) == Event Player;
    }
    actions {
        While((Event Player).changingPage);
            "wait until not changing page as this can mess up the page's texts"
            Wait(False, Ignore Condition);
        End;
        "toggle edit"
        Set Player Variable(Event Player, isEditing, Not((Event Player).isEditing));
        "prevent spamming"
        Wait(0.25, Ignore Condition);
    }
}

rule ("Enable edit mode") {
    event {
        Ongoing - Each Player;
        Team 1;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
    }
    actions {
        Start Rule(loadPage, Do Nothing);
        Stop Chasing Player Variable(Event Player, currentRunTime);
        Set Player Variable(Event Player, currentRunTime, Null);
        "cancel blade and give cooldowns back"
        Start Forcing Player To Be Hero(Event Player, Hero(Torbjörn));
        Start Forcing Player To Be Hero(Event Player, Hero(Genji));
        Stop Forcing Player To Be Hero(Event Player);
        "start noclipping from current position"
        Set Player Variable(Event Player, noclipPosition, Eye Position(Event Player));
        "disable controls"
        Set Ability 1 Enabled(Event Player, False);
        Set Ability 2 Enabled(Event Player, False);
        Set Primary Fire Enabled(Event Player, False);
        Set Secondary Fire Enabled(Event Player, False);
        Set Ultimate Ability Enabled(Event Player, False);
        Set Melee Enabled(Event Player, False);
        Set Jump Enabled(Event Player, False);
        "don't physically move"
        Set Move Speed(Event Player, False);
        "don't fall"
        Set Gravity(Event Player, False);
        "resurrect and heal any bots that are dead so they can be edited"
        Resurrect(All Players(Team 2));
        "make a camera from the noclip position and copy the player's facing direction"
        Start Camera(Event Player, (Event Player).noclipPosition, Add((Event Player).noclipPosition, Facing Direction Of(Event Player)), 128);
        "take into account throttle, facing direction, jump, and crouch inputs to make a decent noclip  # chase the noclip's position"
        Chase Player Variable At Rate(Event Player, noclipPosition, Add((Event Player).noclipPosition, Multiply(Add(Add(Multiply(Facing Direction Of(Event Player), Z Component Of(Throttle Of(Event Player))), World Vector Of(Multiply(Throttle Of(Event Player), Vector(True, False, False)), Event Player, Rotation)), Multiply(Up, Subtract(Is Button Held(Event Player, Jump), Is Button Held(Event Player, Crouch)))), 100)), 14, Destination and Rate);
        "wait for a bit so the player doesn't see where they are teleported to"
        Wait(0.032, Ignore Condition);
        "go to the sky"
        Teleport(Event Player, Multiply(Up, 10000));
    }
}

rule ("Disable edit mode") {
    event {
        Ongoing - Each Player;
        Team 1;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        (Event Player).isEditing == False;
    }
    actions {
        Start Rule(unloadPage, Do Nothing);
        "reset to general page"
        Set Player Variable(Event Player, menuPage, Null);
        "save some server load"
        Stop Chasing Player Variable(Event Player, noclipPosition);
        "subtract player's height from noclipPosition so that the camera is teleported to where the noclip camera was"
        Teleport(Event Player, Subtract((Event Player).noclipPosition, Subtract(Eye Position(Event Player), Position Of(Event Player))));
        "return values to normal"
        Set Gravity(Event Player, 100);
        Set Move Speed(Event Player, 100);
        "enable controls"
        Set Ability 1 Enabled(Event Player, True);
        Set Ability 2 Enabled(Event Player, True);
        Set Primary Fire Enabled(Event Player, True);
        Set Secondary Fire Enabled(Event Player, True);
        Set Ultimate Ability Enabled(Event Player, True);
        Set Melee Enabled(Event Player, True);
        Set Jump Enabled(Event Player, True);
        Set Ultimate Charge(Event Player, 100);
        "player is back in world, can use native player camera"
        Stop Camera(Event Player);
        "cancel momentum"
        Apply Impulse(Event Player, Multiply(Velocity Of(Event Player), -1), Speed Of(Event Player), To World, Incorporate Contrary Motion);
        "if player was moving a bot"
        If(Compare((Event Player).grabbedBot, !=, Null));
            "stop grabbing bot"
            Set Player Variable(Event Player, grabbedBot, Null);
        End;
        "player has a reset position set"
        If(Compare((Event Player).resetPos, !=, Null));
            "teleport to it"
            Teleport(Event Player, (Event Player).resetPos);
            "any dummy is in LoS"
            If(Is True For Any(All Players(Team 2), Is In Line of Sight(Add((Event Player).resetPos, Subtract(Eye Position(Event Player), Position Of(Event Player))), Eye Position(Current Array Element), Barriers Do Not Block LOS)));
                "face towards dummy"
                Set Facing(Event Player, Multiply(Direction Towards((Event Player).resetPos, Sorted Array(Filtered Array(All Players(Team 2), Is In Line of Sight(Add((Event Player).resetPos, Subtract(Eye Position(Event Player), Position Of(Event Player))), Eye Position(Current Array Element), Barriers Do Not Block LOS)), First Of(Distance Between((Event Player).resetPos, Position Of(Current Array Element))))), Vector(True, 0.5, True)), To World);
            "ring spawning"
            Else If(Compare(Global.spawningMode, ==, 1));
                "face towards the center of the ring"
                Set Facing(Event Player, Multiply(Direction Towards((Event Player).resetPos, Global.spawnRingPos), Vector(True, False, True)), To World);
            "none in LoS and not in ring spawning"
            Else;
                "face towards the nearest dummy"
                Set Facing(Event Player, Multiply(Direction Towards((Event Player).resetPos, First Of(Sorted Array(All Players(Team 2), Distance Between((Event Player).resetPos, Position Of(Current Array Element))))), Vector(True, 0.5, True)), To World);
    }
}

rule ("=================================================GAMEMODE LOGIC=================================================") {
    event {
        Ongoing - Global;
    }
}

rule ("Start timer") {
    event {
        Player Dealt Damage;
        All;
        Genji;
    }
    conditions {
        (Event Player).currentRunTime == Null;
    }
    actions {
        "TODO: base this on leaving a certain radius of reset point if in multiplayer"
        Chase Player Variable At Rate(Event Player, currentRunTime, 9999, True, None);
    }
}

rule ("All bots dead - global") {
    event {
        Ongoing - Global;
    }
    conditions {
        Number of Players(Team 2) > Null;
        Number of Living Players(Team 2) == Null;
    }
    actions {
        Wait(0.25, Ignore Condition);
        Call Subroutine(setBotPositions);
        Wait(0.25, Ignore Condition);
        Resurrect(All Players(Team 2));
        "update runner"
        Set Global Variable At Index(runnerData, False, Modulo(Add(Index Of Array Value(Sorted Array(Players On Hero(Hero(Genji), Team 1), Slot Of(Current Array Element)), Value In Array(Global.runnerData, True)), True), Number of Heroes(Hero(Genji), Team 1)));
        Set Global Variable At Index(runnerData, True, Value In Array(Sorted Array(Players On Hero(Hero(Genji), Team 1), Slot Of(Current Array Element)), First Of(Global.runnerData)));
    }
}

rule ("All bots dead - player") {
    event {
        Ongoing - Each Player;
        Team 1;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        Number of Players(Team 2) > Null;
        Number of Living Players(Team 2) == Null;
    }
    actions {
        "event player is current runner"
        If(Compare(Value In Array(Global.runnerData, True), ==, Event Player));
            "run is over, stop chasing run time"
            Stop Chasing Player Variable(Event Player, currentRunTime);
            "record this run time"
            Set Player Variable(Event Player, lastRunTime, (Event Player).currentRunTime);
            Wait(False, Ignore Condition);
            "player has no best time or this is better"
            If(Or(Compare((Event Player).currentRunTime, <, (Event Player).bestRunTime), Not((Event Player).bestRunTime)));
                "update bestRunTime"
                Set Player Variable(Event Player, bestRunTime, (Event Player).currentRunTime);
                "show new PB"
                Small Message(Event Player, Custom String("NEW PERSONAL BEST TIME: {0}", (Event Player).bestRunTime, Null, Null));
            "not a PB"
            Else;
                "show time"
                Small Message(Event Player, Custom String("TIME: {0}", (Event Player).lastRunTime, Null, Null));
            End;
            "reset time for next run"
            Set Player Variable(Event Player, currentRunTime, Null);
        End;
        "is in singleplayer"
        If(Compare(Number of Heroes(Hero(Genji), Team 1), <, 2));
            Wait(0.5, Ignore Condition);
            "has a reset point set"
            If(Compare((Event Player).resetPos, !=, Null));
                "not editing currently"
                If(Not((Event Player).isEditing));
                    "go to reset point"
                    Teleport(Event Player, (Event Player).resetPos);
                    "cancel ult and reset cooldowns"
                    Start Forcing Player To Be Hero(Event Player, Hero(Torbjörn));
                    Start Forcing Player To Be Hero(Event Player, Hero(Genji));
                    Stop Forcing Player To Be Hero(Event Player);
                    "any bot is in LoS"
                    If(Is True For Any(All Players(Team 2), Is In Line of Sight(Add((Event Player).resetPos, Subtract(Eye Position(Event Player), Position Of(Event Player))), Eye Position(Current Array Element), Barriers Do Not Block LOS)));
                        "face towards that bot"
                        Set Facing(Event Player, Multiply(Direction Towards((Event Player).resetPos, Sorted Array(Filtered Array(All Players(Team 2), Is In Line of Sight(Add((Event Player).resetPos, Subtract(Eye Position(Event Player), Position Of(Event Player))), Eye Position(Current Array Element), Barriers Do Not Block LOS)), First Of(Distance Between((Event Player).resetPos, Position Of(Current Array Element))))), Vector(True, 0.5, True)), To World);
                    "current spawning mode is ring spawning"
                    Else If(Compare(Global.spawningMode, ==, 1));
                        "face towards center of ring"
                        Set Facing(Event Player, Multiply(Direction Towards((Event Player).resetPos, Global.spawnRingPos), Vector(True, False, True)), To World);
                    "no bot in LoS and not using ring spawning"
                    Else;
                        "face towards closest bot"
                        Set Facing(Event Player, Multiply(Direction Towards((Event Player).resetPos, First Of(Sorted Array(All Players(Team 2), Distance Between((Event Player).resetPos, Position Of(Current Array Element))))), Vector(True, 0.5, True)), To World);
                    End;
                End;
            "no reset point"
            Else;
                "start editing"
                Set Player Variable(Event Player, isEditing, True);
    }
}

rule ("Give dash back when infinite dash is enabled") {
    event {
        Ongoing - Each Player;
        Team 1;
        Genji;
    }
    conditions {
        Value In Array((Event Player).modifierSettings, 2) == True;
        Is Using Ability 1(Event Player) == False;
    }
    actions {
        Set Ability Cooldown(Event Player, Button(Ability 1), False);
    }
}

rule ("====================================================MENU PAGES====================================================") {
    event {
        Ongoing - Global;
    }
}

rule ("Change menu page") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        Is Button Held(Event Player, Ability 1) == True;
        Or(Is Button Held(Event Player, Primary Fire), Is Button Held(Event Player, Secondary Fire)) == True;
        (Event Player).changingPage == False;
    }
    actions {
        "store which buttons were held when conditions became true for later use, as unloadPage has waits"
        Set Player Variable(Event Player, buttonsHeld, Array(Is Button Held(Event Player, Primary Fire), Is Button Held(Event Player, Secondary Fire)));
        Call Subroutine(unloadPage);
        "holding primary and not secondary"
        If(And(First Of((Event Player).buttonsHeld), Not(Value In Array((Event Player).buttonsHeld, True))));
            "not on first page"
            If(Compare((Event Player).menuPage, >, False));
                Modify Player Variable(Event Player, menuPage, Subtract, True);
            "on first page"
            Else;
                "go to last page"
                Set Player Variable(Event Player, menuPage, 3);
                "drop bot if holding one"
                Set Player Variable(Event Player, grabbedBot, Null);
            End;
        "holding secondary and not primary"
        Else If(Not(First Of((Event Player).buttonsHeld)));
            "on first page"
            If(Compare((Event Player).menuPage, ==, Null));
                "drop bot if holding one"
                Set Player Variable(Event Player, grabbedBot, Null);
            End;
            "do math to figure out where to go"
            Set Player Variable(Event Player, menuPage, Modulo(Add((Event Player).menuPage, True), 4));
        End;
        Call Subroutine(loadPage);
    }
}

rule ("                                                                                                  /// GENERAL PAGE ///") {
    event {
        Ongoing - Global;
    }
}

rule ("Create bot or drop if currently holding one") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == Null;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Primary Fire) == True;
    }
    actions {
        "already have a bot grabbed"
        If(Compare((Event Player).grabbedBot, !=, Null));
            "stop grabbing bot"
            Set Player Variable(Event Player, grabbedBot, Null);
            Set Player Variable(All Players(Team 1), lastRunTime, Null);
            Set Player Variable(All Players(Team 1), bestRunTime, Null);
        "still some heroes to create"
        Else If(Compare(Number of Players(Team 2), <, Count Of(Global.botHeroes)));
            "create the first bot in botHeroes that isn't already in the game"
            Create Dummy Bot(First Of(Remove From Array(Global.botHeroes, Mapped Array(All Players(Team 2), Hero Of(Current Array Element)))), Team 2, -1, Ray Cast Hit Position((Event Player).noclipPosition, Add((Event Player).noclipPosition, Multiply(Facing Direction Of(Event Player), (Event Player).placementDistance)), All Players(All Teams), Event Player, True), Null);
            "grab the newly created bot"
            Set Player Variable(Event Player, grabbedBot, Last Created Entity);
            Set Player Variable(All Players(Team 1), lastRunTime, Null);
            Set Player Variable(All Players(Team 1), bestRunTime, Null);
        "all bots have been created"
        Else;
            Small Message(Event Player, Custom String("NO MORE BOTS LEFT TO CREATE", Null, Null, Null));
            "prevent spamming"
            Wait(0.25, Ignore Condition);
            Abort;
        End;
        "loop timer"
        Wait(0.2, Abort When False);
        "if still holding primary"
        If(Is Button Held(Event Player, Primary Fire));
            "stop grabbing bot"
            Set Player Variable(Event Player, grabbedBot, Null);
            Set Player Variable(All Players(Team 1), lastRunTime, Null);
            Set Player Variable(All Players(Team 1), bestRunTime, Null);
            "allow another rule to register grabbedBot becoming null"
            Wait(False, Ignore Condition);
        End;
        "still more bots to make"
        If(Compare(Number of Players(Team 2), <, Count Of(Global.botHeroes)));
            Loop If Condition Is True;
    }
}

rule ("Detect grab") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == Null;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Secondary Fire) == True;
        "not currently holding a bot"
        (Event Player).grabbedBot == Null;
    }
    actions {
        "any bot is in LoS"
        If(Is True For Any(All Players(Team 2), Is In Line of Sight((Event Player).noclipPosition, Eye Position(Current Array Element), Barriers Do Not Block LOS)));
            "grab the closest bot in LoS to the reticle"
            Set Player Variable(Event Player, grabbedBot, First Of(Sorted Array(Filtered Array(All Players(Team 2), Is In Line of Sight((Event Player).noclipPosition, Eye Position(Current Array Element), Barriers Do Not Block LOS)), Angle Between Vectors(Facing Direction Of(Event Player), Direction Towards((Event Player).noclipPosition, Eye Position(Current Array Element))))));
            Set Player Variable(All Players(Team 1), lastRunTime, Null);
            Set Player Variable(All Players(Team 1), bestRunTime, Null);
        "no bot in LoS"
        Else;
            Small Message(Event Player, Custom String("NO BOT IN LOS", Null, Null, Null));
    }
}

rule ("Grab") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == Null;
        (Event Player).grabbedBot != Null;
    }
    actions {
        "make the playermodel stand on the ground if near it"
        Set Gravity((Event Player).grabbedBot, 10000);
        "force the bot to where the player is aiming"
        Start Forcing Player Position((Event Player).grabbedBot, Ray Cast Hit Position((Event Player).noclipPosition, Add((Event Player).noclipPosition, Multiply(Facing Direction Of(Event Player), (Event Player).placementDistance)), Empty Array, Empty Array, True), True);
    }
}

rule ("Change bot hero") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == Null;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Ability 2) == True;
        (Event Player).grabbedBot == Null;
        (Event Player).isChangingBot == False;
    }
    actions {
        "any bot is in LoS"
        If(Is True For Any(All Players(Team 2), Is In Line of Sight((Event Player).noclipPosition, Eye Position(Current Array Element), Barriers Do Not Block LOS)));
            "set a flag to disable some other rules which interfere otherwise"
            Set Player Variable(Event Player, isChangingBot, True);
            "for some reason the game thinks the player should be moving when they're not spawned in"
            Stop Chasing Player Variable(Event Player, noclipPosition);
            "store the facing direction for a seamless transition back"
            Set Player Variable(Event Player, prevFacing, Facing Direction Of(Event Player));
            "target the bot closest to the reticle in LoS"
            Set Player Variable(Event Player, targetedDummy, First Of(Sorted Array(Filtered Array(All Players(Team 2), Is In Line of Sight((Event Player).noclipPosition, Eye Position(Current Array Element), Barriers Do Not Block LOS)), Angle Between Vectors(Facing Direction Of(Event Player), Direction Towards((Event Player).noclipPosition, Eye Position(Current Array Element))))));
            "change the ana bot to show the player the hero of the bot they're changing"
            Start Forcing Player To Be Hero(Global.nanoBot, Hero Of((Event Player).targetedDummy));
            "force player into hero select"
            Set Player Allowed Heroes(Event Player, If-Then-Else(Compare(Hero Of((Event Player).targetedDummy), !=, Hero(Genji)), Hero Of((Event Player).targetedDummy), Random Value In Array(Remove From Array(Remove From Array(All Heroes, Global.botHeroes), Hero(Genji)))));
            "get kicked out of hero select immediately if this is too short"
            Wait(0.25, Ignore Condition);
            "set the available heros to (all heroes) - (already used heroes) + (the bot's current hero) to avoid duplicate heroes"
            Set Player Allowed Heroes(Event Player, Append To Array(Remove From Array(All Heroes, Global.botHeroes), Hero Of((Event Player).targetedDummy)));
            While(Not(Has Spawned(Event Player)));
                "wait until the player has picked a hero"
                Wait(False, Ignore Condition);
            End;
            "update botHeroes to contain the newly chosen hero"
            Set Global Variable At Index(botHeroes, Slot Of((Event Player).targetedDummy), Hero Of(Event Player));
            "create a new dummy to replace the old one so that they run bot setup again"
            Create Dummy Bot(Hero Of(Event Player), Team 2, Slot Of((Event Player).targetedDummy), Position Of((Event Player).targetedDummy), Null);
            "force player back to genji"
            Start Forcing Player To Be Hero(Event Player, Hero(Genji));
            "disallow picking other heroes"
            Set Player Allowed Heroes(Event Player, Hero(Genji));
            "must stop forcing to let the player get kicked back to hero select in the future"
            Stop Forcing Player To Be Hero(Event Player);
            "set facing to the direction they were facing when triggering rule"
            Set Facing(Event Player, (Event Player).prevFacing, To World);
            Set Player Variable(All Players(Team 1), lastRunTime, Null);
            Set Player Variable(All Players(Team 1), bestRunTime, Null);
            "clear flag"
            Set Player Variable(Event Player, isChangingBot, False);
            "force nano bot back to ana"
            Start Forcing Player To Be Hero(Global.nanoBot, Hero(Ana));
            "take into account throttle, facing direction, jump, and crouch inputs to make a decent noclip  # start running noclip movement logic again"
            Chase Player Variable At Rate(Event Player, noclipPosition, Add((Event Player).noclipPosition, Multiply(Add(Add(Multiply(Facing Direction Of(Event Player), Z Component Of(Throttle Of(Event Player))), World Vector Of(Multiply(Throttle Of(Event Player), Vector(True, False, False)), Event Player, Rotation)), Multiply(Up, Subtract(Is Button Held(Event Player, Jump), Is Button Held(Event Player, Crouch)))), 100)), 14, Destination and Rate);
        "no bot in LoS"
        Else;
            Small Message(Event Player, Custom String("NO BOT IN LOS", Null, Null, Null));
    }
}

rule ("Delete bot") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == Null;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Ultimate) == True;
        (Event Player).grabbedBot == Null;
    }
    actions {
        "any bot is in LoS"
        If(Is True For Any(All Players(Team 2), Is In Line of Sight((Event Player).noclipPosition, Eye Position(Current Array Element), Barriers Do Not Block LOS)));
            "target the bot closest to the reticle in LoS"
            Set Player Variable(Event Player, targetedDummy, First Of(Sorted Array(Filtered Array(All Players(Team 2), Is In Line of Sight((Event Player).noclipPosition, Eye Position(Current Array Element), Barriers Do Not Block LOS)), Angle Between Vectors(Facing Direction Of(Event Player), Direction Towards((Event Player).noclipPosition, Eye Position(Current Array Element))))));
            "show the player which bot they removed"
            Small Message(Event Player, Custom String("REMOVED {0}", Hero Icon String(Hero Of((Event Player).targetedDummy)), Null, Null));
            "destroy the bot"
            Destroy Dummy Bot(Team 2, Slot Of((Event Player).targetedDummy));
            Set Player Variable(All Players(Team 1), lastRunTime, Null);
            Set Player Variable(All Players(Team 1), bestRunTime, Null);
        "no bot in LoS"
        Else;
            Small Message(Event Player, Custom String("NO BOT IN LOS", Null, Null, Null));
    }
}

rule ("Delete all bots") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == Null;
        Number of Players(Team 2) > Null;
        Is Button Held(Event Player, Ability 1) == True;
        Is Button Held(Event Player, Ultimate) == True;
    }
    actions {
        For Global Variable(i, 0, Number of Players(Team 2), True);
            "destroy each dummy"
            Destroy Dummy Bot(Team 2, Value In Array(Mapped Array(All Players(Team 2), Slot Of(Current Array Element)), Global.i));
        End;
        Small Message(Event Player, Custom String("REMOVED ALL BOTS", Null, Null, Null));
        Set Player Variable(All Players(Team 1), lastRunTime, Null);
        Set Player Variable(All Players(Team 1), bestRunTime, Null);
    }
}

rule ("Place reset marker") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == Null;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Reload) == True;
    }
    actions {
        "place the reset point at the player's green sphere cursor"
        Set Player Variable(Event Player, resetPos, Ray Cast Hit Position((Event Player).noclipPosition, Add((Event Player).noclipPosition, Multiply(Facing Direction Of(Event Player), (Event Player).placementDistance)), Empty Array, Empty Array, True));
        Small Message(Event Player, Custom String("PLACED RESET MARKER", Null, Null, Null));
    }
}

rule ("Remove reset marker") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == Null;
        Is Button Held(Event Player, Ability 1) == True;
        Is Button Held(Event Player, Reload) == True;
        "reset point already exists"
        (Event Player).resetPos != Null;
    }
    actions {
        Set Player Variable(Event Player, resetPos, Null);
        Small Message(Event Player, Custom String("REMOVED RESET MARKER", Null, Null, Null));
    }
}

rule ("Change placement distance") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == Null;
        Is Button Held(Event Player, Melee) == True;
    }
    actions {
        "chase the player's placement distance down to 4 if they're holding shift, otherwise up to 64"
        Chase Player Variable At Rate(Event Player, placementDistance, If-Then-Else(Is Button Held(Event Player, Ability 1), 4, 64), 24, Destination and Rate);
    }
}

rule ("Stop changing placement distance") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        Or(Or(Not((Event Player).isEditing), Not(Is Button Held(Event Player, Melee))), Compare((Event Player).menuPage, !=, Null)) == True;
    }
    actions {
        Stop Chasing Player Variable(Event Player, placementDistance);
    }
}

rule ("                                                                                                 /// MODIFIERS PAGE ///") {
    event {
        Ongoing - Global;
    }
}

rule ("Toggle nanoboost damage modifier") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 1;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Ultimate) == True;
    }
    actions {
        Set Player Variable At Index(Event Player, modifierSettings, False, Not(First Of((Event Player).modifierSettings)));
    }
}

rule ("Toggle nanoboost VFX modifier") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 1;
        Is Button Held(Event Player, Ability 1) == True;
        Is Button Held(Event Player, Ultimate) == True;
    }
    actions {
        Set Player Variable At Index(Event Player, modifierSettings, True, Not(Value In Array((Event Player).modifierSettings, True)));
    }
}

rule ("Toggle unlimited dashes modifier") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 1;
        Is Button Held(Event Player, Ability 2) == True;
    }
    actions {
        Set Player Variable At Index(Event Player, modifierSettings, 2, Not(Value In Array((Event Player).modifierSettings, 2)));
    }
}

rule ("Toggle instakill modifier") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 1;
        Is Button Held(Event Player, Melee) == True;
    }
    actions {
        Set Player Variable At Index(Event Player, modifierSettings, 3, Not(Value In Array((Event Player).modifierSettings, 3)));
    }
}

rule ("                                                                                             /// RING SPAWNING PAGE ///") {
    event {
        Ongoing - Global;
    }
}

rule ("Place spawn ring") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 2;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Primary Fire) == True;
    }
    actions {
        "set spawn mode to ring spawning"
        Set Global Variable(spawningMode, 1);
        "currently bugged and resets to the init value of -15"
        Set Global Variable(spawnRingHeight, Min(Max(Global.spawnRingHeight, -30), False));
        "init the variable"
        Set Global Variable(spawnRingPos, Ray Cast Hit Position((Event Player).noclipPosition, Add((Event Player).noclipPosition, Multiply(Facing Direction Of(Event Player), 100)), Empty Array, Empty Array, True));
        "chase the variable"
        Chase Global Variable At Rate(spawnRingPos, Ray Cast Hit Position((Event Player).noclipPosition, Add((Event Player).noclipPosition, Multiply(Facing Direction Of(Event Player), 100)), Empty Array, Empty Array, True), 10000, Destination and Rate);
        Set Player Variable(All Players(Team 1), lastRunTime, Null);
        Set Player Variable(All Players(Team 1), bestRunTime, Null);
    }
}

rule ("Stop changing spawn ring position") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        Or(Or(Not((Event Player).isEditing), Compare((Event Player).menuPage, !=, 2)), Not(And(Is Button Held(Event Player, Primary Fire), Not(Is Button Held(Event Player, Ability 1))))) == True;
    }
    actions {
        Stop Chasing Global Variable(spawnRingPos);
        "update the bot positions to fit in the new ring"
        Call Subroutine(setBotPositions);
    }
}

rule ("Remove spawn ring") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 2;
        Global.spawningMode == 1;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Secondary Fire) == True;
    }
    actions {
        "set spawn mode to default"
        Set Global Variable(spawningMode, Null);
        Set Player Variable(All Players(Team 1), lastRunTime, Null);
        Set Player Variable(All Players(Team 1), bestRunTime, Null);
    }
}

rule ("Change spawn ring radius") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 2;
        Is Button Held(Event Player, Ultimate) == True;
    }
    actions {
        "chase the ring radius to 1 if player is holding shift, otherwise up to 30"
        Chase Global Variable At Rate(spawnRingRadius, If-Then-Else(Is Button Held(Event Player, Ability 1), 1, 30), 5, Destination and Rate);
        Set Player Variable(All Players(Team 1), lastRunTime, Null);
        Set Player Variable(All Players(Team 1), bestRunTime, Null);
    }
}

rule ("Stop changing spawn ring radius") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        Or(Or(Not((Event Player).isEditing), Compare((Event Player).menuPage, !=, 2)), Not(Is Button Held(Event Player, Ultimate))) == True;
    }
    actions {
        Stop Chasing Global Variable(spawnRingRadius);
        Call Subroutine(setBotPositions);
    }
}

rule ("Change spawn ring height") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 2;
        Is Button Held(Event Player, Ability 2) == True;
    }
    actions {
        "chase the ring height to -60 if player is holding shift, otherwise up to 30"
        Chase Global Variable At Rate(spawnRingHeight, If-Then-Else(Is Button Held(Event Player, Ability 1), -60, 30), 10, Destination and Rate);
        Set Player Variable(All Players(Team 1), lastRunTime, Null);
        Set Player Variable(All Players(Team 1), bestRunTime, Null);
    }
}

rule ("Stop changing spawn ring height") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        Or(Or(Not((Event Player).isEditing), Compare((Event Player).menuPage, !=, 2)), Not(Is Button Held(Event Player, Ability 2))) == True;
    }
    actions {
        Stop Chasing Global Variable(spawnRingHeight);
        Call Subroutine(setBotPositions);
    }
}

rule ("Toggle respawn at nearest walkable") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing != False;
        (Event Player).menuPage == 2;
        Is Button Held(Event Player, Melee) == True;
    }
    actions {
        Set Global Variable(respawnAtNearestWalkable, Not(Global.respawnAtNearestWalkable));
        "nearestWalkable just got enabled and using ring spawning"
        If(And(Global.respawnAtNearestWalkable, Compare(Global.spawningMode, ==, 1)));
            "foreach bot"
            For Global Variable(botLoopIndex, 0, Number of Players(Team 2), True);
                Set Global Variable(bot, Value In Array(All Players(Team 2), Global.botLoopIndex));
                "teleport to nearest walkable and move down to force standing animation rather than floating"
                Teleport(Global.bot, Add(Nearest Walkable Position(Position Of(Global.bot)), Multiply(Down, 0.2)));
            End;
    }
}

rule ("                                                                                    /// PRESET POINTS SPAWNING PAGE ///") {
    event {
        Ongoing - Global;
    }
}

rule ("Place spawn point") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing != False;
        (Event Player).menuPage == 3;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Primary Fire) == True;
    }
    actions {
        "need some effects for other objects"
        If(Compare(Count Of(Global.spawnPointPositions), >=, 100));
            Small Message(Event Player, Custom String("Too many spawn points", Null, Null, Null));
            Abort;
        End;
        "set the spawn mode to preset position spawning"
        Set Global Variable(spawningMode, 2);
        "append the player's green sphere cursor position to the spawn point positions"
        Modify Global Variable(spawnPointPositions, Append To Array, Ray Cast Hit Position((Event Player).noclipPosition, Add((Event Player).noclipPosition, Multiply(Facing Direction Of(Event Player), (Event Player).placementDistance)), Empty Array, Empty Array, True));
        "make a new effect"
        Create Effect(Filtered Array(All Players(Team 1), And((Current Array Element).isEditing, Compare(Global.spawningMode, ==, 2))), Sphere, Red, Last Of(Global.spawnPointPositions), 0.5, Visible To);
        "track the effect"
        Modify Global Variable(spawnPointEffectIDs, Append To Array, Last Created Entity);
        Set Player Variable(All Players(Team 1), lastRunTime, Null);
        Set Player Variable(All Players(Team 1), bestRunTime, Null);
    }
}

rule ("Remove spawn point") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing != False;
        (Event Player).menuPage == 3;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Secondary Fire) == True;
    }
    actions {
        "store the index of nearest spawn point position"
        Set Player Variable(Event Player, i, Index Of Array Value(Global.spawnPointPositions, First Of(Sorted Array(Global.spawnPointPositions, Angle Between Vectors(Facing Direction Of(Event Player), Direction Towards((Event Player).noclipPosition, Current Array Element))))));
        "destroy corresponding effect"
        Destroy Effect(Value In Array(Global.spawnPointEffectIDs, (Event Player).i));
        "update arrays"
        Modify Global Variable(spawnPointPositions, Remove From Array By Index, (Event Player).i);
        Modify Global Variable(spawnPointEffectIDs, Remove From Array By Index, (Event Player).i);
        Set Player Variable(All Players(Team 1), lastRunTime, Null);
        Set Player Variable(All Players(Team 1), bestRunTime, Null);
    }
}

rule ("Remove all spawn points") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 3;
        Is Button Held(Event Player, Ability 1) == False;
        Is Button Held(Event Player, Ultimate) == True;
    }
    actions {
        "if current spawning mode is preset point spawning"
        If(Compare(Global.spawningMode, ==, 2));
            "set to default spawning"
            Set Global Variable(spawningMode, Null);
        End;
        "foreach effect"
        For Global Variable(i, 0, Count Of(Global.spawnPointEffectIDs), True);
            "destroy effect"
            Destroy Effect(Value In Array(Global.spawnPointEffectIDs, Global.i));
        End;
        "wipe arrays"
        Set Global Variable(spawnPointPositions, Empty Array);
        Set Global Variable(spawnPointEffectIDs, Empty Array);
        Set Player Variable(All Players(Team 1), lastRunTime, Null);
        Set Player Variable(All Players(Team 1), bestRunTime, Null);
    }
}

rule ("Change preset point variance") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        (Event Player).menuPage == 3;
        Is Button Held(Event Player, Ability 2) == True;
    }
    actions {
        "chase the variance to 0 if player is holding shift, otherwise up to 10"
        Chase Global Variable At Rate(presetPointVariance, If-Then-Else(Is Button Held(Event Player, Ability 1), Null, 10), 2.5, Destination and Rate);
        Set Player Variable(All Players(Team 1), lastRunTime, Null);
        Set Player Variable(All Players(Team 1), bestRunTime, Null);
    }
}

rule ("Stop changing preset point variance") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == False;
        Or(Or(Not((Event Player).isEditing), Compare((Event Player).menuPage, !=, 3)), Not(Is Button Held(Event Player, Ability 2))) == True;
    }
    actions {
        Stop Chasing Global Variable(presetPointVariance);
    }
}

rule ("Reshuffle bots") {
    event {
        Ongoing - Each Player;
        All;
        All;
    }
    conditions {
        (Event Player).isEditing == True;
        Array Contains(Array(2, 3), (Event Player).menuPage) == True;
        Is Button Held(Event Player, Reload) == True;
    }
    actions {
        "switch menuPage:"
        If(True);
        Skip(Value In Array(Array(14, Null, 5), Add(True, Index Of Array Value(Array(2, 3), (Event Player).menuPage))));
        //__label_switch_3_0__:
        "case RINGSPAWNING:
\n no spawn ring has been created"
        If(Not(Global.spawnRingPos));
            "make a new one on green sphere cursor"
            Set Global Variable(spawnRingPos, Ray Cast Hit Position((Event Player).noclipPosition, Add((Event Player).noclipPosition, Multiply(Facing Direction Of(Event Player), (Event Player).placementDistance)), Empty Array, Empty Array, True));
        End;
        "set spawn mode to ring spawning"
        Set Global Variable(spawningMode, 1);
        Else;
        //__label_switch_3_1__:
        "case PRESETSPAWNING:
\n set spawn mode to preset points spawning"
        Set Global Variable(spawningMode, 2);
        "no points have been created"
        If(Not(Count Of(Global.spawnPointPositions)));
            "foreach enemy dummy"
            For Global Variable(i, 0, Number of Players(Team 2), True);
                Modify Global Variable(spawnPointPositions, Append To Array, Position Of(Value In Array(Sorted Array(All Players(Team 2), Slot Of(Current Array Element)), Global.i)));
                "create spawn point effect"
                Create Effect(Filtered Array(All Players(Team 1), And((Current Array Element).isEditing, Compare(Global.spawningMode, ==, 2))), Sphere, Red, Last Of(Global.spawnPointPositions), 0.5, Visible To);
                Modify Global Variable(spawnPointEffectIDs, Append To Array, Last Created Entity);
            End;
        End;
        Else;
        //__label_switch_3_default__:
        End;
        Wait(False, Ignore Condition);
        Call Subroutine(setBotPositions);
    }
}

rule ("===================================================BOT HANDLING===================================================") {
    event {
        Ongoing - Global;
    }
}

rule ("Set high gravity if near floor") {
    event {
        Ongoing - Each Player;
        Team 2;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == True;
        Altitude Of(Event Player) < 0.05;
        "no genji is grabbing the bot"
        Is True For Any(Players On Hero(Hero(Genji), Team 1), Compare((Current Array Element).grabbedBot, ==, Event Player)) == False;
    }
    actions {
        "this makes the playermodel properly stand on the ground"
        Set Gravity(Event Player, 10000);
    }
}

rule ("Set low gravity if not near floor") {
    event {
        Ongoing - Each Player;
        Team 2;
        All;
    }
    conditions {
        Is Dummy Bot(Event Player) == True;
        Altitude Of(Event Player) >= 0.05;
        "no genji is grabbing the bot"
        Is True For Any(Players On Hero(Hero(Genji), Team 1), Compare((Current Array Element).grabbedBot, ==, Event Player)) == False;
    }
    actions {
        "float"
        Set Gravity(Event Player, False);
    }
}

rule ("Stop bots floating") {
    event {
        Ongoing - Each Player;
        Team 2;
        All;
    }
    conditions {
        Speed Of(Event Player) > 0.01;
        Is In Air(Event Player) == True;
        "not being grabbed by any genji"
        Is True For Any(Players On Hero(Hero(Genji), Team 1), Compare((Current Array Element).grabbedBot, ==, Event Player)) == False;
    }
    actions {
        "stop all momentum (works better than what is used to cancel genji's momentum upon exiting noclip)"
        Apply Impulse(Event Player, Up, 0.001, To World, Cancel Contrary Motion);
        Apply Impulse(Event Player, Down, 0.001, To World, Cancel Contrary Motion);
        Apply Impulse(Event Player, Backward, 0.001, To World, Cancel Contrary Motion);
        Apply Impulse(Event Player, Forward, 0.001, To World, Cancel Contrary Motion);
        Apply Impulse(Event Player, Right, 0.001, To World, Cancel Contrary Motion);
        Apply Impulse(Event Player, Left, 0.001, To World, Cancel Contrary Motion);
        Wait(False, Ignore Condition);
        Loop If Condition Is True;
    }
}

rule ("Stop forcing bot position") {
    event {
        Ongoing - Each Player;
        Team 2;
        All;
    }
    conditions {
        "not being grabbed by any genji"
        Is True For Any(Players On Hero(Hero(Genji), Team 1), Compare((Current Array Element).grabbedBot, ==, Event Player)) == False;
    }
    actions {
        Start Forcing Player Position(Event Player, Position Of(Event Player), False);
        Wait(0.032, Ignore Condition);
        Stop Forcing Player Position(Event Player);
    }
}

