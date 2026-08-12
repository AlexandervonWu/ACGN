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

pred cap001252 { all x, y: CapBenchA | (x->y in capBenchR and (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
pred cap001252c { all a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap001252 { cap001252 iff cap001252c }
check CapBenchEquivalent_cap001252 for 4
