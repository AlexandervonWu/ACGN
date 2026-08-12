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

pred cap004591 { not ((inv1 and ((no CapBenchB or no CapBenchB) and some CapBenchB)) and ((some CapBenchA and some CapBenchB) or some capBenchR)) }
pred cap004591c { ((not ((some CapBenchA and some CapBenchB) or some capBenchR)) or (not (inv1 and ((no CapBenchB or no CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004591 { cap004591 iff cap004591c }
check CapBenchEquivalent_cap004591 for 4
