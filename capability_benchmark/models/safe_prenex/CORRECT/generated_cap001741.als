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
all u: User| u not in follows.u
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

pred cap001741 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap001741c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001741 { cap001741 iff cap001741c }
check CapBenchEquivalent_cap001741 for 4
