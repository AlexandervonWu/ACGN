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

pred cap001773 { ((all x: CapBenchA | x->x in capBenchR) or (inv7 and ((some CapBenchB or no CapBenchA) or some capBenchR))) }
pred cap001773c { (all x: CapBenchA | (x->x in capBenchR or (inv7 and ((some CapBenchB or no CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap001773 { cap001773 iff cap001773c }
check CapBenchEquivalent_cap001773 for 4
