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

pred inv7 {
all u, s: User | s in u.suggested iff s not in u.follows and s in u.follows.follows and s != u
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005370 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA))) }
pred cap005370c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA)) or (not (inv7 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)))) }
assert CapBenchEquivalent_cap005370 { cap005370 iff cap005370c }
check CapBenchEquivalent_cap005370 for 4
