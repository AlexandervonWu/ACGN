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

pred cap003277 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some capBenchS or no CapBenchA) or some capBenchR)) and ((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003277c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv7 and ((some capBenchS or no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003277 { cap003277 iff cap003277c }
check CapBenchEquivalent_cap003277 for 4
