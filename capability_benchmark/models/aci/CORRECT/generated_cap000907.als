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

pred cap000907 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000907c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000907 { cap000907 iff cap000907c }
check CapBenchEquivalent_cap000907 for 4
