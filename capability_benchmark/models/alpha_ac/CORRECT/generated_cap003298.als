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

pred cap003298 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some capBenchS) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003298c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchA and some capBenchS) and some capBenchR))) }
assert CapBenchEquivalent_cap003298 { cap003298 iff cap003298c }
check CapBenchEquivalent_cap003298 for 4
