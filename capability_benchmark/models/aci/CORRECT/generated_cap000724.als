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

pred cap000724 { (inv2 and ((some CapBenchA and some capBenchR) or no CapBenchB)) }
pred cap000724c { ((inv2 and ((some CapBenchA and some capBenchR) or no CapBenchB)) and (inv2 and ((some CapBenchA and some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap000724 { cap000724 iff cap000724c }
check CapBenchEquivalent_cap000724 for 4
