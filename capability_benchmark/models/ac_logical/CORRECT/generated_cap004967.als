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

pred cap004967 { not ((inv9 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and some CapBenchA) or no CapBenchA)) }
pred cap004967c { ((not ((some CapBenchA and some CapBenchA) or no CapBenchA)) or (not (inv9 and ((no CapBenchB or no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004967 { cap004967 iff cap004967c }
check CapBenchEquivalent_cap004967 for 4
