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

pred inv1 {
all x : Photo | one posts.x
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005394 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
pred cap005394c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) or (not (inv1 and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005394 { cap005394 iff cap005394c }
check CapBenchEquivalent_cap005394 for 4
