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

pred cap000757 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
pred cap000757c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000757 { cap000757 iff cap000757c }
check CapBenchEquivalent_cap000757 for 4
