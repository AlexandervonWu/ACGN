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

pred cap002257 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
pred cap002257c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002257 { cap002257 iff cap002257c }
check CapBenchEquivalent_cap002257 for 4
