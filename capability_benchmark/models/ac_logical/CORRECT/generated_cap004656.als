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

pred inv1 {
all x : Photo | one posts.x
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004656 { not ((inv1 and ((some capBenchR and no CapBenchB) or no CapBenchA)) and ((some CapBenchB or some CapBenchB) or some capBenchS)) }
pred cap004656c { ((not ((some CapBenchB or some CapBenchB) or some capBenchS)) or (not (inv1 and ((some capBenchR and no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004656 { cap004656 iff cap004656c }
check CapBenchEquivalent_cap004656 for 4
