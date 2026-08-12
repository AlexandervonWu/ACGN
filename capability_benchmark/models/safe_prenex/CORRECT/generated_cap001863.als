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

pred cap001863 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((no CapBenchB or some capBenchS) and some capBenchS))) }
pred cap001863c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((no CapBenchB or some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap001863 { cap001863 iff cap001863c }
check CapBenchEquivalent_cap001863 for 4
