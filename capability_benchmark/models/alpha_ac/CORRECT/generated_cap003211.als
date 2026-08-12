sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s : State | some s.trans
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

pred cap003211 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or no CapBenchA) and no CapBenchB)) and ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003211c { all renamed: CapBenchA | (((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchB or no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap003211 { cap003211 iff cap003211c }
check CapBenchEquivalent_cap003211 for 4
