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

pred cap001927 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001927c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((no CapBenchB or some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001927 { cap001927 iff cap001927c }
check CapBenchEquivalent_cap001927 for 4
