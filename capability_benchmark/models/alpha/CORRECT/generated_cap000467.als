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

pred cap000467 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap000467c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv7 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000467 { cap000467 iff cap000467c }
check CapBenchEquivalent_cap000467 for 4
