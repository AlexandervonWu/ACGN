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

pred cap003873 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap003873c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap003873 { cap003873 iff cap003873c }
check CapBenchEquivalent_cap003873 for 4
