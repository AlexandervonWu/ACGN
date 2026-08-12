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
all i : Influencer, d : Day | d in i.posts.date
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

pred cap004549 { not ((inv6 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)) }
pred cap004549c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)) or (not (inv6 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004549 { cap004549 iff cap004549c }
check CapBenchEquivalent_cap004549 for 4
