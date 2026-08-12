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
all p : Photo | one posts.p
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

pred cap004587 { not ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) and ((some capBenchR and some CapBenchA) or some capBenchR)) }
pred cap004587c { ((not ((some capBenchR and some CapBenchA) or some capBenchR)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004587 { cap004587 iff cap004587c }
check CapBenchEquivalent_cap004587 for 4
