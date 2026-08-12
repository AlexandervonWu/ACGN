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

pred cap002742 { not historically ((inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
pred cap002742c { once (not (inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap002742 { cap002742 iff cap002742c }
check CapBenchEquivalent_cap002742 for 4
