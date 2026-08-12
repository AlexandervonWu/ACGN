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

pred cap000848 { ((inv6 and ((some capBenchR and no CapBenchB) or some capBenchS)) and ((some CapBenchB or some CapBenchB) or some CapBenchA) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap000848c { (((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA) and (inv6 and ((some capBenchR and no CapBenchB) or some capBenchS)) and ((some CapBenchB or some CapBenchB) or some CapBenchA)) }
assert CapBenchEquivalent_cap000848 { cap000848 iff cap000848c }
check CapBenchEquivalent_cap000848 for 4
