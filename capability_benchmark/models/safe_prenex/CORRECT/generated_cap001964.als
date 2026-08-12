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

pred cap001964 { ((some x: CapBenchA | x->x in capBenchR) and (inv6 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001964c { (some x: CapBenchA | (x->x in capBenchR and (inv6 and ((some CapBenchA and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001964 { cap001964 iff cap001964c }
check CapBenchEquivalent_cap001964 for 4
