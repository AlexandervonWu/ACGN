sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv9 {
all t : Track | (no t.succs & Junction) implies no (t.signals & Semaphore)
}

pred inv9c {
	all t : Track | no t.succs & Junction implies no t.signals & Semaphore
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004293 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv9 and ((some capBenchS or some capBenchR) or some capBenchR))) }
pred cap004293c { some a, b: CapBenchA | (b->a in capBenchR and (inv9 and ((some capBenchS or some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap004293 { cap004293 iff cap004293c }
check CapBenchEquivalent_cap004293 for 4
