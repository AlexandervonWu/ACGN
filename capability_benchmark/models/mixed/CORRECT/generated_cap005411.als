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

pred cap005411 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and some CapBenchB) or some CapBenchB))) }
pred cap005411c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchB) or some CapBenchB)) or (not (inv1 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005411 { cap005411 iff cap005411c }
check CapBenchEquivalent_cap005411 for 4
