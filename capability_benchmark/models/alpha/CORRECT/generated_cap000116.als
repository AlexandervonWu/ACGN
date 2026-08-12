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

pred cap000116 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
pred cap000116c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv6 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap000116 { cap000116 iff cap000116c }
check CapBenchEquivalent_cap000116 for 4
