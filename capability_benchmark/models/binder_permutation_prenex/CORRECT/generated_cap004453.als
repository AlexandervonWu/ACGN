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

pred cap004453 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004453c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004453 { cap004453 iff cap004453c }
check CapBenchEquivalent_cap004453 for 4
