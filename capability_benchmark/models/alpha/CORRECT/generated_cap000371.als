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

pred cap000371 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
pred cap000371c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap000371 { cap000371 iff cap000371c }
check CapBenchEquivalent_cap000371 for 4
