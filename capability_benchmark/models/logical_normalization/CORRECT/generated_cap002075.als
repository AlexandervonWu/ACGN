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

pred cap002075 { ((inv2 and ((no CapBenchB or some CapBenchB) and some CapBenchB)) iff ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
pred cap002075c { (((not (inv2 and ((no CapBenchB or some CapBenchB) and some CapBenchB))) or ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) and ((not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) or (inv2 and ((no CapBenchB or some CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap002075 { cap002075 iff cap002075c }
check CapBenchEquivalent_cap002075 for 4
