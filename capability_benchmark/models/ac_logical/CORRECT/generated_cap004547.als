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

pred cap004547 { not ((inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA)) and ((some capBenchR and no CapBenchB) or no CapBenchB)) }
pred cap004547c { ((not ((some capBenchR and no CapBenchB) or no CapBenchB)) or (not (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004547 { cap004547 iff cap004547c }
check CapBenchEquivalent_cap004547 for 4
