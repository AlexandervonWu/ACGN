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

pred cap005020 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchR and no CapBenchA) or some CapBenchA)) and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
pred cap005020c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchA) or no CapBenchB)) or (not (inv1 and ((some capBenchR and no CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005020 { cap005020 iff cap005020c }
check CapBenchEquivalent_cap005020 for 4
