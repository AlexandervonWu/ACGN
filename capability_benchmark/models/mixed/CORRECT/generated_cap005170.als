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

pred cap005170 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((no CapBenchA and some capBenchS) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS))) }
pred cap005170c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchS)) or (not (inv6 and ((no CapBenchA and some capBenchS) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005170 { cap005170 iff cap005170c }
check CapBenchEquivalent_cap005170 for 4
