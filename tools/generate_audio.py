#!/usr/bin/env python3
"""Generate the game's small, original audio palette using only Python's stdlib."""
import math
import random
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "audio"
RATE = 22050


def save(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    peak = max(1e-9, max(abs(x) for x in samples))
    scale = min(1.0, 0.82 / peak)
    with wave.open(str(OUT / name), "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(RATE)
        wf.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, x * scale)) * 32767)) for x in samples))


def ambient():
    seconds = 18
    n = seconds * RATE
    rng = random.Random(3407)
    samples = []
    low = 0.0
    mid = 0.0
    for i in range(n):
        t = i / RATE
        edge = min(1.0, i / (RATE * 1.5), (n - i - 1) / (RATE * 1.5))
        edge = max(0.0, edge)
        noise = rng.uniform(-1, 1)
        low += (noise - low) * 0.012
        mid += (noise - mid) * 0.12
        slow = 0.82 + 0.18 * math.sin(2 * math.pi * 0.11 * t + 0.7)
        hum = (0.17 * math.sin(2 * math.pi * 43.5 * t)
               + 0.12 * math.sin(2 * math.pi * 55.5 * t + 0.8)
               + 0.075 * math.sin(2 * math.pi * 73.5 * t + 1.7)
               + 0.05 * math.sin(2 * math.pi * 110.0 * t + 0.3))
        air = low * 0.15 + mid * 0.035
        faint_pulse = 0.035 * math.sin(2 * math.pi * 0.72 * t) * math.sin(2 * math.pi * 31.0 * t)
        samples.append((hum * slow + air + faint_pulse) * edge)
    save("archive_hum.wav", samples)


def pulse():
    seconds = 1.15
    n = int(seconds * RATE)
    rng = random.Random(990)
    samples = []
    phase = 0.0
    for i in range(n):
        t = i / RATE
        x = t / seconds
        frequency = 118.0 - 72.0 * x
        phase += 2 * math.pi * frequency / RATE
        attack = min(1.0, t * 90.0)
        body = math.exp(-t * 3.2) * (0.62 * math.sin(phase) + 0.19 * math.sin(phase * 2.02 + 0.2))
        metallic = math.exp(-t * 5.4) * 0.14 * math.sin(2 * math.pi * (680.0 - 360.0 * x) * t)
        crackle = rng.uniform(-1, 1) * math.exp(-t * 40.0) * 0.08
        samples.append((body + metallic + crackle) * attack)
    save("echolocation.wav", samples)


def heartbeat():
    seconds = 1.42
    n = int(seconds * RATE)
    samples = []
    for i in range(n):
        t = i / RATE
        value = 0.0
        for beat in (0.06, 0.28):
            dt = t - beat
            if dt >= 0:
                envelope = math.exp(-dt * 23.0)
                value += envelope * (0.56 * math.sin(2 * math.pi * 64.0 * dt) + 0.24 * math.sin(2 * math.pi * 96.0 * dt))
        samples.append(value * 0.48)
    save("drowned_heartbeat.wav", samples)


if __name__ == "__main__":
    ambient()
    pulse()
    heartbeat()
    for path in sorted(OUT.glob("*.wav")):
        print(f"Generated {path.relative_to(ROOT)} ({path.stat().st_size:,} bytes)")
