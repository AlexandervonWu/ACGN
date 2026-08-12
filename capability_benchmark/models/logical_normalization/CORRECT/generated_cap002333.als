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
all u: User | u -> u not in follows
all u: User | u not in u.follows
follows - iden = follows
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

pred cap002333 { ((inv2 and ((some capBenchS or some CapBenchB) or some capBenchS)) iff ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap002333c { (((not (inv2 and ((some capBenchS or some CapBenchB) or some capBenchS))) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (inv2 and ((some capBenchS or some CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap002333 { cap002333 iff cap002333c }
check CapBenchEquivalent_cap002333 for 4
