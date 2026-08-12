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
all p:Photo| one u:User| u->p in posts
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

pred cap002036 { not not ((inv1 and ((some capBenchR and some capBenchR) or some CapBenchA))) }
pred cap002036c { (inv1 and ((some capBenchR and some capBenchR) or some CapBenchA)) }
assert CapBenchEquivalent_cap002036 { cap002036 iff cap002036c }
check CapBenchEquivalent_cap002036 for 4
