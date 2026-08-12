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

pred cap003045 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or some capBenchS) or some CapBenchA)) and ((no CapBenchA and no CapBenchB) and no CapBenchB)) }
pred cap003045c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchB) and no CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap003045 { cap003045 iff cap003045c }
check CapBenchEquivalent_cap003045 for 4
