"""Synthesizes the game's original sound effects and music loop.

    python3 tool/generate_audio.py

Writes 16-bit mono WAV files into assets/audio/. Pure standard library.
"""
import math, random, struct, wave, os

SR = 22050
OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
random.seed(7)


def write(name, samples, peak=0.8):
    m = max(1e-9, max(abs(s) for s in samples))
    k = peak / m
    with wave.open(os.path.join(OUT, name), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, s * k)) * 32767)) for s in samples))


def silence(sec):
    return [0.0] * int(SR * sec)


def tone(freqs, dur, decay=8.0, attack=0.002, amps=None):
    n = int(SR * dur)
    amps = amps or [1.0] * len(freqs)
    out = []
    for i in range(n):
        t = i / SR
        env = min(1.0, t / attack) * math.exp(-decay * t)
        out.append(env * sum(a * math.sin(2 * math.pi * f * t) for f, a in zip(freqs, amps)))
    return out


def sweep(f0, f1, dur, decay=6.0):
    n = int(SR * dur); out = []; ph = 0.0
    for i in range(n):
        t = i / SR
        f = f0 + (f1 - f0) * (i / n)
        ph += 2 * math.pi * f / SR
        env = min(1.0, t / 0.005) * math.exp(-decay * t)
        out.append(env * math.sin(ph))
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] if i < len(t) else 0.0 for t in tracks) for i in range(n)]


def at(track, sec):
    return silence(sec) + track


def glass(f, dur=0.25, decay=14):
    # Inharmonic partials give a glassy "tink".
    return tone([f, f * 2.76, f * 5.4], dur, decay=decay, amps=[1.0, 0.45, 0.18])


def noise_burst(dur, decay=60):
    n = int(SR * dur)
    return [random.uniform(-1, 1) * math.exp(-decay * i / SR) for i in range(n)]


os.makedirs(OUT, exist_ok=True)
write('tap.wav', tone([1400, 2800], 0.07, decay=55, amps=[1, 0.3]), 0.5)
write('select.wav', glass(1900, 0.18, 22), 0.55)
write('lift.wav', sweep(520, 1100, 0.10, decay=18), 0.35)
write('drop.wav', mix(glass(1250, 0.3, 16), [0.25 * s for s in noise_burst(0.02)]), 0.7)
write('invalid.wav', mix(tone([170, 340], 0.2, decay=14, amps=[1, 0.5]),
                         at(tone([150, 300], 0.18, decay=16, amps=[1, 0.5]), 0.09)), 0.6)
write('undo.wav', sweep(1300, 650, 0.16, decay=12), 0.45)
write('shuffle.wav', mix(*[at(glass(random.uniform(1100, 2600), 0.18, 26), i * 0.045) for i in range(10)]), 0.6)
write('add_tube.wav', mix(glass(880, 0.4, 9), at(glass(1175, 0.4, 9), 0.08), at(glass(1568, 0.5, 8), 0.16)), 0.6)
notes = [523.25, 659.25, 783.99, 1046.5, 1318.5]
write('complete.wav', mix(*[at(glass(f, 0.9, 5), i * 0.11) for i, f in enumerate(notes)],
                          *[at(glass(random.uniform(2500, 4200), 0.25, 18), 0.6 + i * 0.07) for i in range(6)]), 0.75)

# Ambient music loop: soft pads over a slow progression with gentle bells.
chords = [[220.0, 261.63, 329.63], [174.61, 220.0, 261.63], [261.63, 329.63, 392.0], [196.0, 246.94, 293.66]]
bar = 4.0
total = int(SR * bar * len(chords))
music = [0.0] * total
for ci, chord in enumerate(chords):
    start = int(ci * bar * SR)
    for i in range(int(bar * SR)):
        t = i / SR
        env = math.sin(math.pi * t / bar) ** 0.8
        v = sum(math.sin(2 * math.pi * f * t) + 0.3 * math.sin(2 * math.pi * f * 2 * t + 0.5) for f in chord)
        music[start + i] += 0.12 * env * v
    for k in range(4):
        f = chord[k % 3] * 4
        b = glass(f, 1.2, 3.5)
        off = start + int((k * 1.0 + 0.5) * SR)
        for j, s in enumerate(b):
            if off + j < total:
                music[off + j] += 0.10 * s
write('music.wav', music, 0.45)
print('ok')
