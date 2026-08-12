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

pred cap004640 { not ((inv9 and ((some capBenchR and some CapBenchB) or no CapBenchA)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap004640c { ((not ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) or (not (inv9 and ((some capBenchR and some CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004640 { cap004640 iff cap004640c }
check CapBenchEquivalent_cap004640 for 4
