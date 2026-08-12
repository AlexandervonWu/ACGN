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
all p : Photo | one posts.p
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

pred cap001782 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((no CapBenchA and no CapBenchB) and some capBenchR))) }
pred cap001782c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap001782 { cap001782 iff cap001782c }
check CapBenchEquivalent_cap001782 for 4
