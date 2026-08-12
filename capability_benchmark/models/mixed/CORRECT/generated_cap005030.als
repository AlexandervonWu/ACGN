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

pred cap005030 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)) and ((no CapBenchB or some CapBenchB) and no CapBenchB))) }
pred cap005030c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or some CapBenchB) and no CapBenchB)) or (not (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005030 { cap005030 iff cap005030c }
check CapBenchEquivalent_cap005030 for 4
