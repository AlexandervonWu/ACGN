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

pred cap002298 { not (all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and some capBenchR)))) }
pred cap002298c { some x: CapBenchA | not (x->x in capBenchR and (inv2 and ((no CapBenchA and some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap002298 { cap002298 iff cap002298c }
check CapBenchEquivalent_cap002298 for 4
