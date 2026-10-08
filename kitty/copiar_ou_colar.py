# Botão direito no kitty, como no Windows Terminal: copia se houver seleção, senão cola.
# Ligado em kitty.conf:  mouse_map right press ungrabbed kitten copiar_ou_colar.py
from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    w = boss.window_id_map.get(target_window_id) or boss.active_window
    if w is None:
        return
    if w.has_selection():
        w.copy_to_clipboard()
        w.clear_selection()
    else:
        boss.paste_from_clipboard()
