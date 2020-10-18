#!include "lobbySettings.opy"
 
#Global variables

# What heroes the bots are spawned as
globalvar botHeroes                 0
# The bot used to nano the player
globalvar nanoBot                   1
# Keeps track of the player who is running
globalvar runnerData                2
# What mode the bots are being spawned in
globalvar spawningMode              3
# Position of the spawning ring
globalvar spawnRingPos              4
# Radius of the spawning ring
globalvar spawnRingRadius           5
# Height of the spawning ring
globalvar spawnRingHeight           6
# Whether to respawn bots at nearest walkable position in ring spawning mode
globalvar respawnAtNearestWalkable  7
# Local variable used for simplification
globalvar bot                       9
# Control variable for affecting multiple bots
globalvar botLoopIndex              10
# Positions of points for preset points spawning
globalvar spawnPointPositions       11
# The points which were randomly chosen to put bots at
globalvar chosenSpawnPointPositions 12
# Effect IDs of spawn points
globalvar spawnPointEffectIDs       13
# How much a bot can move away from a preset point
globalvar presetPointVariance       14

globalvar i                         8
 
 
#Player variables

# Whether the player is editing
playervar isEditing             0
# The position of the player in noclip
playervar noclipPosition        1
# The bot the player is grabbing
playervar grabbedBot            2
# Local variable used for simplification
playervar targetedDummy         3
# The player's reset point position
playervar resetPos              4
# How far away bots and other objects are placed/held
playervar placementDistance     5
# The page the player is on
playervar menuPage              6
# IDs of the HUD texts used to make menu pages
playervar menuPageTextIDs       7
# Control variable for creating menu pages
playervar pageTextIndex         9
# Array of modifier states
playervar modifierSettings      10
# The amount of time the player has spent on their current run
playervar currentRunTime        11
# The amount of time the player spent on their last run
playervar lastRunTime           12
# The lowest amount of time a player has spent on a run
playervar bestRunTime           13
# Whether the player is changing a menu page
playervar changingPage          14
# Misc data to give variance to bot spawning positions
playervar randomSpawnData       15
# Local variable to determine which direction to change menu pages
playervar buttonsHeld           16
# Whether the player is changing a bot's hero
playervar isChangingBot         17
# Local variable to seamlessly restore the player's facing direction
playervar prevFacing             18

playervar i                     8


#Subroutines

# Give the calling player nanoboost
subroutine giveNano         0
# Load the calling player's current page
subroutine loadPage         1
# Unload the calling player's current page
subroutine unloadPage       2
# Perform logic to position bots
subroutine setBotPositions  3
  
#!include "../values.opy"
#!include "../functions.opy"
#!include "../scripts.opy"
#!include "definitions.opy"
#!include "menuPages.opy"
#!include "modifierArrayDefs.opy"


enum MenuPage:
    GENERAL = 0,
    MODIFIERS,
    RINGSPAWNING,
    PRESETSPAWNING

enum SpawnMode:
    DEFAULT = 0,
    RING,
    PRESETS


#!define DEBUG true
rule "debug":
    @Event eachPlayer
    @Condition DEBUG

    #debugText(eventPlayer, eventPlayer.i)


rule "​                                                                 Made by Provoxin - Contact me on Discord @Provoxin#5368":
    @Delimiter


rule "/// Default bot heroes":
    botHeroes = []
    botHeroes.append(Hero.ANA)
    botHeroes.append(Hero.ASHE)
    botHeroes.append(Hero.BAPTISTE)
    botHeroes.append(Hero.ECHO)
    botHeroes.append(Hero.SIGMA)
    botHeroes.append(Hero.ZARYA)


rule "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------":
    @Delimiter
    @Disabled


def giveNano():
    @Name "sub_giveNano"
    nanoBot.teleport(raycast(eventPlayer.getPosition(), eventPlayer.getPosition() + normalize(eventPlayer.getFacingDirection() * vect(1, 0, 1)) * -2, getPlayers(Team.1), [], false).getHitPosition())  # teleport behind genji
    nanoBot.startFacing(directionTowards(nanoBot.getEyePosition(), (eventPlayer.getPosition() + eventPlayer.getEyePosition()) / 2), 5000, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)  # face towards the center of genji
    nanoBot.forceButtonPress(Button.ULTIMATE)  # press nano
    wait(0.145)  # wait for casting time
    __loopIf__(not nanoBot.isUsingUltimate())  # if didn't cast, retry
    wait(1.5)  # let ult line play out
    nanoBot.teleport(Vector.UP * 10000)
    nanoBot.startFacing(currentRunner.getFacingDirection() * vect(1, 0, 1), 5000, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)  # start facing the same way as the genji to make future nanos more consistent


def loadPage():
    @Name "sub_loadPage"

    eventPlayer.changingPage = true  # set a flag to prevent interference
    switch eventPlayer.menuPage:  # switch menuPage:
        case 0:
            # case 0:
            createPage(0, 9)
            break
        case 1:
            # case 1:
            createPage(1, 4)
            break
        case 2:
            # case 2:
            createPage(2, 9)
            break
        case 3:
            # case 3:
            createPage(3, 7)
            break
    eventPlayer.changingPage = false  # clear flag


def unloadPage():
    @Name "sub_unloadPage"

    eventPlayer.changingPage = true  # set a flag to prevent interference
    for eventPlayer.pageTextIndex in range(len(eventPlayer.menuPageTextIDs)-1, -1, -1):  # go from last text to first
        destroyHudText(eventPlayer.menuPageTextIDs[eventPlayer.pageTextIndex])  # destroy text
        del eventPlayer.menuPageTextIDs[eventPlayer.pageTextIndex]  # delete corresponding ID
        if eventPlayer.isEditing:  # if editing
            wait()  # wait for a tick to make an animation
    eventPlayer.changingPage = false  # clear flag


