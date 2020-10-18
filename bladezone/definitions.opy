#!mainFile "bladezone.opy"

#!define NOCLIP_BASE_SPEED 14
#!define NOCLIP_BOOST_MODIFIER 2
#!define NOCLIP_BOOST_SPEED NOCLIP_BASE_SPEED * NOCLIP_BOOST_MODIFIER

#!define noclipEyecast(player, length, include, exclude) raycast(player.noclipPosition, player.noclipPosition + player.getFacingDirection() * (length), include, exclude, true)

#!define closestToReticleNoclipLOS sorted([bot for bot in getPlayers(Team.2) if isInLoS(eventPlayer.noclipPosition, bot.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS)], lambda bot: angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer.noclipPosition, bot.getEyePosition())))[0]

#!define createMenuPageText(text, sort) # create text\
                                        hudSubtext(eventPlayer if eventPlayer.isEditing else [], text, HudPosition.LEFT, sort, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)\
                                        eventPlayer.menuPageTextIDs.append(getLastCreatedText())\
                                        wait()

#!define createPage(page, len) __script__("createPage.js")

#!define updateRunner() currentRunnerIndex = addMod(sorted(getPlayersOnHero(Hero.GENJI, Team.1), lambda player: player.getSlot()).index(currentRunner), 1, getNumberOfHeroes(Hero.GENJI, Team.1))\
                        currentRunner = sorted(getPlayersOnHero(Hero.GENJI, Team.1), lambda player: player.getSlot())[currentRunnerIndex]

#!define resetTimes(players) players.lastRunTime = 0\
                             players.bestRunTime = 0

#!define currentRunnerIndex runnerData[0]
#!define currentRunner runnerData[1]

#!define chaseNoclip() chase(eventPlayer.noclipPosition,\
eventPlayer.noclipPosition\
+ ((eventPlayer.getFacingDirection() * eventPlayer.getForwardThrottle())\
+ (worldVector(eventPlayer.getThrottle() * vect(1, 0, 0), eventPlayer, Transform.ROTATION))\
+ (Vector.UP * (eventPlayer.isHoldingButton(Button.JUMP) - eventPlayer.isHoldingButton(Button.CROUCH)))) * 100,\
rate=(/*NOCLIP_BOOST_SPEED if eventPlayer.isHoldingButton(Button.ABILITY_1) else */NOCLIP_BASE_SPEED), ChaseReeval.DESTINATION_AND_RATE)  # take into account throttle, facing direction, jump, and crouch inputs to make a decent noclip