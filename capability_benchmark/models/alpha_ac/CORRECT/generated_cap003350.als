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

pred cap003350 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) and ((no CapBenchB or some CapBenchB) and some CapBenchA)) }
pred cap003350c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchB) and some CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003350 { cap003350 iff cap003350c }
check CapBenchEquivalent_cap003350 for 4
