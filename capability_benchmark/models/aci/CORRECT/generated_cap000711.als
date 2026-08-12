sig Person  {
	Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv10 {
all c : Class, s : Student | some g : Group | c->s->g in Groups
}

pred inv10c {
  all c:Class,s:Student | some s.(c.Groups)
}

check correct { inv10 <=> inv10c}
pred under { inv10 and !inv10c}
pred over { !inv10 and inv10c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000711 { ((inv10 and ((no CapBenchB or no CapBenchA) and no CapBenchB)) or ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA)) }
pred cap000711c { (((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA) or (inv10 and ((no CapBenchB or no CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap000711 { cap000711 iff cap000711c }
check CapBenchEquivalent_cap000711 for 4
