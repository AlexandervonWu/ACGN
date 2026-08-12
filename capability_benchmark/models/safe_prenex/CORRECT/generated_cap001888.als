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

pred cap001888 { ((some x: CapBenchA | x->x in capBenchR) and (inv9 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001888c { (some x: CapBenchA | (x->x in capBenchR and (inv9 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001888 { cap001888 iff cap001888c }
check CapBenchEquivalent_cap001888 for 4
