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

pred cap003404 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or some CapBenchA) or some CapBenchB)) }
pred cap003404c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchA) or some CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003404 { cap003404 iff cap003404c }
check CapBenchEquivalent_cap003404 for 4
