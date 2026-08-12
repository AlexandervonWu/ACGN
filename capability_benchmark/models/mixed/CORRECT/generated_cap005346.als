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
all x : Influencer | x.posts.date = Day
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

pred cap005346 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((no CapBenchA and no CapBenchB) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA))) }
pred cap005346c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA)) or (not (inv6 and ((no CapBenchA and no CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap005346 { cap005346 iff cap005346c }
check CapBenchEquivalent_cap005346 for 4
