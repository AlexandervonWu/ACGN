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

pred cap002888 { not (((inv6 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) until (((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap002888c { ((not (inv6 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) releases (not ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap002888 { cap002888 iff cap002888c }
check CapBenchEquivalent_cap002888 for 4
