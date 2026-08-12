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
all i : Influencer, d : Day | d in i.posts.date
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

pred cap001458 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap001458c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((no CapBenchA and some CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001458 { cap001458 iff cap001458c }
check CapBenchEquivalent_cap001458 for 4
