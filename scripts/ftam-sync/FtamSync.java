import java.awt.BorderLayout;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.util.ArrayDeque;
import java.util.Deque;
import javax.swing.BorderFactory;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JTextArea;
import javax.swing.JWindow;
import javax.swing.SwingUtilities;

/**
 * CurseForge's Play for the FTAM profile: play.ps1 sets the profile's Java arguments to
 * -javaagent:ftam-sync.jar, so this runs before Minecraft and Forge, while the mods folder is still free.
 * It runs play.ps1 -SyncProfile on the profile, the CurseForge twin of Prism's pre-launch command.
 * CurseForge starts Java in the profile folder, which holds this jar and ftam-sync.repo, the checkout's path.
 */
public final class FtamSync {
    public static void premain(String args) throws Exception {
        File profile = new File(System.getProperty("user.dir"));
        File repoFile = new File(profile, "ftam-sync.repo");
        if (!repoFile.isFile()) {
            System.out.println("[ftam-sync] No ftam-sync.repo in " + profile + ", starting without updating.");
            return;
        }
        String repo = new String(Files.readAllBytes(repoFile.toPath()), "UTF-8").trim();
        File script = new File(repo, "scripts" + File.separator + "play.ps1");
        if (!script.isFile()) {
            fail("The FTAM pack checkout isn't at " + repo + " anymore. Run play.cmd from where it is now.", "");
            return;
        }

        JWindow window = showProgress();
        Deque<String> tail = new ArrayDeque<String>();
        int exit;
        try {
            Process process = new ProcessBuilder("powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass",
                    "-File", script.getPath(), "-SyncProfile", profile.getPath())
                    .redirectErrorStream(true).start();
            process.getOutputStream().close();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), Charset.defaultCharset()));
            for (String line; (line = reader.readLine()) != null; ) {
                System.out.println("[ftam-sync] " + line);
                tail.addLast(line);
                if (tail.size() > 12) tail.removeFirst();
            }
            exit = process.waitFor();
        } catch (Exception e) {
            tail.addLast(e.toString());
            exit = -1;
        } finally {
            window.dispose();
        }
        if (exit != 0) {
            fail("The pack couldn't update.", String.join("\n", tail).trim());
        }
    }

    private static JWindow showProgress() throws Exception {
        final JWindow[] window = new JWindow[1];
        SwingUtilities.invokeAndWait(() -> {
            JProgressBar bar = new JProgressBar();
            bar.setIndeterminate(true);
            JLabel label = new JLabel("Updating FTAM Classic: Origins");
            label.setBorder(BorderFactory.createEmptyBorder(0, 0, 8, 0));
            JPanel panel = new JPanel(new BorderLayout());
            panel.setBorder(BorderFactory.createEmptyBorder(16, 20, 16, 20));
            panel.add(label, BorderLayout.NORTH);
            panel.add(bar, BorderLayout.CENTER);
            window[0] = new JWindow();
            window[0].setContentPane(panel);
            window[0].setSize(320, 80);
            window[0].setLocationRelativeTo(null);
            window[0].setAlwaysOnTop(true);
            window[0].setVisible(true);
        });
        return window[0];
    }

    /** Asks whether to play the pack as it is, and quits the game if not. */
    private static void fail(String message, String detail) {
        Object body = message;
        if (!detail.isEmpty()) {
            JTextArea text = new JTextArea(detail);
            text.setEditable(false);
            text.setRows(Math.min(12, detail.split("\n").length));
            body = new Object[] { message, text };
        }
        String[] options = { "Quit", "Play anyway" };
        int choice = JOptionPane.showOptionDialog(null, body, "FTAM Classic: Origins",
                JOptionPane.DEFAULT_OPTION, JOptionPane.ERROR_MESSAGE, null, options, options[0]);
        if (choice != 1) System.exit(1);
    }
}
