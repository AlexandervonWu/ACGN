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

pred cap004319 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
pred cap004319c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap004319 { cap004319 iff cap004319c }
check CapBenchEquivalent_cap004319 for 4
