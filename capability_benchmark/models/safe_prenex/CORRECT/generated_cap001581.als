sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv7 {
all t:Track | no t & t.(^succs)
}

pred inv7c {
	no t : Track | t in t.^succs
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001581 { ((all x: CapBenchA | x->x in capBenchR) or (inv7 and ((some CapBenchB or no CapBenchA) or some CapBenchB))) }
pred cap001581c { (all x: CapBenchA | (x->x in capBenchR or (inv7 and ((some CapBenchB or no CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001581 { cap001581 iff cap001581c }
check CapBenchEquivalent_cap001581 for 4
