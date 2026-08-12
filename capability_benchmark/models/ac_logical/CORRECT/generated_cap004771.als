sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv5 {
all f : File| f not in Protected => f in Trash
}

pred inv5c {
  	File = Trash + Protected
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004771 { not ((inv5 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004771c { ((not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv5 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap004771 { cap004771 iff cap004771c }
check CapBenchEquivalent_cap004771 for 4
