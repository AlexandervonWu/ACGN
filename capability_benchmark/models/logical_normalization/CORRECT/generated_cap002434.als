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

pred cap002434 { ((inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) implies ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB)) }
pred cap002434c { ((not (inv1 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) or ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB)) }
assert CapBenchEquivalent_cap002434 { cap002434 iff cap002434c }
check CapBenchEquivalent_cap002434 for 4
