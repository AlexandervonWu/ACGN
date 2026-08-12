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
all x : User | x not in follows.x
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

pred cap000775 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap000775c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((no CapBenchB or no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000775 { cap000775 iff cap000775c }
check CapBenchEquivalent_cap000775 for 4
