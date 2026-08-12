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

pred cap004451 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap004451c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004451 { cap004451 iff cap004451c }
check CapBenchEquivalent_cap004451 for 4
