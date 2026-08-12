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

pred cap002794 { not always ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR))) }
pred cap002794c { eventually (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap002794 { cap002794 iff cap002794c }
check CapBenchEquivalent_cap002794 for 4
