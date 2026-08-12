sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s: State | some s.trans
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

pred cap000911 { (inv1 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000911c { ((inv1 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (inv1 and ((no CapBenchB or no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000911 { cap000911 iff cap000911c }
check CapBenchEquivalent_cap000911 for 4
