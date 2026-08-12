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
all x : User | x -> x not in follows
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

pred cap004232 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv2 and ((some CapBenchA and some capBenchS) or no CapBenchB))) }
pred cap004232c { some a, b: CapBenchA | (b->a in capBenchR and (inv2 and ((some CapBenchA and some capBenchS) or no CapBenchB))) }
assert CapBenchEquivalent_cap004232 { cap004232 iff cap004232c }
check CapBenchEquivalent_cap004232 for 4
