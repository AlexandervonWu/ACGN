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

pred cap000582 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv9 and ((no CapBenchA and no CapBenchA) and some CapBenchB))) }
pred cap000582c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv9 and ((no CapBenchA and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000582 { cap000582 iff cap000582c }
check CapBenchEquivalent_cap000582 for 4
