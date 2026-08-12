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

pred cap001760 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((some capBenchR and some CapBenchA) or some capBenchR))) }
pred cap001760c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchR and some CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap001760 { cap001760 iff cap001760c }
check CapBenchEquivalent_cap001760 for 4
