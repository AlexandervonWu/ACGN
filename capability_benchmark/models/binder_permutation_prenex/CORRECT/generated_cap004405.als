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

pred inv7 {
all u : User | u.follows.follows - u - u.follows = u.suggested
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004405 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004405c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004405 { cap004405 iff cap004405c }
check CapBenchEquivalent_cap004405 for 4
