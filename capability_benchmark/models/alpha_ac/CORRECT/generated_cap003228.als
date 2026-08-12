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

pred cap003228 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((some capBenchR and some capBenchR) or no CapBenchB)) and ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003228c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv6 and ((some capBenchR and some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap003228 { cap003228 iff cap003228c }
check CapBenchEquivalent_cap003228 for 4
