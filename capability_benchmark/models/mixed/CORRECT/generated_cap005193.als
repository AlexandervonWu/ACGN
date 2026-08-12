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

pred cap005193 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv2 and ((some CapBenchB or some CapBenchA) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS))) }
pred cap005193c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some capBenchS)) or (not (inv2 and ((some CapBenchB or some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005193 { cap005193 iff cap005193c }
check CapBenchEquivalent_cap005193 for 4
