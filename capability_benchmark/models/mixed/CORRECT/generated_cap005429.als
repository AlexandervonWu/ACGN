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

pred cap005429 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and no CapBenchB) and some CapBenchB))) }
pred cap005429c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and no CapBenchB) and some CapBenchB)) or (not (inv2 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005429 { cap005429 iff cap005429c }
check CapBenchEquivalent_cap005429 for 4
