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

pred cap000520 { (inv3 and ((some capBenchR and no CapBenchA) or some CapBenchA)) }
pred cap000520c { ((inv3 and ((some capBenchR and no CapBenchA) or some CapBenchA)) and (inv3 and ((some capBenchR and no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap000520 { cap000520 iff cap000520c }
check CapBenchEquivalent_cap000520 for 4
