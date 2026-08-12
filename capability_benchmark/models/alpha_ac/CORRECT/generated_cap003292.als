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
all x: Photo | one posts.x
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

pred cap003292 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and some capBenchR) or some capBenchR)) and ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003292c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap003292 { cap003292 iff cap003292c }
check CapBenchEquivalent_cap003292 for 4
