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

pred cap003413 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some CapBenchB) and some CapBenchB)) }
pred cap003413c { all renamed: CapBenchA | (((no CapBenchA and some CapBenchB) and some CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003413 { cap003413 iff cap003413c }
check CapBenchEquivalent_cap003413 for 4
