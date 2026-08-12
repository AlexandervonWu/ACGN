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

pred cap004265 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv7 and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
pred cap004265c { some a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap004265 { cap004265 iff cap004265c }
check CapBenchEquivalent_cap004265 for 4
