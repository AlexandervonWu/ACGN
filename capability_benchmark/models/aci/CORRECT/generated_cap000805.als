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
all x : User | x not in x.follows
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

pred cap000805 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap000805c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap000805 { cap000805 iff cap000805c }
check CapBenchEquivalent_cap000805 for 4
