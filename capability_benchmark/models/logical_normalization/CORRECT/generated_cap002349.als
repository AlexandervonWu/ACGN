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

pred cap002349 { not ((inv9 and ((some capBenchS or no CapBenchB) or some capBenchS)) and ((no CapBenchA and some CapBenchB) and some CapBenchA)) }
pred cap002349c { ((not (inv9 and ((some capBenchS or no CapBenchB) or some capBenchS))) or (not ((no CapBenchA and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002349 { cap002349 iff cap002349c }
check CapBenchEquivalent_cap002349 for 4
