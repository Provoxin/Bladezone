#FUNCTIONS

#!define cancelMomentum(player) player.applyImpulse(player.getVelocity() * -1, player.getSpeed(), Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)

#!define longCancelMomentum(player) player.applyImpulse(Vector.UP, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)\
									player.applyImpulse(Vector.DOWN, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)\
									player.applyImpulse(Vector.BACKWARD, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)\
									player.applyImpulse(Vector.FORWARD, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)\
									player.applyImpulse(Vector.RIGHT, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)\
									player.applyImpulse(Vector.LEFT, 0.001, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

#!define replenishAmmo(player) player.setAmmo(0, player.getMaxAmmo(0))

#!define giveAbilities(player) player.setAbilityCooldown(Button.ABILITY_1, 0)\
								player.setAbilityCooldown(Button.ABILITY_2, 0)
								
#!define debugText(vis, header) hudHeader(vis, header, HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

#!define waitTicks(n) wait(ticks(n))

#!define incrementMatchTime(n) setMatchTime(getMatchTime() + (n))

#!define createGHWatermark(vis) hudSubheader(vis, "{0} GrandeurHammers.com/discord".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2)), HudPosition.RIGHT, -1000, Color.ORANGE, HudReeval.VISIBILITY, SpecVisibility.ALWAYS)

#!define debugMessage() smallMessage(getAllPlayers(), "debug")