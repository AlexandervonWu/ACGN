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

pred cap002675 { not eventually ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA))) }
pred cap002675c { always (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap002675 { cap002675 iff cap002675c }
check CapBenchEquivalent_cap002675 for 4
