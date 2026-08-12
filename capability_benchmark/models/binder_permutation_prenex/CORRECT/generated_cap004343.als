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

pred cap004343 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS))) }
pred cap004343c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap004343 { cap004343 iff cap004343c }
check CapBenchEquivalent_cap004343 for 4
