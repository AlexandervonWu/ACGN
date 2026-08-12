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
all x : User| x.sees- Ad in x.follows.posts
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

pred cap003068 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and some CapBenchA) or some CapBenchB)) and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap003068c { all renamed: CapBenchA | (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003068 { cap003068 iff cap003068c }
check CapBenchEquivalent_cap003068 for 4
