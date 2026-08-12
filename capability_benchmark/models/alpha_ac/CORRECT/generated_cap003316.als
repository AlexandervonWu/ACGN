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

pred cap003316 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003316c { all renamed: CapBenchA | (((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003316 { cap003316 iff cap003316c }
check CapBenchEquivalent_cap003316 for 4
