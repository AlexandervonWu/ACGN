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

pred inv5 {
all i:Influencer | follows.i = (User-i)
}

pred inv5c {
	all i : Influencer | follows.i = User - i
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002249 { ((inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) iff ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap002249c { (((not (inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) or (inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap002249 { cap002249 iff cap002249c }
check CapBenchEquivalent_cap002249 for 4
