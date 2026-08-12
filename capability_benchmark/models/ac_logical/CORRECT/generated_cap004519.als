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

pred cap004519 { not ((inv7 and ((no CapBenchB or no CapBenchA) and some CapBenchA)) and ((some CapBenchA and some CapBenchA) or no CapBenchB)) }
pred cap004519c { ((not ((some CapBenchA and some CapBenchA) or no CapBenchB)) or (not (inv7 and ((no CapBenchB or no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004519 { cap004519 iff cap004519c }
check CapBenchEquivalent_cap004519 for 4
