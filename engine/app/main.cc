
#include <cassert>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <random>
#include <vector>

#include "3rd-party/CLI11.hpp"
#include "topoi/Constants.hh"
#include "topoi/Generators.hh"
#include "topoi/Macros.hh"
#include "topoi/Topoi.hh"
#include "topoi/Types.hh"
#include "topoi/Utils.hh"
#include "topoi/topoi.h"

struct Options { uint64_t seed = 42;
    topoi::index_t levels = 6;
    topoi::index_t sample_moves = 10;
    template <class App>
    void setup_onto(App& app) {
        // clang-format off
      app.add_option("--seed", seed, "Random seed");      app.add_option("--levels", levels, "Levels");app.add_option("--sample-moves", sample_moves, "Sample moves");
        // clang-format on
    }
};

static void run(Options options) {
    using namespace topoi;  std::mt19937_64 rng(options.seed);

    index_t levels = options.levels;
    for (size_t i = 0; i < BOARD_CELLS; i++) {
        Notation id = notation_from_uuid(i);
        index_t uuid = uuid_from_notation(id);
        assert(uuid == i);
    }

    Topoi topoi(levels);

    TOPOI_LOG("levels: " << levels << '\n');
    TOPOI_LOG("cells: " << topoi.adj().size() << '\n');

    Player player = DEFAULT_STARTING_PLAYER;
    State state = make_initial_state(player);
    generate_moves(rng, topoi, state, options.sample_moves);

    if (false) {
        Slide slide{.group = Group({82}), .direction_id = 0, .steps = 1};
        Leap leap{.source = 116, .target = 100};
        Step step{.source = 116, .target = 100};

        std::vector<Move> moves = {
            Move{.type = Type::Slide, .data = &slide},  //
            Move{.type = Type::Leap, .data = &leap},    //
            Move{.type = Type::Step, .data = &step}     //
        };

        replay(topoi, moves);
    }
}

int main(int argc, char* argv[]) {
    using namespace topoi;

    Options options;
    CLI::App app{"topoi"};
    options.setup_onto(app);

    try {
        app.parse(argc, argv);
        run(options);
    } catch (const CLI::ParseError& e) {
        exit(app.exit(e));
    }

    return 0;
}
