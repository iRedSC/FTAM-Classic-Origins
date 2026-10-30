# WorldEdit 6.1.1 WECUI fix

WorldEdit 6.1.1 for Forge 1.7.10 kicks any client running WorldEditCUI from a dedicated server ("A fatal error has occured"). Its `WECUIPacketHandler` calls `FMLProxyPacket.toC17Packet()`, whose `C17PacketCustomPayload` constructor only exists on the client.

`Patch.java` rewrites that handler to read the payload with `WECUIPayload.bytes` instead. To rebuild `mods/server/worldedit-forge-mc1.7.10-6.1.1-ftam1.jar` with a Java 8 JDK:

```sh
javac -source 1.6 -target 1.6 -cp minecraft_server.1.7.10.jar -d out src/com/sk89q/worldedit/forge/WECUIPayload.java
javac -cp asm-all-5.0.3.jar Patch.java
unzip -o worldedit-forge-mc1.7.10-6.1.1-dist.jar com/sk89q/worldedit/forge/WECUIPacketHandler.class
java -cp asm-all-5.0.3.jar:. Patch com/sk89q/worldedit/forge/WECUIPacketHandler.class out/com/sk89q/worldedit/forge/WECUIPacketHandler.class
cp worldedit-forge-mc1.7.10-6.1.1-dist.jar patched.jar && (cd out && jar uf ../patched.jar com)
```

`minecraft_server.1.7.10.jar` (for netty) and `asm-all-5.0.3.jar` come from a server folder made by `scripts/server.sh`.
