import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.jar.JarEntry;
import java.util.jar.JarOutputStream;
import java.util.zip.GZIPInputStream;
import java.util.zip.ZipEntry;

/** Restore recorded archive entry order and times to reproduce a measured JAR from clean classes. */
public final class ReassembleJar {
    public static void main(String[] args) throws Exception {
        if (args.length != 3) throw new IllegalArgumentException("expected entries.tsv.gz classes output.jar");
        Path classes = Path.of(args[1]).toRealPath();
        try (var input = new BufferedReader(new InputStreamReader(
                new GZIPInputStream(Files.newInputStream(Path.of(args[0]))), StandardCharsets.UTF_8));
             var output = new JarOutputStream(Files.newOutputStream(Path.of(args[2]), StandardOpenOption.CREATE_NEW))) {
            for (String line; (line = input.readLine()) != null;) {
                String[] row = line.split("\t", -1);
                if (row.length != 4) throw new IllegalArgumentException("invalid entry metadata");
                var entry = new JarEntry(row[0]);
                entry.setTimeLocal(LocalDateTime.parse(row[1]));
                entry.setMethod(Integer.parseInt(row[2]));
                if (entry.getMethod() == ZipEntry.STORED) {
                    if (!entry.isDirectory()) throw new IllegalArgumentException("unexpected uncompressed payload");
                    entry.setSize(0);
                    entry.setCrc(0);
                }
                output.putNextEntry(entry);
                if (entry.getName().equals("META-INF/MANIFEST.MF")) {
                    output.write(Base64.getDecoder().decode(row[3]));
                } else if (!entry.isDirectory()) {
                    Path file = classes.resolve(entry.getName()).toRealPath();
                    if (!file.startsWith(classes) || !entry.getName().endsWith(".class")) {
                        throw new IllegalArgumentException("unexpected classfile path");
                    }
                    Files.copy(file, output);
                }
                output.closeEntry();
            }
        }
    }
}
