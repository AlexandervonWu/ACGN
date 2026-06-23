module alloy4fun_augmented_trash_rl_inv8
open util/integer [] as integer
sig File {
link: (set File)
}
sig Trash in File {}
sig Protected in File {}

pred inv8_oracle[] {
(no link)
}

pred inv8_correct_0[] {
(all f: (one File) {
(no ((f.link) & File))
})
}

pred inv8_correct_1[] {
(all file: (one File) {
((file.link) = none)
})
}

pred inv8_correct_2[] {
(no link)
}

pred inv8_correct_3[] {
(all f: (one File) {
(no (f.link))
})
}

pred inv8_correct_4[] {
(no (link.File))
}

pred inv8_correct_5[] {
(all f1,f2: (one File) {
(!((f1->f2) in link))
})
}

pred inv8_correct_6[] {
(all f,l: (one File) {
((f->l) !in link)
})
}

pred inv8_correct_7[] {
(all f: (one File) {
(no (f->link))
})
}

pred inv8_correct_8[] {
(no (File.link))
}

pred inv8_correct_9[] {
(link in (none->none))
}

pred inv8_correct_10[] {
(all x: (one File),y: (one File) {
((x->y) !in link)
})
}

pred inv8_correct_11[] {
((no (link.File)) && (no link))
}

pred inv8_correct_12[] {
(all x: (one File) {
(no (x.link))
})
}

