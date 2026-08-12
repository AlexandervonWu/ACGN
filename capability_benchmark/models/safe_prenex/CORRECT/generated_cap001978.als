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

pred cap001978 { ((some x: CapBenchA | x->x in capBenchR) and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001978c { (some x: CapBenchA | (x->x in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001978 { cap001978 iff cap001978c }
check CapBenchEquivalent_cap001978 for 4
