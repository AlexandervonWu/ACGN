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

pred cap003188 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) and ((some CapBenchB or some capBenchS) or some capBenchS)) }
pred cap003188c { all renamed: CapBenchA | (((some CapBenchB or some capBenchS) or some capBenchS) and renamed->renamed in capBenchR and (inv6 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003188 { cap003188 iff cap003188c }
check CapBenchEquivalent_cap003188 for 4
