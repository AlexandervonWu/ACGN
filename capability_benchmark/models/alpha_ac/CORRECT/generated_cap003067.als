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

pred cap003067 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchB or some CapBenchA) and some CapBenchB)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap003067c { all renamed: CapBenchA | (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchB or some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap003067 { cap003067 iff cap003067c }
check CapBenchEquivalent_cap003067 for 4
