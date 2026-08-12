sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
trans in State -> some Event -> State
}

pred inv1c {
	all s:State | some s.trans
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002696 { not (((inv1 and ((some capBenchR and some CapBenchA) or no CapBenchB))) until (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap002696c { ((not (inv1 and ((some capBenchR and some CapBenchA) or no CapBenchB))) releases (not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap002696 { cap002696 iff cap002696c }
check CapBenchEquivalent_cap002696 for 4
