import topoi_wasm from './topoi.js'; // Adjust path if needed

async function init() {  try {
 const topoi_engine = await topoi_wasm();  // Initialize the module
    console.log('awaiting');

    console.log('Topoi WASM module loaded!');
    const state = topoi_engine.make_initial_state();
    const levels = 5;
    const topoi = new topoi_engine.Topoi(levels);


    const moves = [
      ['Leap', 49, 28],
      ['Leap', 65, 64],
      ['Step', 2, 10],
      ['Slide', 31, 5, 1],
      ['Slide', 57, 0, 1],
      ['Step', 5, 0],
      ['Leap', 81, 52],
      ['Leap', 54, 31],
      ['Leap', 85, 56],
    ];

    function play(topoi, moves, state) {
      function leap(source, target, state) {
        logToDocument(`-- leap ${source} ${target} `);
        const success = topoi.leap(source, target, state);        return success;
      }

      function step(source, target, state) {
        logToDocument(`-- step ${source} ${target} `);
        const success = topoi.step(source, target, state);
        return success;
      }

      function slide(source, direction, steps, state) {
        logToDocument(`-- slide [${source}] ${direction} ${steps} `);
        var group = new topoi_engine.VectorIndex();
        group.push_back(source);
        const success = topoi.slide(group, direction, steps, state);
        return success;
      }

      const moveFunctions = {
        Leap: leap,
        Step: step,
        Slide: slide,
      };

      let state_repr = topoi_engine.serialize_state(state);
      logToDocument(`0 ${state_repr}`);
      for (let moveId = 0; moveId < moves.length; moveId++) {
        const move = moves[moveId];
        const moveType = move[0];
        const args = move.slice(1);
        const fn = moveFunctions[moveType];
        const ret = fn(...args, state);
        logToDocument(ret ? ' success' : ' failure');
        state_repr = topoi_engine.serialize_state(state);
        logToDocument(`${moveId + 1} ${state_repr}`);
      }
    }

    function logToDocument(message) {
      const outputDiv = document.getElementById('output');
      if (outputDiv) {
        outputDiv.innerHTML += message + '<br>';
      } else {
        console.error('Output div not found!');
      }
    }

    play(topoi, moves, state);
  } catch (error) {
    console.error('Error initializing Topoi WASM:', error);
  }
}

init();
console.log('Parsed and run!');

