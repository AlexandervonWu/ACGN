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

pred cap000687 { ((inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) or ((some CapBenchA and some capBenchS) or some capBenchS) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA)) }
pred cap000687c { (((some CapBenchA and some capBenchS) or some capBenchS) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA) or (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000687 { cap000687 iff cap000687c }
check CapBenchEquivalent_cap000687 for 4
