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

pred cap004744 { not ((inv5 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004744c { ((not ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv5 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004744 { cap004744 iff cap004744c }
check CapBenchEquivalent_cap004744 for 4
