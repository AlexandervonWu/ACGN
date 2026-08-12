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

pred cap000267 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((no CapBenchB or some CapBenchB) and some capBenchR))) }
pred cap000267c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv6 and ((no CapBenchB or some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000267 { cap000267 iff cap000267c }
check CapBenchEquivalent_cap000267 for 4
