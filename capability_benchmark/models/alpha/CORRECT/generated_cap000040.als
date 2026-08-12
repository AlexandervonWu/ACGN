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

pred cap000040 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchA and some capBenchS) or some CapBenchA))) }
pred cap000040c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((some CapBenchA and some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap000040 { cap000040 iff cap000040c }
check CapBenchEquivalent_cap000040 for 4
