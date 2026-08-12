sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv9 {
all t: Track | no Junction & t.succs => no Semaphore & t.signals
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

pred cap003031 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA)) and ((some capBenchR and some CapBenchB) or no CapBenchB)) }
pred cap003031c { all renamed: CapBenchA | (((some capBenchR and some CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003031 { cap003031 iff cap003031c }
check CapBenchEquivalent_cap003031 for 4
