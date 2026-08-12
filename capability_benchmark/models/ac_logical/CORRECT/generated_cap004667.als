sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv9 {
all t : Track | (no t.succs & Junction) implies no (t.signals & Semaphore)
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

pred cap004667 { not ((inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA)) and ((some capBenchR and no CapBenchA) or some capBenchS)) }
pred cap004667c { ((not ((some capBenchR and no CapBenchA) or some capBenchS)) or (not (inv9 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004667 { cap004667 iff cap004667c }
check CapBenchEquivalent_cap004667 for 4
