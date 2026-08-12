sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some f: File | f in Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004763 { not ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004763c { ((not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap004763 { cap004763 iff cap004763c }
check CapBenchEquivalent_cap004763 for 4
