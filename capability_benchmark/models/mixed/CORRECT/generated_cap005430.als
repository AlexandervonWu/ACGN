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

pred cap005430 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or no CapBenchB) and some CapBenchB))) }
pred cap005430c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchB) and some CapBenchB)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005430 { cap005430 iff cap005430c }
check CapBenchEquivalent_cap005430 for 4
