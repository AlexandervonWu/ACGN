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

pred cap002380 { ((inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) implies ((some CapBenchB or some capBenchS) or some CapBenchA)) }
pred cap002380c { ((not (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) or ((some CapBenchB or some capBenchS) or some CapBenchA)) }
assert CapBenchEquivalent_cap002380 { cap002380 iff cap002380c }
check CapBenchEquivalent_cap002380 for 4
