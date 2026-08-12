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

pred cap002064 { not (all x: CapBenchA | (x->x in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or some CapBenchB)))) }
pred cap002064c { some x: CapBenchA | not (x->x in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap002064 { cap002064 iff cap002064c }
check CapBenchEquivalent_cap002064 for 4
