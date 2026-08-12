sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all t:Track | t in Entry <=> t not in Track.^succs
}

pred inv4c {
	all t : Track | t in Entry iff no succs.t
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004548 { not ((inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((some capBenchS or no CapBenchB) or no CapBenchB)) }
pred cap004548c { ((not ((some capBenchS or no CapBenchB) or no CapBenchB)) or (not (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004548 { cap004548 iff cap004548c }
check CapBenchEquivalent_cap004548 for 4
