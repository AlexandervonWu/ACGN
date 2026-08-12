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

pred cap002124 { not (all x: CapBenchA | (x->x in capBenchR and (inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
pred cap002124c { some x: CapBenchA | not (x->x in capBenchR and (inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002124 { cap002124 iff cap002124c }
check CapBenchEquivalent_cap002124 for 4
