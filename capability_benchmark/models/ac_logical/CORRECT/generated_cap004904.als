sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e:Event | some s1,s2:State | s1->e->s2 in trans
}

pred inv6c {
	State.trans.State = Event
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004904 { not ((inv6 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchB or some CapBenchA) or some CapBenchB)) }
pred cap004904c { ((not ((some CapBenchB or some CapBenchA) or some CapBenchB)) or (not (inv6 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004904 { cap004904 iff cap004904c }
check CapBenchEquivalent_cap004904 for 4
