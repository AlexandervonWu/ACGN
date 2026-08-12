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
all u : User | u.sees - Ad in u.follows.posts
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

pred cap005436 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
pred cap005436c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchR) or some CapBenchB)) or (not (inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005436 { cap005436 iff cap005436c }
check CapBenchEquivalent_cap005436 for 4
