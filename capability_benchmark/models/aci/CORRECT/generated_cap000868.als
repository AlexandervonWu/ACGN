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

pred cap000868 { (inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) }
pred cap000868c { ((inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS)) and (inv6 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap000868 { cap000868 iff cap000868c }
check CapBenchEquivalent_cap000868 for 4
