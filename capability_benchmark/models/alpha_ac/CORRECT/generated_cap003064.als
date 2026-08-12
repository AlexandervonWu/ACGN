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

pred cap003064 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or some CapBenchB)) and ((some capBenchS or some capBenchS) or no CapBenchB)) }
pred cap003064c { all renamed: CapBenchA | (((some capBenchS or some capBenchS) or no CapBenchB) and renamed->renamed in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003064 { cap003064 iff cap003064c }
check CapBenchEquivalent_cap003064 for 4
