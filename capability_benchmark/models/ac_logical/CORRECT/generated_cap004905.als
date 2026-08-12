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

pred cap004905 { not ((inv9 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some CapBenchA) and some CapBenchB)) }
pred cap004905c { ((not ((no CapBenchA and some CapBenchA) and some CapBenchB)) or (not (inv9 and ((some capBenchS or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004905 { cap004905 iff cap004905c }
check CapBenchEquivalent_cap004905 for 4
