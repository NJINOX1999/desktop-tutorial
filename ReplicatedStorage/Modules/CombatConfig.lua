local CombatConfig = {}

CombatConfig.FISTS = {
	[1] = {name="JabCombo", cooldown=0.6, damage=8, stun=0.2, knockback=25, range=4, size=Vector3.new(5,5,6)},
	[2] = {name="Uppercut", cooldown=4, damage=18, stun=0.6, knockback=45, range=4, size=Vector3.new(5,6,6)},
	[3] = {name="GroundSlam", cooldown=6, damage=22, stun=0.8, knockback=30, radius=8},
	[4] = {name="DashPunch", cooldown=5, damage=16, stun=0.5, knockback=50, range=6, size=Vector3.new(6,5,8), dashSpeed=60, dashTime=0.25},
}

CombatConfig.SWORD = {
	[1] = {name="SlashCombo", cooldown=0.8, damage=10, stun=0.2, knockback=28, range=5, size=Vector3.new(6,5,8)},
	[2] = {name="WhirlwindSpin", cooldown=7, damage=20, stun=0.6, knockback=35, radius=9},
	[3] = {name="DashStrike", cooldown=5, damage=18, stun=0.4, knockback=50, range=7, size=Vector3.new(6,5,9), dashSpeed=70, dashTime=0.2},
	[4] = {name="BladeWave", cooldown=8, damage=16, stun=0.4, knockback=40, projectileSpeed=70, projectileRange=60, projectileRadius=4},
}

return CombatConfig
