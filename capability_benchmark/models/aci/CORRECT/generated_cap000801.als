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

pred cap000801 { ((inv2 and ((some capBenchS or some capBenchS) or some capBenchR)) or ((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB) or ((some CapBenchA and some CapBenchB) or no CapBenchA)) }
pred cap000801c { (((no CapBenchA and no CapBenchB) and CapBenchA in CapBenchA + CapBenchB) or ((some CapBenchA and some CapBenchB) or no CapBenchA) or (inv2 and ((some capBenchS or some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap000801 { cap000801 iff cap000801c }
check CapBenchEquivalent_cap000801 for 4
