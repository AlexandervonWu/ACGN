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

pred cap001608 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
pred cap001608c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001608 { cap001608 iff cap001608c }
check CapBenchEquivalent_cap001608 for 4
