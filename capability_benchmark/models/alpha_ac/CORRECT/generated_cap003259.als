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

pred cap003259 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((no CapBenchB or some CapBenchA) and some capBenchR)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003259c { all renamed: CapBenchA | (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv2 and ((no CapBenchB or some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap003259 { cap003259 iff cap003259c }
check CapBenchEquivalent_cap003259 for 4
