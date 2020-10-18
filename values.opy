#VALUES
#!define getHeight(player) (player.getEyePosition() - player.getPosition())

#!define eyeCast(fromPlayer, len) raycast(fromPlayer.getEyePosition(), fromPlayer.getEyePosition() + fromPlayer.getFacingDirection() * len, getAllPlayers(), fromPlayer, true)

#!define altitudeOf(point) distance(point, raycast(point, point + Vector.DOWN * 100, [], [], false).getHitPosition())

#!defineMember getForwardThrottle() getThrottle().z

#!defineMember getBackwardsThrottle() (getThrottle().z * -1)

#!defineMember getStrafeThrottle() getThrottle().x

#!defineMember getLeftThrottle() getThrottle().x

#!define oppositeTeamOf(player) getOppositeTeam(player.getTeam())

#!define ticks(n) 0.016*(n)

#!define addMod(v, a, m) ((v + (a)) % (m))

#!define sign(n) (1 if n >= 0 else -1)

#!define clamp(value, minimum, maximum) min(max(value, minimum), maximum)