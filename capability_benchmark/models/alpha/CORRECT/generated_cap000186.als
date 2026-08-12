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

pred cap000186 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap000186c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv7 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000186 { cap000186 iff cap000186c }
check CapBenchEquivalent_cap000186 for 4
