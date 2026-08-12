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

pred cap004907 { not ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchR and some CapBenchA) or some CapBenchB)) }
pred cap004907c { ((not ((some capBenchR and some CapBenchA) or some CapBenchB)) or (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004907 { cap004907 iff cap004907c }
check CapBenchEquivalent_cap004907 for 4
