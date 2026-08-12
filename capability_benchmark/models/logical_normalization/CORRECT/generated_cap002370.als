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

pred cap002370 { not (all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)))) }
pred cap002370c { some x: CapBenchA | not (x->x in capBenchR and (inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap002370 { cap002370 iff cap002370c }
check CapBenchEquivalent_cap002370 for 4
