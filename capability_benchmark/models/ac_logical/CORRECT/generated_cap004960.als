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

pred cap004960 { not ((inv1 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) }
pred cap004960c { ((not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) or (not (inv1 and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004960 { cap004960 iff cap004960c }
check CapBenchEquivalent_cap004960 for 4
