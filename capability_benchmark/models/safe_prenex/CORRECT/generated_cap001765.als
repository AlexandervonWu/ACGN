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

pred cap001765 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
pred cap001765c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((some CapBenchB or some CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap001765 { cap001765 iff cap001765c }
check CapBenchEquivalent_cap001765 for 4
