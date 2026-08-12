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

pred cap000170 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
pred cap000170c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((no CapBenchA and some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap000170 { cap000170 iff cap000170c }
check CapBenchEquivalent_cap000170 for 4
