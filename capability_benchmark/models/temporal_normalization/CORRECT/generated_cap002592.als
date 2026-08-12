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

pred cap002592 { not historically ((inv9 and ((some capBenchR and no CapBenchB) or some CapBenchB))) }
pred cap002592c { once (not (inv9 and ((some capBenchR and no CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002592 { cap002592 iff cap002592c }
check CapBenchEquivalent_cap002592 for 4
