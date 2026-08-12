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

pred cap003319 { all x: CapBenchA | (x->x in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003319c { all renamed: CapBenchA | (((some capBenchR and some capBenchS) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003319 { cap003319 iff cap003319c }
check CapBenchEquivalent_cap003319 for 4
