#!/usr/bin/env python3
"""Desenha o Mangekyō Sharingan do Itachi em PNG (Python puro, sem bibliotecas de imagem).

Uso: python3 gerar-sharingan.py [saida.png] [tamanho]
"""
import math
import struct
import sys
import zlib

SAIDA = sys.argv[1] if len(sys.argv) > 1 else 'sharingan.png'
N = int(sys.argv[2]) if len(sys.argv) > 2 else 512
SS = 3  # supersampling por eixo (antialiasing)

PRETO = (8, 0, 0)
VERMELHO_BORDA = (120, 0, 0)
VERMELHO_CENTRO = (235, 20, 20)

R_ANEL = 0.90      # começo do anel preto externo
R_FORA = 1.0       # fim do olho
R_PUPILA = 0.20
SPIRAL = 1.5       # quanto as lâminas giram do centro até a borda (radianos)
LARGURA = 0.85     # meia-largura angular da lâmina perto do centro (radianos)


def cor(x, y):
    """Cor (r, g, b, a) do ponto (x, y) em coordenadas -1..1."""
    r = math.hypot(x, y)
    if r > R_FORA:
        return (0, 0, 0, 0)
    if r >= R_ANEL or r <= R_PUPILA:
        return (*PRETO, 255)

    # três lâminas curvas em espiral (cata-vento), afinando até encostar no anel
    theta = math.atan2(y, x)
    t = (r - R_PUPILA) / (R_ANEL - R_PUPILA)
    largura = LARGURA * (1 - t) ** 1.3 + 0.10 * math.sin(math.pi * t)
    for i in range(3):
        centro = i * 2 * math.pi / 3 + SPIRAL * t * t
        d = (theta - centro + math.pi) % (2 * math.pi) - math.pi
        # lado de dentro da curva mais "cheio", lado de fora cortado: forma de foice
        limite = largura * (1.25 if d < 0 else 0.75)
        if abs(d) < limite:
            return (*PRETO, 255)

    # íris: vermelho vivo no meio, escurecendo para a borda
    k = min(1.0, r / R_ANEL) ** 2
    rgb = tuple(int(c0 + (c1 - c0) * k) for c0, c1 in zip(VERMELHO_CENTRO, VERMELHO_BORDA))
    return (*rgb, 255)


def pixel(px, py):
    acc = [0, 0, 0, 0]
    for sy in range(SS):
        for sx in range(SS):
            x = ((px + (sx + 0.5) / SS) / N) * 2 - 1
            y = ((py + (sy + 0.5) / SS) / N) * 2 - 1
            c = cor(x, y)
            # média com alfa pré-multiplicado
            a = c[3] / 255
            acc[0] += c[0] * a
            acc[1] += c[1] * a
            acc[2] += c[2] * a
            acc[3] += c[3]
    n = SS * SS
    a = acc[3] / n
    if a == 0:
        return (0, 0, 0, 0)
    f = 255 / a
    return (int(acc[0] / n * f), int(acc[1] / n * f), int(acc[2] / n * f), int(a))


linhas = bytearray()
for py in range(N):
    linhas.append(0)  # filtro PNG "none"
    for px in range(N):
        linhas.extend(pixel(px, py))


def chunk(tipo, dados):
    return struct.pack('>I', len(dados)) + tipo + dados + struct.pack('>I', zlib.crc32(tipo + dados) & 0xFFFFFFFF)


png = b'\x89PNG\r\n\x1a\n'
png += chunk(b'IHDR', struct.pack('>IIBBBBB', N, N, 8, 6, 0, 0, 0))
png += chunk(b'IDAT', zlib.compress(bytes(linhas), 9))
png += chunk(b'IEND', b'')
with open(SAIDA, 'wb') as f:
    f.write(png)
print(f'{SAIDA}: {N}x{N}')
