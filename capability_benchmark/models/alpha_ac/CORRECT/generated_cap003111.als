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

pred cap003111 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB)) and ((some capBenchR and no CapBenchB) or some capBenchR)) }
pred cap003111c { all renamed: CapBenchA | (((some capBenchR and no CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchB))) }
assert CapBenchEquivalent_cap003111 { cap003111 iff cap003111c }
check CapBenchEquivalent_cap003111 for 4
