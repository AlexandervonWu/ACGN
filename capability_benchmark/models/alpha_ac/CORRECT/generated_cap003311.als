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

pred cap003311 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003311c { all renamed: CapBenchA | (((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap003311 { cap003311 iff cap003311c }
check CapBenchEquivalent_cap003311 for 4
