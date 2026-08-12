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

pred cap000713 { (inv7 and ((some capBenchS or no CapBenchA) or no CapBenchB)) }
pred cap000713c { ((inv7 and ((some capBenchS or no CapBenchA) or no CapBenchB)) or (inv7 and ((some capBenchS or no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000713 { cap000713 iff cap000713c }
check CapBenchEquivalent_cap000713 for 4
