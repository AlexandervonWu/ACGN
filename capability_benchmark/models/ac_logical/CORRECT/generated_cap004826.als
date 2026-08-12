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

pred cap004826 { not ((inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004826c { ((not ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)))) }
assert CapBenchEquivalent_cap004826 { cap004826 iff cap004826c }
check CapBenchEquivalent_cap004826 for 4
