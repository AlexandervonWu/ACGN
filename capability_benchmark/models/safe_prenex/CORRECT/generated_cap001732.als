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

pred cap001732 { ((some x: CapBenchA | x->x in capBenchR) and (inv9 and ((some CapBenchA and some capBenchS) or no CapBenchB))) }
pred cap001732c { (some x: CapBenchA | (x->x in capBenchR and (inv9 and ((some CapBenchA and some capBenchS) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001732 { cap001732 iff cap001732c }
check CapBenchEquivalent_cap001732 for 4
