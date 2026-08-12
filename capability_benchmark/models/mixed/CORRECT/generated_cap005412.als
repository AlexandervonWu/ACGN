sig User {
	follows : set User,
	sees : set Photo,
	posts : set Photo,
	suggested : set User
}

sig Influencer extends User {}

sig Photo {
	date : one Day
}
sig Ad extends Photo {}

sig Day {}

pred inv2 {
all u:User|  u not in u.follows
}

pred inv2c {
	all p : User | p not in p.follows
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005412 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or some CapBenchB) or some CapBenchB))) }
pred cap005412c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchB) or some CapBenchB)) or (not (inv2 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005412 { cap005412 iff cap005412c }
check CapBenchEquivalent_cap005412 for 4
