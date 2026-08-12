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

pred inv2 {
all u : User | u not in u.follows
}

pred inv2c {
	all p : User | p not in p.follows
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000601 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((some capBenchS or some capBenchR) or some CapBenchB))) }
pred cap000601c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((some capBenchS or some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap000601 { cap000601 iff cap000601c }
check CapBenchEquivalent_cap000601 for 4
