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

pred cap004571 { not ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap004571c { ((not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) or (not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004571 { cap004571 iff cap004571c }
check CapBenchEquivalent_cap004571 for 4
