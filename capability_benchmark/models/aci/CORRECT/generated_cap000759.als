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

pred cap000759 { ((inv8 and ((no CapBenchB or some CapBenchA) and some capBenchR)) or ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB)) }
pred cap000759c { (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB) or (inv8 and ((no CapBenchB or some CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000759 { cap000759 iff cap000759c }
check CapBenchEquivalent_cap000759 for 4
