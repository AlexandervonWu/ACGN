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

pred cap003179 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) and ((some CapBenchA and some capBenchR) or some capBenchS)) }
pred cap003179c { all renamed: CapBenchA | (((some CapBenchA and some capBenchR) or some capBenchS) and renamed->renamed in capBenchR and (inv6 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA))) }
assert CapBenchEquivalent_cap003179 { cap003179 iff cap003179c }
check CapBenchEquivalent_cap003179 for 4
