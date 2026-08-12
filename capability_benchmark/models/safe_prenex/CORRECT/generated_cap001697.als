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

pred cap001697 { ((all x: CapBenchA | x->x in capBenchR) or (inv7 and ((some capBenchS or some CapBenchA) or no CapBenchB))) }
pred cap001697c { (all x: CapBenchA | (x->x in capBenchR or (inv7 and ((some capBenchS or some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001697 { cap001697 iff cap001697c }
check CapBenchEquivalent_cap001697 for 4
