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
all d : Day | all i : Influencer |  d in i.posts.date
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

pred cap003836 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchA and no CapBenchA) or some capBenchS))) }
pred cap003836c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv6 and ((some CapBenchA and no CapBenchA) or some capBenchS))) }
assert CapBenchEquivalent_cap003836 { cap003836 iff cap003836c }
check CapBenchEquivalent_cap003836 for 4
