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

pred inv6 {
all i : Influencer | all d : Day | some p : Photo | d = p.date and p in i.posts
}

pred inv6c {
	all i : Influencer, d : Day | some i.posts & date.d
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000919 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv6 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap000919c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv6 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000919 { cap000919 iff cap000919c }
check CapBenchEquivalent_cap000919 for 4
