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
all u : User | u.follows.follows - u - u.follows = u.suggested
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

pred cap005332 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((some capBenchR and some CapBenchB) or some capBenchS)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005332c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv7 and ((some capBenchR and some CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005332 { cap005332 iff cap005332c }
check CapBenchEquivalent_cap005332 for 4
