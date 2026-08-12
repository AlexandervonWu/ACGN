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
all p:Photo | one posts.p
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

pred cap004863 { not ((inv1 and ((no CapBenchB or some capBenchS) and some capBenchS)) and ((some CapBenchA and no CapBenchB) or some CapBenchA)) }
pred cap004863c { ((not ((some CapBenchA and no CapBenchB) or some CapBenchA)) or (not (inv1 and ((no CapBenchB or some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap004863 { cap004863 iff cap004863c }
check CapBenchEquivalent_cap004863 for 4
