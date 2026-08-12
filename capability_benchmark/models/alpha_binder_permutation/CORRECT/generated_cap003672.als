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

pred cap003672 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
pred cap003672c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap003672 { cap003672 iff cap003672c }
check CapBenchEquivalent_cap003672 for 4
