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

pred cap000932 { ((inv1 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or no CapBenchB) or some CapBenchB) and ((no CapBenchB or some CapBenchB) and some capBenchR)) }
pred cap000932c { (((no CapBenchB or some CapBenchB) and some capBenchR) and (inv1 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or no CapBenchB) or some CapBenchB)) }
assert CapBenchEquivalent_cap000932 { cap000932 iff cap000932c }
check CapBenchEquivalent_cap000932 for 4
