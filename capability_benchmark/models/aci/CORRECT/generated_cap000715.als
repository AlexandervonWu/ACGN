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

pred cap000715 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB))) }
pred cap000715c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap000715 { cap000715 iff cap000715c }
check CapBenchEquivalent_cap000715 for 4
