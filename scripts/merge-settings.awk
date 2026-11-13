# Puts the pack's lines into one settings file the server or player also owns. play.ps1 does the same in PowerShell;
# scripts/test-settings.sh checks the two agree.
#
#   awk -v SEP='=' -v FILE=config/x.cfg -v NEWSTATE=<file> -f merge-settings.awk \
#       part=state <state> part=once <settings/once/...> part=always <settings/always/...> part=target <current>
#
# A line's identity is its section (an INI [header], or the path of Forge `name {` categories) and its key: the text
# before SEP, or what a `# key: <key>` comment on the line above says, for files whose lines share a first word
# (Xaero's `interface:<name>:...`). A target line has a key when it starts with it and then SEP. The pack owns every
# identity its files name: their lines replace all of the target's lines with that
# identity, where the first of them was, so a key repeated as a list is replaced as a whole. An identity the target
# lacks goes at the end of its section, or a new INI section at the end. Once lines apply only if this exact line
# isn't in the state file yet; NEWSTATE gets a line for each one applied. Always lines win over once lines.

function trim(s) { sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }

function keyof(t,   i) {
    if (t == "" || t ~ /^(;|#|\/\/)/) return ""
    i = index(t, SEP)
    return i <= 1 ? "" : trim(substr(t, 1, i - 1))
}

function path(   i, p) {
    p = ""
    for (i = 1; i <= depth; i++) p = p (i > 1 ? "." : "") stack[i]
    return p
}

# Sets KIND (ini, open, close, key, other), KEY, and the running section SEC (with SECKIND ini or forge).
function classify(line,   t, name) {
    t = trim(line); KEY = ""
    if (t ~ /^\[.+\]$/) { SEC = substr(t, 2, length(t) - 2); SECKIND = "ini"; KIND = "ini"; return }
    if (t ~ /\{$/) {
        name = trim(substr(t, 1, length(t) - 1)); gsub(/"/, "", name)
        stack[++depth] = name; SEC = path(); SECKIND = "forge"; KIND = "open"; return
    }
    if (t == "}" && depth > 0) { CLOSED = SEC; depth--; SEC = path(); KIND = "close"; return }
    KEY = keyof(t); KIND = KEY == "" ? "other" : "key"
}

function id(sec, key) { return tolower(sec) SUBSEP tolower(key) }

part != lastpart { lastpart = part; SEC = ""; SECKIND = ""; depth = 0 }

# The state file is written with "\n" (see END), but a CRLF one from an older run must still match.
part == "state" { sub(/\r$/, ""); seen[$0] = 1; next }

part == "once" || part == "always" {
    sub(/\r$/, "")
    if (match($0, /^[ \t]*#[ \t]*key:[ \t]*/)) { named = trim(substr($0, RLENGTH + 1)); next }
    classify($0)
    if (KIND != "key") next
    if (named != "") { KEY = named; named = "" }
    k = id(SEC, KEY)
    if (!((part, k) in lines)) {
        order[part, ++count[part]] = k
        lines[part, k] = ""
        sec[k] = SEC; seckind[k] = SECKIND
    }
    if (!(k in keyname)) {
        keyname[k] = KEY
        # Longest keys first, so `interface:gui.xaero_minimap` claims its line before a plain `interface` would.
        for (j = ++keys; j > 1 && length(keyname[keylist[j - 1]]) < length(KEY); j--) keylist[j] = keylist[j - 1]
        keylist[j] = k
    }
    lines[part, k] = lines[part, k] (lines[part, k] == "" ? "" : "\n") trim($0)
    next
}

part == "target" {
    if ($0 ~ /\r$/) crlf = 1
    sub(/\r$/, "")
    n++
    row[n] = $0
    classify($0)
    rkind[n] = KIND; rsec[n] = SEC; rseckind[n] = SECKIND
    rid[n] = KIND == "key" ? owner_of(SEC, trim($0)) : ""
    if (KIND == "close") rclosed[n] = CLOSED
    match($0, /^[ \t]*/); rindent[n] = substr($0, 1, RLENGTH)
}

# The pack identity a target line in section s has: the longest pack key in s the line starts with, then SEP.
function owner_of(s, t,   j, k, rest) {
    for (j = 1; j <= keys; j++) {
        k = keylist[j]
        if (tolower(sec[k]) != tolower(s)) continue
        if (tolower(substr(t, 1, length(keyname[k]))) != tolower(keyname[k])) continue
        rest = substr(t, length(keyname[k]) + 1); sub(/^[ \t]+/, "", rest)
        if (substr(rest, 1, 1) == SEP) return k
    }
    return ""
}

# Where a line of this section goes when the target lacks it: after this row (0 means before the first), or -1 when
# the section itself is missing.
function insert_after(s, kind,   i, h, last) {
    if (s == "") {
        last = 0
        for (i = 1; i <= n; i++) {
            if (rkind[i] == "ini" || rkind[i] == "open") break
            if (trim(row[i]) != "") last = i
        }
        return last
    }
    if (kind == "forge") {
        for (i = 1; i <= n; i++) if (rkind[i] == "close" && tolower(rclosed[i]) == tolower(s)) return i - 1
        return -1
    }
    h = 0
    for (i = 1; i <= n; i++) if (rkind[i] == "ini" && tolower(rsec[i]) == tolower(s)) { h = i; break }
    if (!h) return -1
    last = h
    for (i = h + 1; i <= n && rkind[i] != "ini"; i++) if (trim(row[i]) != "") last = i
    return last
}

function indent_for(k, at,   i, d) {
    if (seckind[k] != "forge") return ""
    d = split(sec[k], parts, ".")
    return sprintf("%" (d * 4) "s", "")
}

END {
    ORS = crlf ? "\r\n" : "\n"
    m = 0
    for (i = 1; i <= count["always"]; i++) { k = order["always", i]; own[k] = lines["always", k]; owned[++m] = k }
    for (i = 1; i <= count["once"]; i++) {
        k = order["once", i]
        if (("always", k) in lines) continue
        sig = FILE "\t" sec[k] "\t" k "\t" lines["once", k]
        gsub(/\n/, "\037", sig); gsub(SUBSEP, "\t", sig)
        if (sig in seen) continue
        own[k] = lines["once", k]; owned[++m] = k
        if (NEWSTATE != "") printf "%s\n", sig >> NEWSTATE
    }

    # An identity whose lines already read as the pack's, in order, stays where it is, even spread apart.
    for (i = 1; i <= n; i++) {
        if (rid[i] == "" || !(rid[i] in own)) continue
        # Tested before have[] is read, since reading an awk array element creates it.
        if (rid[i] in have) have[rid[i]] = have[rid[i]] "\n" trim(row[i])
        else have[rid[i]] = trim(row[i])
    }
    for (i = 1; i <= n; i++) {
        if (rid[i] == "" || !(rid[i] in own)) continue
        if (have[rid[i]] == own[rid[i]]) { first[rid[i]] = i; continue }
        if (rid[i] in first) drop[i] = 1
        else { first[rid[i]] = i; rep[i] = rid[i] }
    }
    for (j = 1; j <= m; j++) {
        k = owned[j]
        if (k in first) continue
        at = insert_after(sec[k], seckind[k])
        if (at >= 0) { after[at] = after[at] indented(own[k], indent_for(k)) ; continue }
        if (seckind[k] == "forge") {
            print "settings: " FILE " has no category " sec[k] " for " own[k] "; skipped" > "/dev/stderr"
            continue
        }
        if (!(sec[k] in tailbuf)) { tailorder[++tails] = sec[k]; tailbuf[sec[k]] = "" }
        tailbuf[sec[k]] = tailbuf[sec[k]] own[k] "\n"
    }

    out(after[0])
    for (i = 1; i <= n; i++) {
        if (drop[i]) { out(after[i]); continue }
        if (i in rep) out(indented(own[rep[i]], rindent[i]))
        else print row[i]
        out(after[i])
    }
    for (j = 1; j <= tails; j++) {
        if (n > 0 || j > 1) print ""
        print "[" tailorder[j] "]"
        out(tailbuf[tailorder[j]])
    }
}

function indented(text, pad,   r, a, c, i) {
    c = split(text, a, "\n"); r = ""
    for (i = 1; i <= c; i++) r = r pad a[i] "\n"
    return r
}

# Prints a buffer of "\n"-ended lines with ORS.
function out(text,   a, c, i) {
    if (text == "") return
    c = split(text, a, "\n")
    for (i = 1; i < c; i++) print a[i]
}
