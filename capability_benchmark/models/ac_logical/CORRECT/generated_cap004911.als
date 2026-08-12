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

pred cap004911 { not ((inv9 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and some CapBenchB) or some CapBenchB)) }
pred cap004911c { ((not ((some CapBenchA and some CapBenchB) or some CapBenchB)) or (not (inv9 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004911 { cap004911 iff cap004911c }
check CapBenchEquivalent_cap004911 for 4
