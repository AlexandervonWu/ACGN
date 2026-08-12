sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5 {
all t : Track | t in Junction <=> #(succs.t) > 1
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

pred cap002031 { not ((inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA)) and ((some capBenchR and some CapBenchB) or no CapBenchB)) }
pred cap002031c { ((not (inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchA))) or (not ((some capBenchR and some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap002031 { cap002031 iff cap002031c }
check CapBenchEquivalent_cap002031 for 4
