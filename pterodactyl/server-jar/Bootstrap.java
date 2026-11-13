import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

/**
 * ftam-server.jar: lets a panel that can only run `java -jar server.jar` run the pack. It runs bootstrap.sh in the
 * server folder with this process's console, so the panel's console and its stop command reach the server.
 * Compiled for Java 8 so it starts on any image.
 */
public final class Bootstrap {
    public static void main(String[] args) throws Exception {
        Path script = Files.createTempFile("ftam-bootstrap", ".sh");
        try (InputStream in = Bootstrap.class.getResourceAsStream("/bootstrap.sh")) {
            Files.copy(in, script, StandardCopyOption.REPLACE_EXISTING);
        }
        Process p = new ProcessBuilder("bash", script.toString()).inheritIO().start();
        int code = p.waitFor();
        Files.deleteIfExists(script);
        System.exit(code);
    }
}
