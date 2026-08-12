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

pred cap002670 { not historically ((inv1 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
pred cap002670c { once (not (inv1 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap002670 { cap002670 iff cap002670c }
check CapBenchEquivalent_cap002670 for 4
