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

pred cap000758 { ((inv7 and ((no CapBenchA and some CapBenchA) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)) and ((some capBenchS or no CapBenchB) or some CapBenchB)) }
pred cap000758c { (((some capBenchS or no CapBenchB) or some CapBenchB) and (inv7 and ((no CapBenchA and some CapBenchA) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap000758 { cap000758 iff cap000758c }
check CapBenchEquivalent_cap000758 for 4
