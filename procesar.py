

import sys
import argparse


# Configuracion de mapas (debe coincidir con master_data.sql)
MAPS = [
    (1, 1, "E1M1", (-1500, 1500), (-1500, 1500)),
    (2, 1, "E1M2", (-2000, 1000), (-1000, 2000)),
    (3, 2, "E2M1", (-1000, 2000), (-1500, 1500)),
    (4, 2, "E2M2", (-1500, 1500), (-2000, 1000)),
    (5, 3, "E3M1", (-1000, 1000), (-3500, 1000)),
    (6, 3, "E3M2", (-2000, 2000), (-1000, 2000)),
]

SECTOR_SIZE = 250


def build_sector_lookup():
    lookup = {}
    sector_id = 1
    for mid, _, _, (xmin, xmax), (ymin, ymax) in MAPS:
        gx_start = xmin // SECTOR_SIZE
        gx_end = xmax // SECTOR_SIZE + 1
        gy_start = ymin // SECTOR_SIZE
        gy_end = ymax // SECTOR_SIZE + 1
        for gx in range(gx_start, gx_end):
            for gy in range(gy_start, gy_end):
                lookup[(mid, gx, gy)] = sector_id
                sector_id += 1
    return lookup


def parse_game_tsv(filepath):

    sessions = []
    current = None

    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            line = line.rstrip('\n')

            # Linea de metadata "When: ... Episode: X Map: Y"
            if line.startswith('When:'):
                parts = line.split()
                try:
                    ep_idx = parts.index('Episode:')
                    mp_idx = parts.index('Map:')
                    episode = int(parts[ep_idx + 1])
                    game_map = int(parts[mp_idx + 1])
                    if current is not None:
                        current['episode'] = episode
                        current['map'] = game_map
                except (ValueError, IndexError):
                    pass
                continue

            # Header de sesion
            stripped = line.strip()
            if stripped.startswith('timestamp') and 'tic' in stripped:
                if current is not None and current['rows']:
                    sessions.append(current)
                current = {'rows': [], 'episode': None, 'map': None}
                continue

            # Filas de datos (deben empezar con un digito - timestamp YYYY-MM-DD)
            if current is not None and line and line[0].isdigit():
                fields = [f.strip() for f in line.split('\t')]
                if len(fields) >= 8:
                    current['rows'].append({
                        'timestamp': fields[0],
                        'tic':       fields[1],
                        'x':         fields[2],
                        'y':         fields[3],
                        'z':         fields[4],
                        'angle':     fields[5],
                        'momx':      fields[6],
                        'momy':      fields[7],
                    })

    if current is not None and current['rows']:
        sessions.append(current)

    return sessions


def main():
    parser = argparse.ArgumentParser(
        description='Procesa TSV crudo de chocolate-doom -> formato staging_telemetry'
    )
    parser.add_argument('input_tsv', help='Archivo TSV emitido por el juego')
    parser.add_argument('--game-id', type=int, required=True,
                        help='ID de la partida en la DB (debe existir en Game)')
    parser.add_argument('--player-id', type=int, required=True,
                        help='ID del jugador en la DB (debe existir en Player)')
    parser.add_argument('--map-id', type=int, default=1,
                        help='ID del mapa en la DB (default: 1 = E1M1)')
    parser.add_argument('--output', default='processed.tsv',
                        help='TSV de salida (default: processed.tsv)')
    parser.add_argument('--health', type=int, default=100,
                        help='Valor de health a usar (juego no lo emite)')
    parser.add_argument('--armor', type=int, default=0,
                        help='Valor de armor a usar (juego no lo emite)')
    parser.add_argument('--ammo', type=int, default=50,
                        help='Valor de ammo a usar (juego no lo emite)')
    args = parser.parse_args()

    print(f"Procesando: {args.input_tsv}")
    sessions = parse_game_tsv(args.input_tsv)

    if not sessions:
        print("ERROR: No se encontraron sesiones de telemetria.")
        sys.exit(1)

    print(f"Sesiones encontradas: {len(sessions)}")
    for i, sess in enumerate(sessions, 1):
        ep = sess['episode'] if sess['episode'] else '?'
        mp = sess['map']     if sess['map']     else '?'
        print(f"  Sesion {i}: {len(sess['rows'])} filas | "
              f"Episode={ep}, Map={mp}")

    sectors = build_sector_lookup()
    total_written = 0
    total_skipped = 0
    skip_reasons = {}

    with open(args.output, 'w') as out:
        # Header igual a staging_telemetry
        out.write("game_id\tplayer_id\tsector_id\ttic\tpos_x\tpos_y\t"
                  "mom_x\tmom_y\tangle\tfov\thealth\tarmor\tammo\n")

        for sess in sessions:
            for row in sess['rows']:
                # Parsear valores numericos
                try:
                    tic = int(row['tic'])
                    x   = float(row['x'])
                    y   = float(row['y'])
                    angle = float(row['angle'])
                    momx  = float(row['momx'])
                    momy  = float(row['momy'])
                except ValueError:
                    total_skipped += 1
                    skip_reasons['valor numerico invalido'] = \
                        skip_reasons.get('valor numerico invalido', 0) + 1
                    continue

                # Resolver sector desde (x, y)
                gx = int(x // SECTOR_SIZE)
                gy = int(y // SECTOR_SIZE)
                sector_id = sectors.get((args.map_id, gx, gy))
                if sector_id is None:
                    total_skipped += 1
                    skip_reasons['posicion fuera de grilla'] = \
                        skip_reasons.get('posicion fuera de grilla', 0) + 1
                    continue

                # Defaults para combat stats (juego no los emite)
                out.write(
                    f"{args.game_id}\t{args.player_id}\t{sector_id}\t{tic}\t"
                    f"{x:.2f}\t{y:.2f}\t"
                    f"{momx:.2f}\t{momy:.2f}\t"
                    f"{angle:.2f}\t90.00\t"
                    f"{args.health}\t{args.armor}\t{args.ammo}\n"
                )
                total_written += 1

    print(f"\nResultado:")
    print(f"  Filas escritas: {total_written}")
    print(f"  Filas omitidas: {total_skipped}")
    for motivo, n in skip_reasons.items():
        print(f"    - {motivo}: {n}")

    print(f"\nProximo paso:")
    print(f"  1. Asegurate de tener la partida creada en la DB:")
    print(f"       INSERT INTO Game (game_id, map_id, start_time) "
          f"VALUES ({args.game_id}, {args.map_id}, NOW());")
    print(f"  2. Carga al staging:")
    print(f"       \\copy staging_telemetry FROM '{args.output}' "
          f"WITH (FORMAT csv, DELIMITER E'\\t', HEADER true)")
    print(f"  3. Corre el ETL de tu parte2_puntoB.sql")


if __name__ == '__main__':
    main()
