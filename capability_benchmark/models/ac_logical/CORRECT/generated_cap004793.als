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

pred cap004793 { not ((inv7 and ((some capBenchS or some capBenchR) or some capBenchR)) and ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004793c { ((not ((no CapBenchA and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv7 and ((some capBenchS or some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap004793 { cap004793 iff cap004793c }
check CapBenchEquivalent_cap004793 for 4
