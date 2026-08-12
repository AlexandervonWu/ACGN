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
all x: Photo | one posts.x
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

pred cap005168 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and some capBenchS) or no CapBenchA)) and ((some capBenchS or no CapBenchA) or some capBenchS))) }
pred cap005168c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchA) or some capBenchS)) or (not (inv1 and ((some CapBenchA and some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005168 { cap005168 iff cap005168c }
check CapBenchEquivalent_cap005168 for 4
