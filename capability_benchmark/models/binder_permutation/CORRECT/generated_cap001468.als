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

pred cap001468 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001468c { all a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap001468 { cap001468 iff cap001468c }
check CapBenchEquivalent_cap001468 for 4
