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
all d : Day, i : Influencer | some p : Photo | i->p in posts and p->d in date
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

pred cap002335 { no x: CapBenchA | (x->x in capBenchR and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS))) }
pred cap002335c { all x: CapBenchA | not (x->x in capBenchR and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap002335 { cap002335 iff cap002335c }
check CapBenchEquivalent_cap002335 for 4
