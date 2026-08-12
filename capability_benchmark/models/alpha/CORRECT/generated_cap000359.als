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

pred cap000359 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
pred cap000359c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv7 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap000359 { cap000359 iff cap000359c }
check CapBenchEquivalent_cap000359 for 4
