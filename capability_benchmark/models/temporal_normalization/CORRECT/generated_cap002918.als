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

pred cap002918 { not (((inv1 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) until (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB))) }
pred cap002918c { ((not (inv1 and ((no CapBenchA and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) releases (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap002918 { cap002918 iff cap002918c }
check CapBenchEquivalent_cap002918 for 4
