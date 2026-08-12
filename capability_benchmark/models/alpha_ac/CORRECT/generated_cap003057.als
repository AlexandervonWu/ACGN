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

pred cap003057 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB)) }
pred cap003057c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap003057 { cap003057 iff cap003057c }
check CapBenchEquivalent_cap003057 for 4
