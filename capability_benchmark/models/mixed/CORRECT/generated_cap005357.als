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

pred cap005357 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchS or some capBenchR) or some capBenchS)) and ((no CapBenchA and no CapBenchA) and some CapBenchA))) }
pred cap005357c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchA) and some CapBenchA)) or (not (inv2 and ((some capBenchS or some capBenchR) or some capBenchS)))) }
assert CapBenchEquivalent_cap005357 { cap005357 iff cap005357c }
check CapBenchEquivalent_cap005357 for 4
