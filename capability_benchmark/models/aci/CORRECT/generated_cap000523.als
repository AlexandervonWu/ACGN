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

pred cap000523 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap000523c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv9 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap000523 { cap000523 iff cap000523c }
check CapBenchEquivalent_cap000523 for 4
