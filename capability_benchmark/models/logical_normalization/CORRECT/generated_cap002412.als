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

pred cap002412 { not (all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
pred cap002412c { some x: CapBenchA | not (x->x in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002412 { cap002412 iff cap002412c }
check CapBenchEquivalent_cap002412 for 4
