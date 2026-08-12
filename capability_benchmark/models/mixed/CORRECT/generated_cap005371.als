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

pred cap005371 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) and ((some CapBenchA and some capBenchR) or some CapBenchA))) }
pred cap005371c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some capBenchR) or some CapBenchA)) or (not (inv7 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)))) }
assert CapBenchEquivalent_cap005371 { cap005371 iff cap005371c }
check CapBenchEquivalent_cap005371 for 4
