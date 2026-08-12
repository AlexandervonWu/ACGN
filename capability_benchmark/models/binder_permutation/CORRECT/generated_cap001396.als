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

pred cap001396 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001396c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001396 { cap001396 iff cap001396c }
check CapBenchEquivalent_cap001396 for 4
