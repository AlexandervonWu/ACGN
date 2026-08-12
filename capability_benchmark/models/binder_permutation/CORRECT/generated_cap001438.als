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

pred cap001438 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001438c { all a, b: CapBenchA | (b->a in capBenchR and (inv7 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001438 { cap001438 iff cap001438c }
check CapBenchEquivalent_cap001438 for 4
