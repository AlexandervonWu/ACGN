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

pred cap001676 { ((some x: CapBenchA | x->x in capBenchR) and (inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA))) }
pred cap001676c { (some x: CapBenchA | (x->x in capBenchR and (inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001676 { cap001676 iff cap001676c }
check CapBenchEquivalent_cap001676 for 4
