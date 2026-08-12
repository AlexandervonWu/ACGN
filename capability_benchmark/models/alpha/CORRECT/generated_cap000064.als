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

pred cap000064 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
pred cap000064c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap000064 { cap000064 iff cap000064c }
check CapBenchEquivalent_cap000064 for 4
