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

pred cap003173 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or some capBenchS) or no CapBenchA)) and ((no CapBenchA and no CapBenchB) and some capBenchS)) }
pred cap003173c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv2 and ((some capBenchS or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap003173 { cap003173 iff cap003173c }
check CapBenchEquivalent_cap003173 for 4
