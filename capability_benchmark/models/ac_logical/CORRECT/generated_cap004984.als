sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5 {
all t:Track | t in Junction iff #(succs.t) > 1
}

pred inv5c {
	all t : Track | t not in Junction iff lone succs.t
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004984 { not ((inv5 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or no CapBenchA) or no CapBenchA)) }
pred cap004984c { ((not ((some CapBenchB or no CapBenchA) or no CapBenchA)) or (not (inv5 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004984 { cap004984 iff cap004984c }
check CapBenchEquivalent_cap004984 for 4
