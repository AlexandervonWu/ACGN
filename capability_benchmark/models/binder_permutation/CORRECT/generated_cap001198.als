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

pred cap001198 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB))) }
pred cap001198c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap001198 { cap001198 iff cap001198c }
check CapBenchEquivalent_cap001198 for 4
