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

pred cap001786 { ((some x: CapBenchA | x->x in capBenchR) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR))) }
pred cap001786c { (some x: CapBenchA | (x->x in capBenchR and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap001786 { cap001786 iff cap001786c }
check CapBenchEquivalent_cap001786 for 4
