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

pred cap003307 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) and ((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003307c { all renamed: CapBenchA | (((some CapBenchA and some capBenchR) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap003307 { cap003307 iff cap003307c }
check CapBenchEquivalent_cap003307 for 4