def setBotPositions():
    @Name "sub_setBotPositions"

    if spawningMode == SpawnMode.RING:  # currents spawning mode is ring spawning
        for botLoopIndex in range(getNumberOfPlayers(Team.2)):  # foreach bot
            bot = getPlayers(Team.2)[botLoopIndex]  # store relevant bot to make referncing them easier
            bot.randomSpawnData = angleToDirection(random.uniform(0, 360), 0) * sqrt(random.uniform(0, 1)) * spawnRingRadius  # random point in a circle the size of the spawn ring
            # raycast from top of ring to bottom to find ground
            bot.randomSpawnData = raycast(spawnRingPos + (Vector.UP * (30 - spawnRingHeight)) + bot.randomSpawnData, spawnRingPos + (Vector.UP * spawnRingHeight) + bot.randomSpawnData, [], [], false).getHitPosition()
            # teleport to nearest walkable position if it's enabled, otherwise use the raw raycast value
            bot.teleport(nearestWalkablePosition(bot.randomSpawnData) if respawnAtNearestWalkable else bot.randomSpawnData)
    elif spawningMode == SpawnMode.PRESETS:  # current spawning mode is preset points
        if len(spawnPointPositions) >= getNumberOfPlayers(Team.2):  # there's enough spawn points for each dummy
            chosenSpawnPointPositions = random.shuffle(spawnPointPositions).slice(0, getNumberOfPlayers(Team.2))  # choose randomly from the spawn ponts
            for botLoopIndex in range(getNumberOfPlayers(Team.2)):  # foreach bot
                bot = getPlayers(Team.2)[botLoopIndex]  # store relevant bot to make referencing them easier
                # store an offset from the point's position for random variance
                bot.randomSpawnData = angleToDirection(random.uniform(0, 360), 0) * sqrt(random.uniform(0, 1)) * presetPointVariance
                # teleport to a raycast from the point to the point + its offset to avoid clipping into walls
                getPlayers(Team.2)[botLoopIndex].teleport(raycast(chosenSpawnPointPositions[botLoopIndex] + Vector.UP * 0.1, chosenSpawnPointPositions[botLoopIndex] + bot.randomSpawnData + (normalize(bot.randomSpawnData) * 0.5), [], [], false).getHitPosition() - (normalize(bot.randomSpawnData) * 0.5))


rule "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------":
    @Delimiter
    @Disabled


rule "==================================================SETUP / GENERAL==================================================":
    @Delimiter


