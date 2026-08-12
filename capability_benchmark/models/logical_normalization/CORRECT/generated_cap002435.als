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

pred cap002435 { ((inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) iff ((some CapBenchA and some capBenchR) or some CapBenchB)) }
pred cap002435c { (((not (inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) or ((some CapBenchA and some capBenchR) or some CapBenchB)) and ((not ((some CapBenchA and some capBenchR) or some CapBenchB)) or (inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap002435 { cap002435 iff cap002435c }
check CapBenchEquivalent_cap002435 for 4
