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
all u:User | u not in follows.u
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

pred cap002021 { ((inv2 and ((some capBenchS or no CapBenchA) or some CapBenchA)) iff ((no CapBenchA and some CapBenchA) and no CapBenchB)) }
pred cap002021c { (((not (inv2 and ((some capBenchS or no CapBenchA) or some CapBenchA))) or ((no CapBenchA and some CapBenchA) and no CapBenchB)) and ((not ((no CapBenchA and some CapBenchA) and no CapBenchB)) or (inv2 and ((some capBenchS or no CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap002021 { cap002021 iff cap002021c }
check CapBenchEquivalent_cap002021 for 4