rule "Global setup":
    @Event global

    pauseMatchTime()
    setMatchTime(0)
    setObjectiveDescription(getAllPlayers(), "KILL {0} BOTS".format(getNumberOfLivingPlayers(Team.2)), HudReeval.VISIBILITY_AND_STRING)
    spawnRingRadius = 10
    spawnRingHeight = -15
    respawnAtNearestWalkable = true
    runnerData = [0, null]
    spawnPointPositions = []
    spawnPointEffectIDs = []
    createDummy(Hero.ANA, Team.1, 5, Vector.UP * 10000, Vector.FORWARD)  # create an ana in the sky to nano
    /*
    hudHeader([player for player in getPlayers(Team.1) if player.isEditing], "NEXT BOT: {0}".format(heroIcon(botHeroes.exclude([player.getCurrentHero() for player in getPlayers(Team.2)])[0]) if getNumberOfPlayers(Team.2) < len(botHeroes) else "NONE"), HudPosition.LEFT, -10, Color.GREEN, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)  # show which bot will be created next
    #hudSubtext([player for player in getPlayers(Team.1) if player.isEditing and player.menuPage == MenuPage.GENERAL], "{0} CREATE BOT {1}\n{2}".format(buttonString(Button.PRIMARY_FIRE), heroIcon(botHeroes.exclude([player.getCurrentHero() for player in getPlayers(Team.2)])[0]) if getNumberOfPlayers(Team.2) < len(botHeroes) else "(NONE LEFT)", "{0} GRAB BOT\n{1}".format(buttonString(Button.SECONDARY_FIRE), "[{0}] REMOVE BOT\n[{1}] + [{0}] REMOVE ALL BOTS\n{2}".format(buttonString(Button.ABILITY_2), buttonString(Button.ABILITY_1), "[{0}] PLACE RESET MARKER\n[{1}] + [{0}] REMOVE RESET MARKER\n{2}".format(buttonString(Button.RELOAD), buttonString(Button.ABILITY_1), "[{0}] INCREASE PLACEMENT DISTANCE\n[{1}] + [{0}] DECREASE PLACEMENT DISTANCE".format(buttonString(Button.MELEE), buttonString(Button.ABILITY_1)))))), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)  # show keybinds
    */
    hudSubtext([player for player in getPlayers(Team.1) if player.isEditing], " \n\n\n\n\n[{0}] LEAVE EDIT MODE".format(buttonString(Button.INTERACT)), HudPosition.LEFT, -10, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.1) if player.isEditing and player.menuPage == MenuPage.GENERAL and not getNumberOfPlayers(Team.2)], " \n\n\n\n\n\n\n\n\n\n\n\n\n{0} CREATE BOT".format(buttonString(Button.PRIMARY_FIRE)), HudPosition.TOP, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.1) if player.isEditing and player.menuPage == MenuPage.RINGSPAWNING and spawningMode != SpawnMode.RING], " \n\n\n\n\n\n\n\n\n\n\n\n\n{0} PLACE RING".format(buttonString(Button.PRIMARY_FIRE)), HudPosition.TOP, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.1) if player.isEditing and player.menuPage == MenuPage.PRESETSPAWNING/* and not len(spawnPointPositions)*/], " \n\n\n\n\n\n\n\n\n\n\n\n\n{0}".format("{0} PLACE SPAWN POINT".format(buttonString(Button.PRIMARY_FIRE)) if not len(spawnPointPositions) else "[{0}] CHANGE TO PRESET POINTS SPAWNING".format(buttonString(Button.RELOAD)) if spawningMode != SpawnMode.PRESETS else ""), HudPosition.TOP, 10, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    createEffect([player for player in getPlayers(Team.1) if player.isEditing and spawningMode == SpawnMode.RING], Effect.LIGHT_SHAFT, Color.RED, spawnRingPos + (Vector.UP * spawnRingHeight), spawnRingRadius + 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createGHWatermark([player for player in getAllPlayers() if player.isEditing])

 
rule "Player Setup":
    @Event eachPlayer
    @Team  1
    @Condition eventPlayer.isDummy() == false

    eventPlayer.menuPageTextIDs = []  # IDs for the text on each menu page
    eventPlayer.modifierSettings = [true, true, false, false]  # booleans for the modifiers
    eventPlayer.placementDistance = 16  # the distance from the camera at which multiple things are placed

    # show page number, page name, and controls for navigating pages
    hudSubtext(eventPlayer if eventPlayer.isEditing else [], "PAGE {0} - {1}\n[{2}] + {3} NEXT PAGE\n[{2}] + {4} PREVIOUS PAGE".format(eventPlayer.menuPage+1, menuPageNames[eventPlayer.menuPage], buttonString(Button.ABILITY_1), buttonString(Button.SECONDARY_FIRE), buttonString(Button.PRIMARY_FIRE)), HudPosition.LEFT, -9, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    # show last run's time and best run time
    hudSubtext(eventPlayer if (eventPlayer.isEditing or not eventPlayer.currentRunTime) else [], "LAST TIME: {0}\nBEST TIME: {1}".format(eventPlayer.lastRunTime if eventPlayer.lastRunTime != null else "N/A", eventPlayer.bestRunTime if eventPlayer.bestRunTime != null else "N/A"), HudPosition.TOP, 5, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

    # the player is switched between these two heroes to cancel blade
    eventPlayer.preloadHero([Hero.GENJI, Hero.TORBJORN])

    # deal a lot of damage if instakill is enabled
    startDamageModification(getPlayers(Team.2), eventPlayer, 10000 if eventPlayer.instakillEnabled else 100, DamageReeval.RECEIVERS_DAMAGERS_AND_DMGPERCENT)
    startDamageModification(getPlayers(Team.2), eventPlayer, 10000 if eventPlayer.instakillEnabled else 100, DamageReeval.RECEIVERS_DAMAGERS_AND_DMGPERCENT)

    # when using blade with nano enabled, if ana isn't using ult, give same damage as nano would. works as a failsafe as well as allowing the player to disable nano VFX while keeping the damage
    startDamageModification(getPlayers(Team.2), eventPlayer, 150 if eventPlayer.isUsingUltimate() and eventPlayer.nanoEnabled and (not eventPlayer.nanoVFXEnabled or (not nanoBot.isUsingUltimate() and eventPlayer.nanoEnabled)) else 100, DamageReeval.RECEIVERS_DAMAGERS_AND_DMGPERCENT)

    # don't allow damage while in edit mode (it's possible to sneak in a shuriken
    startDamageModification(getPlayers(Team.2), eventPlayer, 0 if eventPlayer.isEditing else 100, DamageReeval.RECEIVERS_DAMAGERS_AND_DMGPERCENT)

    # show where objects will be placed
    createEffect(eventPlayer if eventPlayer.isEditing else [], Effect.SPHERE, Color.GREEN, noclipEyecast(eventPlayer, eventPlayer.placementDistance, getAllPlayers(), eventPlayer).getHitPosition(), 0.1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    # show where the player's reset point is
    createEffect(eventPlayer if (eventPlayer.isEditing and eventPlayer.resetPos != null) else [], Effect.SPHERE, Color.BLUE, eventPlayer.resetPos, 0.25, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    # show controls to manipulate the nearest bot to crosshair
    createInWorldText(eventPlayer if (eventPlayer.isEditing and eventPlayer.grabbedBot == null and not eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.menuPage == MenuPage.GENERAL and any([isInLoS(eventPlayer.noclipPosition, dummy, BarrierLos.PASS_THROUGH_BARRIERS) for dummy in getPlayers(Team.2)])) else [], "      {0} PICK UP\n[{1}] CHANGE HERO\n     [{2}] REMOVE".format(buttonString(Button.SECONDARY_FIRE), buttonString(Button.ABILITY_2), buttonString(Button.ULTIMATE)), closestToReticleNoclipLOS, 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

    # show how to drop a bot when one is held
    createInWorldText(eventPlayer if (eventPlayer.isEditing and eventPlayer.grabbedBot != null and not eventPlayer.isHoldingButton(Button.ABILITY_1)) else [], "{0} DROP".format(buttonString(Button.PRIMARY_FIRE)), eventPlayer.grabbedBot, 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

    # create a nameplate for other editors to see
    createInWorldText([player for player in getPlayers(Team.1).exclude(eventPlayer) if player.isEditing] if eventPlayer.isEditing else [], eventPlayer, eventPlayer.noclipPosition, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

    # show other editors where player is looking
    createBeam([player for player in getPlayers(Team.1).exclude(eventPlayer) if player.isEditing] if eventPlayer.isEditing else [], Beam.BAD, eventPlayer.noclipPosition, noclipEyecast(eventPlayer, eventPlayer.placementDistance, [], []).getHitPosition(), Color.GREEN, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

    # show how to remove a preset point
    createInWorldText(eventPlayer if (eventPlayer.isEditing and not eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.menuPage == MenuPage.PRESETSPAWNING and spawningMode == SpawnMode.PRESETS and len(spawnPointPositions) > 0) else [], "{0} REMOVE".format(buttonString(Button.SECONDARY_FIRE)), sorted([effect for effect in spawnPointPositions if isInLoS(eventPlayer.noclipPosition, effect, BarrierLos.PASS_THROUGH_BARRIERS)], lambda effect: angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.noclipPosition, effect)))[0], 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)


rule "Player spawned setup":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.hasSpawned() == true

    wait(ticks(8), Wait.ABORT_WHEN_FALSE)
    eventPlayer.isEditing = true  # enter noclip on spawn TODO unless preset spawns are setup


rule "Bot setup":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.hasSpawned() == true

    # start facing towards player's camera
    eventPlayer.startFacing(vectorTowards(eventPlayer.getEyePosition(), currentRunner.noclipPosition if currentRunner.isEditing else currentRunner.getEyePosition()), 10000, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
    eventPlayer.disableRespawn()
    eventPlayer.setRespawnTime(9999)  # just in case disable respawn doesn't work


rule "Ana bot setup":
    @Event eachPlayer
    @Team 1
    @Hero ana
    @Condition eventPlayer.isDummy() == true
    
    nanoBot = eventPlayer
    eventPlayer.teleport(Vector.UP * 10000)
    eventPlayer.setInvisibility(Invis.ALL)  # make ana a genie who magically gives nano while out of sight
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)  # don't collide with players
    eventPlayer.setGravity(0)  # falling can mess up nano
    # face the same direction as genji, but disregard vertical component (because looking up/down can get werid)
    eventPlayer.startFacing(currentRunner.getFacingDirection() * vect(1, 0, 1), 5000, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)


rule "Set match time to time elapsed":
    @Condition not DEBUG

    wait(1)
    incrementMatchTime(1)
    goto RULE_START


rule "Give ult":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isUsingUltimate() == false
    @Condition eventPlayer.getUltCharge() < 100
    @Condition eventPlayer.isEditing == false
    
    eventPlayer.setUltCharge(100)
    wait()
    if RULE_CONDITION: goto RULE_START


rule "Repeatedly nano player while blading":
    @Event eachPlayer
    @Team 1
    @Hero genji
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.nanoEnabled == true
    @Condition eventPlayer.nanoVFXEnabled == true
    @Condition eventPlayer.isEditing == false
    @Condition eventPlayer.isUsingUltimate() == true

    if getNumberOfLivingPlayers(Team.2) > 0:  # make sure bots aren't resetting
        giveNano()
        wait(6.5, Wait.ABORT_WHEN_FALSE)  # nano duration + casting time
    if RULE_CONDITION: goto RULE_START


rule "Update currentRunner when a valid runner exists":
    @Condition currentRunner == null  # no runner is set
    @Condition getNumberOfHeroes(Hero.GENJI, Team.1) > 0  # there's a valid runner

    # update runner
    updateRunner()
    wait()
    if RULE_CONDITION: goto RULE_START

    
rule "Update currentRunner when the current runner doesn't exist":
    @Condition entityExists(currentRunner) == false

    currentRunner = null  # allow previous rule to pick up a new runner

rule "When not the current runner":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.hasSpawned() == true
    @Condition currentRunner != null
    @Condition currentRunner != eventPlayer

    eventPlayer.isEditing = true  # force player to spectate when they're not the current runner


rule "When current runner":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.hasSpawned() == true
    @Condition currentRunner == eventPlayer
    @Condition eventPlayer.isChangingBot == false

    eventPlayer.isEditing = false  # force player to drop out of edit mode and teleport to their reset point if it exists


rule "Toggle edit mode":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition currentRunner == eventPlayer  # only allow the current runner to toggle edit

    while eventPlayer.changingPage:
        wait()  # wait until not changing page as this can mess up the page's texts
    eventPlayer.isEditing = not eventPlayer.isEditing  # toggle edit
    wait(0.25)  # prevent spamming


rule "Enable edit mode":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isEditing == true
 
    async(loadPage(), AsyncBehavior.NOOP)
    stopChasingVariable(eventPlayer.currentRunTime)
    eventPlayer.currentRunTime = 0
    eventPlayer.startForcingHero(Hero.TORBJORN)  # cancel blade and give cooldowns back
    eventPlayer.startForcingHero(Hero.GENJI)
    eventPlayer.stopForcingCurrentHero()
    eventPlayer.noclipPosition = eventPlayer.getEyePosition()  # start noclipping from current position

    # disable controls
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.setUltEnabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setJumpEnabled(false)
    
    eventPlayer.setMoveSpeed(0)  # don't physically move
    eventPlayer.setGravity(0)  # don't fall

    getPlayers(Team.2).resurrect()  # resurrect and heal any bots that are dead so they can be edited

    eventPlayer.setCamera(eventPlayer.noclipPosition, eventPlayer.noclipPosition + eventPlayer.getFacingDirection(), 128)  # make a camera from the noclip position and copy the player's facing direction
    chaseNoclip()  # chase the noclip's position
    waitTicks(2)  # wait for a bit so the player doesn't see where they are teleported to
    eventPlayer.teleport(Vector.UP * 10000)  # go to the sky

    
rule "Disable edit mode":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isDummy() == false
    @Condition eventPlayer.isEditing == false

    async(unloadPage(), AsyncBehavior.NOOP)
    eventPlayer.menuPage = MenuPage.GENERAL  # reset to general page
    stopChasingVariable(eventPlayer.noclipPosition)  # save some server load
    eventPlayer.teleport(eventPlayer.noclipPosition - getHeight(eventPlayer))  # subtract player's height from noclipPosition so that the camera is teleported to where the noclip camera was
    
    # return values to normal
    eventPlayer.setGravity(100)
    eventPlayer.setMoveSpeed(100)

    # enable controls
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.setPrimaryFireEnabled(true)
    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setUltEnabled(true)
    eventPlayer.setMeleeEnabled(true)
    eventPlayer.setJumpEnabled(true)

    eventPlayer.setUltCharge(100)

    eventPlayer.stopCamera()  # player is back in world, can use native player camera
    cancelMomentum(eventPlayer)  # cancel momentum

    if eventPlayer.grabbedBot != null:  # if player was moving a bot
        eventPlayer.grabbedBot = null  # stop grabbing bot

    if eventPlayer.resetPos != null:  # player has a reset position set
        eventPlayer.teleport(eventPlayer.resetPos)  # teleport to it
        if any([isInLoS(eventPlayer.resetPos + getHeight(eventPlayer), dummy.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) for dummy in getPlayers(Team.2)]):  # any dummy is in LoS
            # face towards dummy
            eventPlayer.setFacing(directionTowards(eventPlayer.resetPos, sorted([dummy for dummy in getPlayers(Team.2) if isInLoS(eventPlayer.resetPos + getHeight(eventPlayer), dummy.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS)], lambda dummy: distance(eventPlayer.resetPos, dummy.getPosition())[0])) * vect(1, 0.5, 1), Relativity.TO_WORLD)
        elif spawningMode == SpawnMode.RING:  # ring spawning
            # face towards the center of the ring
            eventPlayer.setFacing(directionTowards(eventPlayer.resetPos, spawnRingPos) * vect(1, 0, 1), Relativity.TO_WORLD)
        else:  # none in LoS and not in ring spawning
            # face towards the nearest dummy
            eventPlayer.setFacing(directionTowards(eventPlayer.resetPos, sorted(getPlayers(Team.2), lambda player: distance(eventPlayer.resetPos, player.getPosition()))[0]) * vect(1, 0.5, 1), Relativity.TO_WORLD)


rule "=================================================GAMEMODE LOGIC=================================================":
    @Delimiter


rule "Start timer":
    @Event playerDealtDamage
    @Hero genji
    @Condition eventPlayer.currentRunTime == 0

    chase(eventPlayer.currentRunTime, 9999, rate=1, ChaseReeval.NONE)  # TODO: base this on leaving a certain radius of reset point if in multiplayer


rule "All bots dead - global":
    @Event global
    @Condition getNumberOfPlayers(Team.2) > 0
    @Condition getNumberOfLivingPlayers(Team.2) == 0

    wait(0.25)
    setBotPositions()
    wait(0.25)
    getPlayers(Team.2).resurrect()
    # update runner
    updateRunner()

rule "All bots dead - player":
    @Event eachPlayer
    @Team 1
    @Condition eventPlayer.isDummy() == false
    @Condition getNumberOfPlayers(Team.2) > 0
    @Condition getNumberOfLivingPlayers(Team.2) == 0

    if currentRunner == eventPlayer:  # event player is current runner
        stopChasingVariable(eventPlayer.currentRunTime)  # run is over, stop chasing run time
        eventPlayer.lastRunTime = eventPlayer.currentRunTime  # record this run time
        wait()
        if eventPlayer.currentRunTime < eventPlayer.bestRunTime or not eventPlayer.bestRunTime:  # player has no best time or this is better
            eventPlayer.bestRunTime = eventPlayer.currentRunTime  # update bestRunTime
            smallMessage(eventPlayer, "NEW PERSONAL BEST TIME: {0}".format(eventPlayer.bestRunTime))  # show new PB
        else:  # not a PB
            smallMessage(eventPlayer, "TIME: {0}".format(eventPlayer.lastRunTime))  # show time
        eventPlayer.currentRunTime = 0  # reset time for next run
    if getNumberOfHeroes(Hero.GENJI, Team.1) < 2:  # is in singleplayer
        wait(0.5)
        if eventPlayer.resetPos != null:  # has a reset point set
            if not eventPlayer.isEditing:  # not editing currently
                eventPlayer.teleport(eventPlayer.resetPos)  # go to reset point
                # cancel ult and reset cooldowns
                eventPlayer.startForcingHero(Hero.TORBJORN)
                eventPlayer.startForcingHero(Hero.GENJI)
                eventPlayer.stopForcingCurrentHero()
                # any bot is in LoS
                if any([isInLoS(eventPlayer.resetPos + getHeight(eventPlayer), dummy.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) for dummy in getPlayers(Team.2)]):
                    # face towards that bot
                    eventPlayer.setFacing(directionTowards(eventPlayer.resetPos, sorted([dummy for dummy in getPlayers(Team.2) if isInLoS(eventPlayer.resetPos + getHeight(eventPlayer), dummy.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS)], lambda dummy: distance(eventPlayer.resetPos, dummy.getPosition())[0])) * vect(1, 0.5, 1), Relativity.TO_WORLD)
                elif spawningMode == SpawnMode.RING:  # current spawning mode is ring spawning
                    eventPlayer.setFacing(directionTowards(eventPlayer.resetPos, spawnRingPos) * vect(1, 0, 1), Relativity.TO_WORLD)  # face towards center of ring
                else:  # no bot in LoS and not using ring spawning
                    # face towards closest bot
                    eventPlayer.setFacing(directionTowards(eventPlayer.resetPos, sorted(getPlayers(Team.2), lambda player: distance(eventPlayer.resetPos, player.getPosition()))[0]) * vect(1, 0.5, 1), Relativity.TO_WORLD)
        else:  # no reset point
            eventPlayer.isEditing = true  # start editing
        

rule "All bots dead - bot":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isDummy() == true
    @Condition getNumberOfPlayers(Team.2) > 0
    @Condition getNumberOfLivingPlayers(Team.2) == 0

        
rule "Give dash back when infinite dash is enabled":
    @Event eachPlayer
    @Team 1
    @Hero genji
    @Condition eventPlayer.infiniteDashEnabled == true
    @Condition eventPlayer.isUsingAbility1() == false

    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
        

rule "====================================================MENU PAGES====================================================":
    @Delimiter


rule "Change menu page":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition eventPlayer.changingPage == false

    # store which buttons were held when conditions became true for later use, as unloadPage has waits
    eventPlayer.buttonsHeld = [eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)]

    unloadPage()

    if eventPlayer.buttonsHeld[0] and not eventPlayer.buttonsHeld[1]:  # holding primary and not secondary
        if eventPlayer.menuPage > 0:  # not on first page
            eventPlayer.menuPage --  # subtract 1
        else:  # on first page
            eventPlayer.menuPage = len(menuPageNames) - 1  # go to last page
            eventPlayer.grabbedBot = null  # drop bot if holding one
    elif not eventPlayer.buttonsHeld[0]:  # holding secondary and not primary
        if eventPlayer.menuPage == MenuPage.GENERAL:  # on first page
            eventPlayer.grabbedBot = null  # drop bot if holding one 
        eventPlayer.menuPage = addMod(eventPlayer.menuPage, 1, len(menuPageNames))  # do math to figure out where to go
    
    loadPage()


rule "                                                                                                  /// GENERAL PAGE ///":
    @Delimiter


rule "Create bot or drop if currently holding one":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.GENERAL
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
 
    if eventPlayer.grabbedBot != null:  # already have a bot grabbed
        eventPlayer.grabbedBot = null  # stop grabbing bot
        resetTimes(getPlayers(Team.1))
    elif getNumberOfPlayers(Team.2) < len(botHeroes):  # still some heroes to create
        # create the first bot in botHeroes that isn't already in the game
        createDummy(botHeroes.exclude([dummy.getCurrentHero() for dummy in getPlayers(Team.2)])[0], Team.2, -1, noclipEyecast(eventPlayer, eventPlayer.placementDistance, getAllPlayers(), eventPlayer).getHitPosition(), null)
        eventPlayer.grabbedBot = getLastCreatedEntity()  # grab the newly created bot
        resetTimes(getPlayers(Team.1))
    else:  # all bots have been created
        smallMessage(eventPlayer, "NO MORE BOTS LEFT TO CREATE")
        wait(0.25)  # prevent spamming
        return
    wait(0.2, Wait.ABORT_WHEN_FALSE)  # loop timer
    if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):  # if still holding primary
        eventPlayer.grabbedBot = null  # stop grabbing bot
        resetTimes(getPlayers(Team.1))
        wait()  # allow another rule to register grabbedBot becoming null
    if getNumberOfPlayers(Team.2) < len(botHeroes):  # still more bots to make
        if RULE_CONDITION: goto RULE_START


rule "Detect grab":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.GENERAL
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.grabbedBot == null  # not currently holding a bot

    if any([isInLoS(eventPlayer.noclipPosition, dummy.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) for dummy in getPlayers(Team.2)]):  # any bot is in LoS
        eventPlayer.grabbedBot = closestToReticleNoclipLOS  # grab the closest bot in LoS to the reticle
        resetTimes(getPlayers(Team.1))
    else:  # no bot in LoS
        smallMessage(eventPlayer, "NO BOT IN LOS")


rule "Grab":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.GENERAL
    @Condition eventPlayer.grabbedBot != null

    eventPlayer.grabbedBot.setGravity(10000)  # make the playermodel stand on the ground if near it
    # force the bot to where the player is aiming
    eventPlayer.grabbedBot.startForcingPosition(noclipEyecast(eventPlayer, eventPlayer.placementDistance, [], []).getHitPosition()/* + Vector.DOWN * min(1, eventPlayer.grabbedBot.getAltitude())*/, true)


rule "Change bot hero":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.GENERAL
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.grabbedBot == null
    @Condition eventPlayer.isChangingBot == false

    if any([isInLoS(eventPlayer.noclipPosition, dummy.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) for dummy in getPlayers(Team.2)]):  # any bot is in LoS
        eventPlayer.isChangingBot = true  # set a flag to disable some other rules which interfere otherwise
        stopChasingVariable(eventPlayer.noclipPosition)  # for some reason the game thinks the player should be moving when they're not spawned in
        eventPlayer.prevFacing = eventPlayer.getFacingDirection()  # store the facing direction for a seamless transition back
        eventPlayer.targetedDummy = closestToReticleNoclipLOS  # target the bot closest to the reticle in LoS
        nanoBot.startForcingHero(eventPlayer.targetedDummy.getCurrentHero())  # change the ana bot to show the player the hero of the bot they're changing
        # force player into hero select
        eventPlayer.setAllowedHeroes(eventPlayer.targetedDummy.getCurrentHero() if eventPlayer.targetedDummy.getCurrentHero() != Hero.GENJI else random.choice(getAllHeroes().exclude(botHeroes).exclude(Hero.GENJI)))
        wait(0.25)  # get kicked out of hero select immediately if this is too short
        # set the available heros to (all heroes) - (already used heroes) + (the bot's current hero) to avoid duplicate heroes
        eventPlayer.setAllowedHeroes(getAllHeroes().exclude(botHeroes).concat(eventPlayer.targetedDummy.getCurrentHero()))
        while not eventPlayer.hasSpawned():
            waitTicks(1)  # wait until the player has picked a hero
        botHeroes[eventPlayer.targetedDummy.getSlot()] = eventPlayer.getCurrentHero()  # update botHeroes to contain the newly chosen hero
        # create a new dummy to replace the old one so that they run bot setup again
        createDummy(eventPlayer.getCurrentHero(), Team.2, eventPlayer.targetedDummy.getSlot(), eventPlayer.targetedDummy.getPosition(), null)
        eventPlayer.startForcingHero(Hero.GENJI)  # force player back to genji
        eventPlayer.setAllowedHeroes(Hero.GENJI)  # disallow picking other heroes
        eventPlayer.stopForcingCurrentHero()  # must stop forcing to let the player get kicked back to hero select in the future
        eventPlayer.setFacing(eventPlayer.prevFacing, Relativity.TO_WORLD)  # set facing to the direction they were facing when triggering rule
        resetTimes(getPlayers(Team.1))
        eventPlayer.isChangingBot = false  # clear flag
        nanoBot.startForcingHero(Hero.ANA)  # force nano bot back to ana
        chaseNoclip()  # start running noclip movement logic again
    else:  # no bot in LoS
        smallMessage(eventPlayer, "NO BOT IN LOS")


rule "Delete bot":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.GENERAL
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.grabbedBot == null

    if any([isInLoS(eventPlayer.noclipPosition, dummy.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) for dummy in getPlayers(Team.2)]):  # any bot is in LoS
        eventPlayer.targetedDummy = closestToReticleNoclipLOS  # target the bot closest to the reticle in LoS
        smallMessage(eventPlayer, "REMOVED {0}".format(heroIcon(eventPlayer.targetedDummy.getCurrentHero())))  # show the player which bot they removed
        destroyDummy(Team.2, eventPlayer.targetedDummy.getSlot())  # destroy the bot
        resetTimes(getPlayers(Team.1))
    else:  # no bot in LoS
        smallMessage(eventPlayer, "NO BOT IN LOS")


rule "Delete all bots":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.GENERAL
    @Condition getNumberOfPlayers(Team.2) > 0
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

    for i in range(getNumberOfPlayers(Team.2)):
        destroyDummy(Team.2, [dummy.getSlot() for dummy in getPlayers(Team.2)][i])  # destroy each dummy
    smallMessage(eventPlayer, "REMOVED ALL BOTS")
    resetTimes(getPlayers(Team.1))


rule "Place reset marker":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.GENERAL
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true

    eventPlayer.resetPos = noclipEyecast(eventPlayer, eventPlayer.placementDistance, [], []).getHitPosition()  # place the reset point at the player's green sphere cursor
    smallMessage(eventPlayer, "PLACED RESET MARKER")


rule "Remove reset marker":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.GENERAL
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true
    @Condition eventPlayer.resetPos != null  # reset point already exists

    eventPlayer.resetPos = null
    smallMessage(eventPlayer, "REMOVED RESET MARKER")


rule "Change placement distance":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.GENERAL
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true

    # chase the player's placement distance down to 4 if they're holding shift, otherwise up to 64
    chase(eventPlayer.placementDistance, 4 if eventPlayer.isHoldingButton(Button.ABILITY_1) else 64, rate=24, ChaseReeval.DESTINATION_AND_RATE)


rule "Stop changing placement distance":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == false
    @Condition not eventPlayer.isEditing or not eventPlayer.isHoldingButton(Button.MELEE) or eventPlayer.menuPage != MenuPage.GENERAL

    stopChasingVariable(eventPlayer.placementDistance)


rule "                                                                                                 /// MODIFIERS PAGE ///":
    @Delimiter


rule "Toggle nanoboost damage modifier":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.MODIFIERS
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

    eventPlayer.nanoEnabled = not eventPlayer.nanoEnabled


rule "Toggle nanoboost VFX modifier":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.MODIFIERS
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == true
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

    eventPlayer.nanoVFXEnabled = not eventPlayer.nanoVFXEnabled


rule "Toggle unlimited dashes modifier":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.MODIFIERS
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true

    eventPlayer.infiniteDashEnabled = not eventPlayer.infiniteDashEnabled


rule "Toggle instakill modifier":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.MODIFIERS
    @Condition eventPlayer.isHoldingButton(Button.MELEE) == true

    eventPlayer.instakillEnabled = not eventPlayer.instakillEnabled


rule "                                                                                             /// RING SPAWNING PAGE ///":
    @Delimiter


rule "Place spawn ring":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.RINGSPAWNING
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true

    spawningMode = SpawnMode.RING  # set spawn mode to ring spawning
    spawnRingHeight = clamp(spawnRingHeight, -30, 0)  # currently bugged and resets to the init value of -15
    spawnRingPos = noclipEyecast(eventPlayer, 100, [], []).getHitPosition()  # init the variable
    chase(spawnRingPos, noclipEyecast(eventPlayer, 100, [], []).getHitPosition(), rate=10000, ChaseReeval.DESTINATION_AND_RATE)  # chase the variable
    resetTimes(getPlayers(Team.1))


rule "Stop changing spawn ring position":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == false
    @Condition not eventPlayer.isEditing or eventPlayer.menuPage != MenuPage.RINGSPAWNING or not (eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) and not eventPlayer.isHoldingButton(Button.ABILITY_1))
    
    stopChasingVariable(spawnRingPos)
    setBotPositions()  # update the bot positions to fit in the new ring


rule "Remove spawn ring":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.RINGSPAWNING
    @Condition spawningMode == SpawnMode.RING
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true

    spawningMode = SpawnMode.DEFAULT  # set spawn mode to default
    resetTimes(getPlayers(Team.1))


rule "Change spawn ring radius":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.RINGSPAWNING
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

    # chase the ring radius to 1 if player is holding shift, otherwise up to 30
    chase(spawnRingRadius, 1 if eventPlayer.isHoldingButton(Button.ABILITY_1) else 30, rate=5, ChaseReeval.DESTINATION_AND_RATE)
    resetTimes(getPlayers(Team.1))


rule "Stop changing spawn ring radius":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == false
    @Condition not eventPlayer.isEditing or eventPlayer.menuPage != MenuPage.RINGSPAWNING or not eventPlayer.isHoldingButton(Button.ULTIMATE)

    stopChasingVariable(spawnRingRadius)
    setBotPositions()


rule "Change spawn ring height":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.RINGSPAWNING
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true

    # chase the ring height to -60 if player is holding shift, otherwise up to 30
    chase(spawnRingHeight, -60 if eventPlayer.isHoldingButton(Button.ABILITY_1) else 30, rate=10, ChaseReeval.DESTINATION_AND_RATE)
    resetTimes(getPlayers(Team.1))


rule "Stop changing spawn ring height":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == false
    @Condition not eventPlayer.isEditing or eventPlayer.menuPage != MenuPage.RINGSPAWNING or not eventPlayer.isHoldingButton(Button.ABILITY_2)

    stopChasingVariable(spawnRingHeight)
    setBotPositions()


rule "Toggle respawn at nearest walkable":
    @Event eachPlayer
    @Condition eventPlayer.isEditing
    @Condition eventPlayer.menuPage == MenuPage.RINGSPAWNING
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    respawnAtNearestWalkable = not respawnAtNearestWalkable
    if respawnAtNearestWalkable and spawningMode == SpawnMode.RING:  # nearestWalkable just got enabled and using ring spawning
        for botLoopIndex in range(getNumberOfPlayers(Team.2)):  # foreach bot
            bot = getPlayers(Team.2)[botLoopIndex]
            bot.teleport(nearestWalkablePosition(bot.getPosition()) + Vector.DOWN * 0.2)  # teleport to nearest walkable and move down to force standing animation rather than floating



rule "                                                                                    /// PRESET POINTS SPAWNING PAGE ///":
    @Delimiter


rule "Place spawn point":
    @Event eachPlayer
    @Condition eventPlayer.isEditing
    @Condition eventPlayer.menuPage == MenuPage.PRESETSPAWNING
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true

    if len(spawnPointPositions) >= 100:  # need some effects for other objects
        smallMessage(eventPlayer, "Too many spawn points")
        return
    spawningMode = SpawnMode.PRESETS  # set the spawn mode to preset position spawning
    spawnPointPositions.append(noclipEyecast(eventPlayer, eventPlayer.placementDistance, [], []).getHitPosition())  # append the player's green sphere cursor position to the spawn point positions
    createEffect([player for player in getPlayers(Team.1) if player.isEditing and spawningMode == SpawnMode.PRESETS], Effect.SPHERE, Color.RED, spawnPointPositions.last(), 0.5, EffectReeval.VISIBILITY)  # make a new effect
    spawnPointEffectIDs.append(getLastCreatedEntity())  # track the effect
    resetTimes(getPlayers(Team.1))


rule "Remove spawn point":
    @Event eachPlayer
    @Condition eventPlayer.isEditing
    @Condition eventPlayer.menuPage == MenuPage.PRESETSPAWNING
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true

    # store the index of nearest spawn point position
    eventPlayer.i = spawnPointPositions.index(sorted(spawnPointPositions, lambda effect: angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.noclipPosition, effect)))[0])
    destroyEffect(spawnPointEffectIDs[eventPlayer.i])  # destroy corresponding effect
    # update arrays
    del spawnPointPositions[eventPlayer.i]
    del spawnPointEffectIDs[eventPlayer.i]
    resetTimes(getPlayers(Team.1))


rule "Remove all spawn points":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.PRESETSPAWNING
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) == false
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true

    if spawningMode == SpawnMode.PRESETS:  # if current spawning mode is preset point spawning
        spawningMode = SpawnMode.DEFAULT  # set to default spawning
    for i in range(len(spawnPointEffectIDs)):  # foreach effect
        destroyEffect(spawnPointEffectIDs[i])  # destroy effect
    # wipe arrays
    spawnPointPositions = []
    spawnPointEffectIDs = []
    resetTimes(getPlayers(Team.1))


rule "Change preset point variance":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage == MenuPage.PRESETSPAWNING
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true

    # chase the variance to 0 if player is holding shift, otherwise up to 10
    chase(presetPointVariance, 0 if eventPlayer.isHoldingButton(Button.ABILITY_1) else 10, rate=2.5, ChaseReeval.DESTINATION_AND_RATE)
    resetTimes(getPlayers(Team.1))


rule "Stop changing preset point variance":
    @Event eachPlayer
    @Condition eventPlayer.isDummy() == false
    @Condition not eventPlayer.isEditing or eventPlayer.menuPage != MenuPage.PRESETSPAWNING or not eventPlayer.isHoldingButton(Button.ABILITY_2)

    stopChasingVariable(presetPointVariance)
    #setBotPositions()


rule "Reshuffle bots":
    @Event eachPlayer
    @Condition eventPlayer.isEditing == true
    @Condition eventPlayer.menuPage in [MenuPage.RINGSPAWNING, MenuPage.PRESETSPAWNING] == true
    @Condition eventPlayer.isHoldingButton(Button.RELOAD) == true

    switch eventPlayer.menuPage:  # switch menuPage:
        case MenuPage.RINGSPAWNING:
            # case RINGSPAWNING:
            if not spawnRingPos:  # no spawn ring has been created
                spawnRingPos = noclipEyecast(eventPlayer, eventPlayer.placementDistance, [], []).getHitPosition()  # make a new one on green sphere cursor
            spawningMode = SpawnMode.RING  # set spawn mode to ring spawning
            break
        case MenuPage.PRESETSPAWNING:
            # case PRESETSPAWNING:
            spawningMode = SpawnMode.PRESETS  # set spawn mode to preset points spawning
            if not len(spawnPointPositions):  # no points have been created
                for i in range(getNumberOfPlayers(Team.2)):  # foreach enemy dummy
                    spawnPointPositions.append(sorted(getPlayers(Team.2), lambda dummy: dummy.getSlot())[i].getPosition())  # append dummy's position
                    # create spawn point effect
                    createEffect([player for player in getPlayers(Team.1) if player.isEditing and spawningMode == SpawnMode.PRESETS], Effect.SPHERE, Color.RED, spawnPointPositions.last(), 0.5, EffectReeval.VISIBILITY)
                    spawnPointEffectIDs.append(getLastCreatedEntity())  # track effect ID
            break

    wait()
    setBotPositions()


rule "===================================================BOT HANDLING===================================================":
    @Delimiter


rule "Set high gravity if near floor":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.getAltitude() < 0.05
    @Condition any([player.grabbedBot == eventPlayer for player in getPlayersOnHero(Hero.GENJI, Team.1)]) == false  # no genji is grabbing the bot

    eventPlayer.setGravity(10000)  # this makes the playermodel properly stand on the ground


rule "Set low gravity if not near floor":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.getAltitude() >= 0.05
    @Condition any([player.grabbedBot == eventPlayer for player in getPlayersOnHero(Hero.GENJI, Team.1)]) == false  # no genji is grabbing the bot

    eventPlayer.setGravity(0)  # float


rule "Stop bots floating":
    @Event eachPlayer
    @Team 2
    @Condition eventPlayer.getSpeed() > 0.01
    @Condition eventPlayer.isInAir() == true
    @Condition any([player.grabbedBot == eventPlayer for player in getPlayersOnHero(Hero.GENJI, Team.1)]) == false  # not being grabbed by any genji

    # stop all momentum (works better than what is used to cancel genji's momentum upon exiting noclip)
    longCancelMomentum(eventPlayer)  
    wait()
    if RULE_CONDITION: goto RULE_START


rule "Stop forcing bot position":
    @Event eachPlayer
    @Team 2
    @Condition any([player.grabbedBot == eventPlayer for player in getPlayersOnHero(Hero.GENJI, Team.1)]) == false  # not being grabbed by any genji

    eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
    waitTicks(2)
    eventPlayer.stopForcingPosition()
