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
all u: User | u -> u not in follows
all u: User | u not in u.follows
follows - iden = follows
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

pred cap005288 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some CapBenchA and some capBenchR) or some capBenchR)) and ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005288c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((some CapBenchA and some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap005288 { cap005288 iff cap005288c }
check CapBenchEquivalent_cap005288 for 4
