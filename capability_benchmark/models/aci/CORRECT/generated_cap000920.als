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

pred cap000920 { ((inv1 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or no CapBenchA) or some CapBenchB) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) }
pred cap000920c { (((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB) and (inv1 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or no CapBenchA) or some CapBenchB)) }
assert CapBenchEquivalent_cap000920 { cap000920 iff cap000920c }
check CapBenchEquivalent_cap000920 for 4
