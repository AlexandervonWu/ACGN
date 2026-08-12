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
all x : User | x -> x not in follows
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

pred cap002604 { not historically ((inv2 and ((some CapBenchA and some capBenchS) or some CapBenchB))) }
pred cap002604c { once (not (inv2 and ((some CapBenchA and some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap002604 { cap002604 iff cap002604c }
check CapBenchEquivalent_cap002604 for 4
