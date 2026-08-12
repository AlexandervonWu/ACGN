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
all u: User | u.sees in (u.follows.posts + Ad)
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

pred cap001912 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001912c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001912 { cap001912 iff cap001912c }
check CapBenchEquivalent_cap001912 for 4
