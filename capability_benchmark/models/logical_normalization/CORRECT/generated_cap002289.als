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

pred cap002289 { not ((inv1 and ((some CapBenchB or some capBenchR) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002289c { ((not (inv1 and ((some CapBenchB or some capBenchR) or some capBenchR))) or (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002289 { cap002289 iff cap002289c }
check CapBenchEquivalent_cap002289 for 4
