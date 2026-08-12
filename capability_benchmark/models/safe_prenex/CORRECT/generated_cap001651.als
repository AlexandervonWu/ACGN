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

pred cap001651 { ((all x: CapBenchA | x->x in capBenchR) or (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA))) }
pred cap001651c { (all x: CapBenchA | (x->x in capBenchR or (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap001651 { cap001651 iff cap001651c }
check CapBenchEquivalent_cap001651 for 4
