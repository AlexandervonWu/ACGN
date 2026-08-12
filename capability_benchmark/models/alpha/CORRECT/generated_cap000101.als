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

pred cap000101 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv9 and ((some capBenchS or some capBenchR) or some CapBenchB))) }
pred cap000101c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv9 and ((some capBenchS or some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap000101 { cap000101 iff cap000101c }
check CapBenchEquivalent_cap000101 for 4
