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
all p:Photo|one u: User| p in u.posts
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

pred cap000680 { ((inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((some CapBenchB or some capBenchR) or some capBenchS) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA)) }
pred cap000680c { (((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchA) and (inv1 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((some CapBenchB or some capBenchR) or some capBenchS)) }
assert CapBenchEquivalent_cap000680 { cap000680 iff cap000680c }
check CapBenchEquivalent_cap000680 for 4
