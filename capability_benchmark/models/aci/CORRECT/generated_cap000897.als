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

pred cap000897 { ((inv9 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA) or ((some CapBenchA and some capBenchS) or no CapBenchB)) }
pred cap000897c { (((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and some CapBenchA) or ((some CapBenchA and some capBenchS) or no CapBenchB) or (inv9 and ((some capBenchS or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000897 { cap000897 iff cap000897c }
check CapBenchEquivalent_cap000897 for 4
