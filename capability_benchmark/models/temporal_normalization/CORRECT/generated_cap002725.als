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

pred cap002725 { not once ((inv2 and ((some CapBenchB or some capBenchR) or no CapBenchB))) }
pred cap002725c { historically (not (inv2 and ((some CapBenchB or some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap002725 { cap002725 iff cap002725c }
check CapBenchEquivalent_cap002725 for 4
