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

pred cap003185 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS)) }
pred cap003185c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS) and renamed->renamed in capBenchR and (inv9 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003185 { cap003185 iff cap003185c }
check CapBenchEquivalent_cap003185 for 4
