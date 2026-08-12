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
all u:User | u not in u.follows
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

pred cap001881 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap001881c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap001881 { cap001881 iff cap001881c }
check CapBenchEquivalent_cap001881 for 4
