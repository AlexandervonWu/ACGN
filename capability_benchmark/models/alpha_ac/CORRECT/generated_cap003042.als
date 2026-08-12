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

pred cap003042 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some capBenchS) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB)) }
pred cap003042c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap003042 { cap003042 iff cap003042c }
check CapBenchEquivalent_cap003042 for 4
