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

pred cap004864 { not ((inv6 and ((some capBenchR and some capBenchS) or some capBenchS)) and ((some CapBenchB or no CapBenchB) or some CapBenchA)) }
pred cap004864c { ((not ((some CapBenchB or no CapBenchB) or some CapBenchA)) or (not (inv6 and ((some capBenchR and some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap004864 { cap004864 iff cap004864c }
check CapBenchEquivalent_cap004864 for 4
