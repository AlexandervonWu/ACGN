public final class UnicodeOrderWitness {
    public static void main(String[] args) {
        String supplementary = new String(Character.toChars(0x10000));
        String bmp = "\uE000";
        if (supplementary.compareTo(bmp) >= 0) throw new AssertionError("UTF-16 witness");
        System.out.println("Java UTF-16: U+10000 < U+E000");
    }
}
