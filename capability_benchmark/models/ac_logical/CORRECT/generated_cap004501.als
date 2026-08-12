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

pred cap004501 { not ((inv6 and ((some CapBenchB or some CapBenchA) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) }
pred cap004501c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and no CapBenchA)) or (not (inv6 and ((some CapBenchB or some CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004501 { cap004501 iff cap004501c }
check CapBenchEquivalent_cap004501 for 4
