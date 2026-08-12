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

pred cap002020 { ((inv7 and ((some capBenchR and no CapBenchA) or some CapBenchA)) implies ((some CapBenchB or some CapBenchA) or no CapBenchB)) }
pred cap002020c { ((not (inv7 and ((some capBenchR and no CapBenchA) or some CapBenchA))) or ((some CapBenchB or some CapBenchA) or no CapBenchB)) }
assert CapBenchEquivalent_cap002020 { cap002020 iff cap002020c }
check CapBenchEquivalent_cap002020 for 4
