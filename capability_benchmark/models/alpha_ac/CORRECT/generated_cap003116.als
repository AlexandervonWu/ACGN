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

pred inv3 {
all u : User | all p : Photo | p in u.sees implies p in u.follows.posts or p in Ad
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003116 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((some CapBenchB or some capBenchR) or some capBenchR)) }
pred cap003116c { all renamed: CapBenchA | (((some CapBenchB or some capBenchR) or some capBenchR) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB))) }
assert CapBenchEquivalent_cap003116 { cap003116 iff cap003116c }
check CapBenchEquivalent_cap003116 for 4
