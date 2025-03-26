from topoi_engine import (
    Topoi,
    # Point,
    # Vertex,
    # Notation,
    Type,
    make_initial_state,
    Player,
)
import argparse


def play(topoi, moves, state):    def leap(source, target, state):                 print("-- leap", source, target, end="")
        success = topoi.leap(source, target, state)
        return success

    def step(source, target, state):
        print("-- step", source, target, end="")
        success = topoi.step(source, target, state)
        return success

    def slide(source, direction, steps, state):
        print("-- slide", source, direction, steps, end="")
        success = topoi.slide([source], direction, steps, state)
        return success

    move_functions = {
        Type.Leap: leap,
        Type.Step: step,
        Type.Slide: slide,
    }

    print(0, state)
    for move_id, move in enumerate(moves, 1):
        move_type, *args = move
        fn = move_functions[move_type]
        ret = fn(*args, state)
        print(" success" if ret else " failure")
        print(move_id, state)


# Example usage:
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Topoi Game")
    args = parser.parse_args()

    levels = 5
    topoi = Topoi(levels)
    player = Player.White
    initial_state = make_initial_state(player)

    moves = [
        (Type.Leap, 49, 28),
        (Type.Leap, 65, 64),
        (Type.Step, 2, 10),
        (Type.Slide, 31, 5, 1),
        (Type.Slide, 57, 0, 1),
        (Type.Step, 5, 0),
        (Type.Leap, 81, 52),
        (Type.Leap, 54, 31),
        (Type.Leap, 85, 56),
    ]

    play(topoi, moves, initial_state)
