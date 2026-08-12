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

pred cap002109 { not ((inv2 and ((some capBenchS or some capBenchS) or some CapBenchB)) and ((no CapBenchA and no CapBenchB) and some capBenchR)) }
pred cap002109c { ((not (inv2 and ((some capBenchS or some capBenchS) or some CapBenchB))) or (not ((no CapBenchA and no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002109 { cap002109 iff cap002109c }
check CapBenchEquivalent_cap002109 for 4
