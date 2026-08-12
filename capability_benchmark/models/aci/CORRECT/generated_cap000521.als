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

pred cap000521 { (inv9 and ((some capBenchS or no CapBenchA) or some CapBenchA)) }
pred cap000521c { ((inv9 and ((some capBenchS or no CapBenchA) or some CapBenchA)) or (inv9 and ((some capBenchS or no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap000521 { cap000521 iff cap000521c }
check CapBenchEquivalent_cap000521 for 4
