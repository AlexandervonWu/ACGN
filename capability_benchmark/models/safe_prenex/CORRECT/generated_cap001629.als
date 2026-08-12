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

pred cap001629 { ((all x: CapBenchA | x->x in capBenchR) or (inv2 and ((some CapBenchB or some CapBenchA) or no CapBenchA))) }
pred cap001629c { (all x: CapBenchA | (x->x in capBenchR or (inv2 and ((some CapBenchB or some CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001629 { cap001629 iff cap001629c }
check CapBenchEquivalent_cap001629 for 4
