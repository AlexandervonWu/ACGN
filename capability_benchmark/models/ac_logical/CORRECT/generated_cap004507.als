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

pred cap004507 { not ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap004507c { ((not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004507 { cap004507 iff cap004507c }
check CapBenchEquivalent_cap004507 for 4
