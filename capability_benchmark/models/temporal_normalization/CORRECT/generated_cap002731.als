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
all p : Photo | one posts.p
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

pred cap002731 { not once ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB))) }
pred cap002731c { historically (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB))) }
assert CapBenchEquivalent_cap002731 { cap002731 iff cap002731c }
check CapBenchEquivalent_cap002731 for 4
