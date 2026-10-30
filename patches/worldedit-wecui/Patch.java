import org.objectweb.asm.*;
import org.objectweb.asm.tree.*;
import java.nio.file.*;

// Rewrites WECUIPacketHandler.onPacketData to use WECUIPayload.bytes instead of the client-only C17 conversion.
public class Patch {
    public static void main(String[] a) throws Exception {
        ClassNode cn = new ClassNode();
        new ClassReader(Files.readAllBytes(Paths.get(a[0]))).accept(cn, ClassReader.SKIP_FRAMES);
        int replaced = 0;
        for (Object o : cn.methods) { MethodNode m = (MethodNode) o;
            if (!m.name.equals("onPacketData")) continue;
            for (AbstractInsnNode n : m.instructions.toArray()) {
                if (n instanceof MethodInsnNode && ((MethodInsnNode) n).name.equals("toC17Packet")) {
                    m.instructions.set(n, new MethodInsnNode(Opcodes.INVOKESTATIC,
                        "com/sk89q/worldedit/forge/WECUIPayload", "bytes", "(Ljava/lang/Object;)[B", false));
                    replaced++;
                } else if (n instanceof TypeInsnNode && n.getOpcode() == Opcodes.CHECKCAST
                        && ((TypeInsnNode) n).desc.equals("net/minecraft/network/play/client/C17PacketCustomPayload")) {
                    m.instructions.remove(n);
                    replaced++;
                } else if (n instanceof MethodInsnNode && ((MethodInsnNode) n).name.equals("func_149558_e")) {
                    m.instructions.remove(n);
                    replaced++;
                }
            }
            // bytes() declares Exception; the handler doesn't, which the JVM allows, so no frame changes beyond these.
        }
        if (replaced != 3) throw new IllegalStateException("expected 3 patch sites, found " + replaced);
        // Only merges between unrelated MC types happen here; Object is a safe common supertype.
        ClassWriter cw = new ClassWriter(ClassWriter.COMPUTE_FRAMES) {
            @Override protected String getCommonSuperClass(String x, String y) { return "java/lang/Object"; }
        };
        cn.accept(cw);
        Files.write(Paths.get(a[1]), cw.toByteArray());
        System.out.println("patched " + replaced + " sites");
    }
}
