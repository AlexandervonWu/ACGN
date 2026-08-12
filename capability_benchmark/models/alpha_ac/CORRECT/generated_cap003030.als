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

pred cap003030 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) and ((no CapBenchB or some CapBenchB) and no CapBenchB)) }
pred cap003030c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchB) and no CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003030 { cap003030 iff cap003030c }
check CapBenchEquivalent_cap003030 for 4
