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

pred cap003074 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((no CapBenchA and some CapBenchB) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) }
pred cap003074c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB) and renamed->renamed in capBenchR and (inv6 and ((no CapBenchA and some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003074 { cap003074 iff cap003074c }
check CapBenchEquivalent_cap003074 for 4
