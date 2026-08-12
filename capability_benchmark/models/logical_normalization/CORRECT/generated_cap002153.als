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

pred cap002153 { ((inv9 and ((some CapBenchB or no CapBenchB) or no CapBenchA)) iff ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)) }
pred cap002153c { (((not (inv9 and ((some CapBenchB or no CapBenchB) or no CapBenchA))) or ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)) and ((not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)) or (inv9 and ((some CapBenchB or no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap002153 { cap002153 iff cap002153c }
check CapBenchEquivalent_cap002153 for 4
