sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s,s1,s2:State,e:Event | s->e->s1 in trans and s->e->s2 in trans implies s1=s2
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003476 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or some CapBenchB) or no CapBenchA)) }
pred cap003476c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003476 { cap003476 iff cap003476c }
check CapBenchEquivalent_cap003476 for 4
