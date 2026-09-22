#!/usr/bin/env python3
"""Generate the SFX for Line Duty into core/resources/audio/.

Pure-stdlib synthesis (no numpy): short 44.1 kHz mono WAVs. Everything here
is generated, so it carries no license; replace with real assets when they
exist (keep the file names — core/lib/services/audio_service.dart refers to
them).

    python3 script/gen_placeholder_audio.py
"""
import math
import os
import random
import struct
import wave

SR = 44100
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'core', 'resources', 'audio')


def write_wav(name, samples, peak_target=0.89):
    os.makedirs(OUT, exist_ok=True)
    peak = max(1e-9, max(abs(s) for s in samples))
    gain = peak_target / peak
    frames = struct.pack('<%dh' % len(samples), *[int(max(-1.0, min(1.0, s * gain)) * 32767) for s in samples])
    path = os.path.join(OUT, name)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(frames)
    print('  %-18s %5.2f s' % (name, len(samples) / SR))


def note(freq, dur, decay=5.0, attack=0.004, harmonics=((1, 1.0),), freq_end=None):
    n = int(dur * SR)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = freq if freq_end is None else freq + (freq_end - freq) * (i / max(1, n - 1))
        phase += f / SR
        env = math.exp(-decay * t / dur)
        if t < attack:
            env *= t / attack
        s = sum(amp * math.sin(2 * math.pi * phase * k) for k, amp in harmonics)
        out.append(s * env)
    return out


def noise(dur, decay=30.0, seed=1, lowpass=0.2):
    rnd = random.Random(seed)
    n = int(dur * SR)
    out = []
    y = 0.0
    for i in range(n):
        t = i / SR
        y += lowpass * (rnd.uniform(-1, 1) - y)
        out.append(y * math.exp(-decay * t))
    return out


def mix(*parts):
    n = max(len(p) for p, _ in parts)
    out = [0.0] * n
    for samples, at in parts:
        start = int(at * SR)
        for i, s in enumerate(samples):
            if start + i < n:
                out[start + i] += s
    return out


def main():
    print('Generating SFX → core/resources/audio/')
    # Tap: short click.
    write_wav('sfx_tap.wav', mix((note(1800, 0.05, decay=9, harmonics=((1, 1.0), (2, 0.3))), 0)))
    # Draw start: soft rising blip.
    write_wav('sfx_draw.wav', mix((note(520, 0.09, decay=4, freq_end=760), 0)))
    # Deliver: two-note chime up.
    write_wav('sfx_deliver.wav', mix(
        (note(660, 0.14, decay=4, harmonics=((1, 1.0), (2, 0.25))), 0),
        (note(990, 0.22, decay=4, harmonics=((1, 1.0), (2, 0.2))), 0.09),
    ))
    # Warn: short buzz.
    write_wav('sfx_warn.wav', mix(
        (note(220, 0.16, decay=3, harmonics=((1, 1.0), (3, 0.5), (5, 0.25))), 0),
        (note(220, 0.16, decay=3, harmonics=((1, 1.0), (3, 0.5), (5, 0.25))), 0.2),
    ))
    # Crash: noise burst + low thud.
    write_wav('sfx_crash.wav', mix(
        (noise(0.45, decay=9, lowpass=0.35), 0),
        (note(90, 0.5, decay=5, freq_end=40, harmonics=((1, 1.0), (2, 0.4))), 0),
    ))
    # Record: three-note arpeggio.
    write_wav('sfx_record.wav', mix(
        (note(523, 0.2, decay=3), 0),
        (note(659, 0.2, decay=3), 0.12),
        (note(784, 0.32, decay=3), 0.24),
        (note(1047, 0.45, decay=3), 0.36),
    ))
    print('Done')


if __name__ == '__main__':
    main()
