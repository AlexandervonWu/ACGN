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

pred cap003122 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)) }
pred cap003122c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003122 { cap003122 iff cap003122c }
check CapBenchEquivalent_cap003122 for 4
