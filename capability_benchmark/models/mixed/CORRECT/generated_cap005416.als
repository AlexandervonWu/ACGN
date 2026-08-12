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
all p:Photo | one posts.p
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

pred cap005416 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or some CapBenchB) or some CapBenchB))) }
pred cap005416c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some CapBenchB) or some CapBenchB)) or (not (inv1 and ((some CapBenchA and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005416 { cap005416 iff cap005416c }
check CapBenchEquivalent_cap005416 for 4
