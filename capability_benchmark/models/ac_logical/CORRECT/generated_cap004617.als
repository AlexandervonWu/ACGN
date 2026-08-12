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

pred cap004617 { not ((inv6 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((no CapBenchA and some capBenchR) and some capBenchR)) }
pred cap004617c { ((not ((no CapBenchA and some capBenchR) and some capBenchR)) or (not (inv6 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004617 { cap004617 iff cap004617c }
check CapBenchEquivalent_cap004617 for 4
