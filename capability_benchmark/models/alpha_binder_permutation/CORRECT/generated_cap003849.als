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

pred cap003849 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((some capBenchS or no CapBenchB) or some capBenchS))) }
pred cap003849c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv9 and ((some capBenchS or no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap003849 { cap003849 iff cap003849c }
check CapBenchEquivalent_cap003849 for 4
