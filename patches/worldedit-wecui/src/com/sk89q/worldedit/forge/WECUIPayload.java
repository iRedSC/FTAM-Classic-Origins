package com.sk89q.worldedit.forge;

import io.netty.buffer.ByteBuf;

/**
 * FTAM patch: reads a WECUI packet's bytes without FMLProxyPacket.toC17Packet(),
 * whose C17PacketCustomPayload constructor only exists on the client.
 */
public final class WECUIPayload {
    private WECUIPayload() {}

    public static byte[] bytes(Object fmlProxyPacket) throws Exception {
        ByteBuf buf = (ByteBuf) fmlProxyPacket.getClass().getMethod("payload").invoke(fmlProxyPacket);
        byte[] out = new byte[buf.readableBytes()];
        buf.getBytes(buf.readerIndex(), out);
        return out;
    }
}
