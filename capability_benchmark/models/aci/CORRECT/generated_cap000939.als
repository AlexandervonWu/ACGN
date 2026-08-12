sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv8 {
all f : File | no f.link
}

pred inv8c {
	no link
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000939 { ((inv8 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA))) or ((some capBenchR and some capBenchR) or some CapBenchB) or ((no CapBenchA and no CapBenchA) and some capBenchR)) }
pred cap000939c { (((some capBenchR and some capBenchR) or some CapBenchB) or ((no CapBenchA and no CapBenchA) and some capBenchR) or (inv8 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000939 { cap000939 iff cap000939c }
check CapBenchEquivalent_cap000939 for 4
