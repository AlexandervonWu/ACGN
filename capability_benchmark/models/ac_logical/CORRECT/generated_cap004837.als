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

pred cap004837 { not ((inv1 and ((some CapBenchB or no CapBenchA) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004837c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((some CapBenchB or no CapBenchA) or some capBenchS)))) }
assert CapBenchEquivalent_cap004837 { cap004837 iff cap004837c }
check CapBenchEquivalent_cap004837 for 4
