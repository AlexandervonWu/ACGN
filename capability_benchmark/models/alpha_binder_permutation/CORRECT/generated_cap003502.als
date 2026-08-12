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

pred cap003502 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((no CapBenchA and some CapBenchA) and some CapBenchA))) }
pred cap003502c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv9 and ((no CapBenchA and some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap003502 { cap003502 iff cap003502c }
check CapBenchEquivalent_cap003502 for 4
