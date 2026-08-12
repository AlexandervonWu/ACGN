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
all x : User | x not in x.follows
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

pred cap001793 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some capBenchS or some capBenchR) or some capBenchR))) }
pred cap001793c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some capBenchS or some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap001793 { cap001793 iff cap001793c }
check CapBenchEquivalent_cap001793 for 4
