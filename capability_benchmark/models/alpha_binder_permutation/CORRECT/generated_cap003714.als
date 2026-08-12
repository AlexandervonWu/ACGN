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

pred cap003714 { all x, y: CapBenchA | (x->y in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
pred cap003714c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv9 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap003714 { cap003714 iff cap003714c }
check CapBenchEquivalent_cap003714 for 4
