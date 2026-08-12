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
all u1,u2 : User | (u1 in u2.suggested implies (u1 in ( u2.follows.follows - u2.follows) and u1!=u2))
and
( (u1 in ( u2.follows.follows - u2.follows) and u1!=u2) implies (u1 in u2.suggested))
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

pred cap003151 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)) and ((some capBenchR and some CapBenchA) or some capBenchS)) }
pred cap003151c { all renamed: CapBenchA | (((some capBenchR and some CapBenchA) or some capBenchS) and renamed->renamed in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap003151 { cap003151 iff cap003151c }
check CapBenchEquivalent_cap003151 for 4
