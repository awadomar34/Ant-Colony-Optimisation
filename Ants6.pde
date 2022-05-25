// config
int board_size = 30;
boolean print_anthill_status = false;
boolean print_ant_numbers = false;
boolean setSeed = true;
int seed = 420;
int frame_rate = 8;

// String map_setup = "random";
// String map_setup = "alw";  //"against the walls";
String map_setup = "clw";  // "cover the walls";



// stuff from paper

// choose phi and gamma 
float phi = 1.2;
float gamma = 0.1;

float N = 2*board_size;
float beta = log(sqrt(phi/(1-gamma)));
float q0_A = pow(phi,N);
float q0_B = q0_A;

// fixed 
float qA_th = 1;
float qB_th = 1;



// float beta = 0.01;
float s0 = 0.99;
float ds = 0.00;
float s_min = 0.5; 
float alpha = 0.25;  // walk bias


// stuff i added
int init_anthill_food = 100;
int init_food_amnt = 5;
float min_amnt_scouts = 4;
int max_iteration = int(1e4);

int inv_collection_rate = 5;
String macro_data_file_name = "macro_data.csv";




// data collectors; DONT TOUCH
int num_of_scouting_ants_produced = 0;
int num_of_gathering_ants_produced = 0;
int total_food_return_to_hill = 0;
int num_complete_trips = 0;
int number_of_A_pheros_on_map = 0;
int number_of_B_pheros_on_map = 0;


// globals; DONT TOUCH
int scale;
GridMap grid;
Anthill hill;


HashMap<Integer, Pheromon> global_A_pheromons;
HashMap<Integer, Pheromon> global_B_pheromons;
HashMap<Integer, Food> global_food;
HashMap<Integer, Anthill> global_hill;
ArrayList<ScoutingAnt> scouting_ants_on_map;
ArrayList<GatheringAnt> gathering_ants_on_map;



// other stuff; DONT TOUCH
boolean paused = false;
int iteration_number = 0;

String phero_direction = "max";
Table marco_data_table;
Table phero_A_table;
Table phero_B_table;
boolean food_reached = false;
boolean food_returned = false;




void setup() {
    frameRate(frame_rate);
    size(600, 600);
    scale = width / board_size;
    grid = new GridMap();
    marco_data_table = initMacroDataTable();
    phero_A_table = initPheroTable();
    phero_B_table = initPheroTable();


    if (setSeed) {
        randomSeed(seed);
    }


    // setup globals`
    global_A_pheromons = new HashMap<Integer, Pheromon>();
    global_B_pheromons = new HashMap<Integer, Pheromon>();
    global_food = new HashMap<Integer, Food>();
    global_hill = new HashMap<Integer, Anthill>();
    scouting_ants_on_map = new ArrayList<ScoutingAnt>();
    gathering_ants_on_map = new ArrayList<GatheringAnt>();


    if (map_setup.equals("alw")) {
        againstTheWalls();
    } else if (map_setup.equals("clw")) {
        coverTheWalls();
    } else {
        randomSetup();
    }

    noLoop();
}

void draw() {
    print("Iteration number: "); println(iteration_number);
    background(211, 211, 211);
    grid.show();



    // update, remove and show phA
    ArrayList<Integer> phA_to_pop = new ArrayList<Integer>();
    for (Integer k : global_A_pheromons.keySet()) {
        if (global_A_pheromons.get(k).strength <= qA_th) {
            phA_to_pop.add(k);
        }
    }
    for (Integer k : phA_to_pop) {
        global_A_pheromons.remove(k);
    }
    
    // update, remove and show phB
    ArrayList<Integer> phB_to_pop = new ArrayList<Integer>();
    for (Integer k : global_B_pheromons.keySet()) {
        if (global_B_pheromons.get(k).strength <= qB_th) {
            phB_to_pop.add(k);
        }
    }
    for (Integer k : phB_to_pop) {
        global_B_pheromons.remove(k);
    }
    

    // updateAndShow() foods
    ArrayList<Integer> keys_to_pop = new ArrayList<Integer>();
    for (Integer k : global_food.keySet()) {
        if (global_food.get(k).amount_left <= 0) {
            keys_to_pop.add(k);
        }
    }
    for (Integer k : keys_to_pop) {
        global_food.remove(k);
    }
    for (Food f : global_food.values()) {
        f.updateAndShow();
    }

    // update() ants
    for (ScoutingAnt a : scouting_ants_on_map) {
        a.update();
    }
    for (GatheringAnt a : gathering_ants_on_map) {
        a.update();
    }

    // remove some of the ants
    ArrayList<ScoutingAnt> still_alive = new ArrayList<ScoutingAnt>();
    for (ScoutingAnt a : scouting_ants_on_map) {
        if (a.phero_sense > s_min){
            still_alive.add(a);
        }
    }
    scouting_ants_on_map = still_alive;

    ArrayList<GatheringAnt> still_alive2 = new ArrayList<GatheringAnt>();
    for (GatheringAnt a : gathering_ants_on_map) {
        if (a.phero_sense > s_min){
            still_alive2.add(a);
        }
    }
    gathering_ants_on_map = still_alive2;



    for (Pheromon ph : global_A_pheromons.values()) {
        ph.updateAndShow();
    }
    for (Pheromon ph : global_B_pheromons.values()) {
        ph.updateAndShow();
    }

    //  ants
    for (ScoutingAnt a : scouting_ants_on_map) {
        a.show();
    }
    for (GatheringAnt a : gathering_ants_on_map) {
        a.show();
    }

    // updateAndShow() hills
    for (Anthill h : global_hill.values()) {
        h.updateAndShow();
    }


    

    if (print_ant_numbers) {
        println("Number of Scouting Ants: " + scouting_ants_on_map.size());
        println("Number of Gathering Ants: " + gathering_ants_on_map.size());
        
    }








    print("\n\n\n\n\n\n");
    // videoExport.saveFrame();
    if (iteration_number % inv_collection_rate == 0) {
        addMacroDataRow();
        addPheroDataRow('A');
        addPheroDataRow('B');
    }
    

    // check for termination
    if (scouting_ants_on_map.size() == 0 && gathering_ants_on_map.size() == 0) {
        println("No more ants... :( ");  // sad
        exit();
    } else if (global_food.size() == 0) {
        println("Collected all the food! :)");  // happy
        exit();
    // } else if (food_returned) {
    //     println("Food returned! :)"); // happy
    //     exit();
    } else if (total_food_return_to_hill >= 10) {
        println("Returned 10 food! :)");
        exit();
    } else if (iteration_number == max_iteration) {
        println("Max iteration number reached.");  // technical
        exit();
    } 

    // delay(10000);
    iteration_number++;
}

void keyPressed() {
    // space button
    if (key == ' ') {
        paused = !paused;
        if (paused) {
            noLoop();
            println("Pause...");
            
        } else {
            loop();
            println("Unpause...");
        }
    }

    // arrow keys
    if (key == CODED) {
        if (keyCode == LEFT) {
            if (frame_rate <= 1) {
                frame_rate = 1;
            } else {
                frame_rate = int(frame_rate/2);
            }
        }
        if (keyCode == RIGHT) {
            frame_rate = frame_rate*2;
        }

        println("Frame rate changed to " + frame_rate);
        frameRate(frame_rate);
    }

}

void exit() {
    // last bit of data
    addMacroDataRow();
    addPheroDataRow('A');
    addPheroDataRow('B');

    // save the data 
    String s = Integer.toString(seed);
    saveTable(phero_A_table, "data/phero_a_" + s + ".csv");
    saveTable(phero_B_table, "data/phero_b_" + s + ".csv");
    saveTable(marco_data_table, "data/macro_data_" + s + ".csv");

    // endRecord();
    // videoExport.endMovie();
    super.exit();
}



// util functions
int posToInt(PVector v) {
    // uses Cantor Pairing to encode grid position to a unique int
    // https://en.wikipedia.org/wiki/Pairing_function

    // v = posToGrid(v);
    return int(0.5*(v.x + v.y)*(v.x + v.y + 1) + v.y);
}

PVector intToPos(int z) {
    int w = floor((sqrt(8*z + 1) - 1)/2);
    int t = int((pow(w, 2) + w)/2);
    int y = z - t;
    int x = w - y;

    return new PVector(x, y);
}


// global functions
PVector gridToPos(int grid_x, int grid_y) {
    return new PVector(scale*grid_x + scale / 2, scale*grid_y + scale / 2);
}

PVector posToGrid(PVector p) {
    return new PVector(p.x/scale - 0.5, p.y/scale - 0.5);
}

ArrayList<PVector> removeOutOfBounds(ArrayList<PVector> vectors) {
    ArrayList<PVector> viable = new ArrayList<PVector>();
    for (int i = 0; i < vectors.size(); i++) {
        PVector v = vectors.get(i);
        if (v.x >= 0 && v.x < width && v.y >= 0 && v.y < height) {
            viable.add(v);
        }
    }

    return viable;
}

boolean isOutOfBounds(PVector v) {
    if (v.x < 0 || v.x >= width || v.y < 0 || v.y >= height) {
            return true;
    } else {
        return false;
    }

}


// global var updating functions
void addPheromon(Pheromon ph) {
    int phero_id = posToInt(ph.pos);

    if (ph.type == 'A') {
        if (global_A_pheromons.containsKey(phero_id)) {
            global_A_pheromons.get(phero_id).strength += ph.strength;
        } else {
            global_A_pheromons.put(phero_id, ph);
        }

    } else {
        if (global_B_pheromons.containsKey(phero_id)) {
            global_B_pheromons.get(phero_id).strength += ph.strength;
        } else {
            global_B_pheromons.put(phero_id, ph);
        }

        // println("phero B added");
    }

    
}

void randSpawnFood() {
    int x = int(random(board_size));
    int y = int(random(board_size));

    PVector pos = gridToPos(x, y);
    Integer k = posToInt(pos);
    Food fd = new Food(pos);

    global_food.put(k, fd);
}

// data collection functions
Table initMacroDataTable() {
    Table t = new Table();
    t.addColumn("timestep",  Table.INT);
    
    t.addColumn("num_scouts_produced",  Table.INT); 
    t.addColumn("num_gatherers_produced",  Table.INT);
    t.addColumn("num_scouts_alive",  Table.INT); 
    t.addColumn("num_gatherers_alive",  Table.INT);
    
    t.addColumn("total_food_collected",  Table.INT);
    t.addColumn("num_ants_returned",  Table.INT); 
    t.addColumn("num_complete_trips",  Table.INT);
    
    t.addColumn("num_phero_A_on_map",  Table.INT); 
    t.addColumn("num_phero_B_on_map",  Table.INT);
    t.addColumn("num_food_on_map", Table.INT);
    t.addColumn("amount_of_food_left", Table.INT);

    return t;
}

Table initPheroTable() {
    Table t = new Table();
    t.addColumn("timestep", Table.INT);

    for (int i = 0; i < board_size; i++) {
        for (int j = 0; j < board_size; j++) {
            PVector p = new PVector(i, j);
            int id = posToInt(p);

            t.addColumn(Integer.toString(id), Table.FLOAT);
        }
    }

    return t;
}

void addMacroDataRow() {
    TableRow r = marco_data_table.addRow();

    r.setInt("timestep", iteration_number);

    r.setInt("num_scouts_produced", num_of_scouting_ants_produced);
    r.setInt("num_gatherers_produced", num_of_gathering_ants_produced);
    r.setInt("num_scouts_alive", scouting_ants_on_map.size());
    r.setInt("num_gatherers_alive", gathering_ants_on_map.size());

    r.setInt("total_food_collected", total_food_return_to_hill);
    r.setInt("num_complete_trips", num_complete_trips);

    r.setInt("num_phero_A_on_map", global_A_pheromons.size());
    r.setInt("num_phero_B_on_map", global_B_pheromons.size());

    r.setInt("num_food_on_map", global_food.size());
    float amount_of_food_left = 0;
    for (Food fd : global_food.values()) {
        amount_of_food_left += fd.amount_left;
    }
    r.setInt("amount_of_food_left", int(amount_of_food_left));
}

void addPheroDataRow(char phero_type) {
    HashMap<Integer, Pheromon> pheros;
    Table t;
    if (phero_type == 'A') {
        pheros = global_A_pheromons;
        t = phero_A_table;
    } else {
        pheros = global_B_pheromons;
        t = phero_B_table;
    }

    TableRow r =  t.addRow();
    r.setInt("timestep", iteration_number);

    for (Integer k : pheros.keySet()) {
        PVector p = intToPos(k);
        PVector p2 = posToGrid(p);
        int id = posToInt(p2);

        if (pheros.containsKey(k)) {
            r.setFloat(Integer.toString(id), pheros.get(k).strength);
        } else {
            r.setFloat(Integer.toString(id), 0.0);
        }
    }



}

// setups
void randomSetup() {
    global_hill.put(
        posToInt(gridToPos(int(board_size/2), int(board_size/2))), 
        new Anthill(gridToPos(int(board_size/2), int(board_size/2)))
    );

    for (int i = 0; i < board_size/2; i++) {
        randSpawnFood();
    }
     
}


void againstTheWalls() {
    global_hill.put(
        posToInt(gridToPos(0, int(board_size/2))), 
        new Anthill(gridToPos(0, int(board_size/2)))
    );

    for (int i = 0; i < board_size; i++) {
        PVector p = gridToPos(board_size-1, i);
        Integer k = posToInt(p);
        global_food.put(k, new Food(p));
    }
     
}

void coverTheWalls() {
    global_hill.put(
        posToInt(gridToPos(int(board_size/2), int(board_size/2))), 
        new Anthill(gridToPos(int(board_size/2), int(board_size/2)))
    );

    // left and right walls
    for (int i = 0; i < board_size; i++) {
        PVector p = gridToPos(0, i);
        Integer k = posToInt(p);
        global_food.put(k, new Food(p));

        PVector p2 = gridToPos(board_size-1, i);
        Integer k2 = posToInt(p2);
        global_food.put(k2, new Food(p2));
    }

    // up and down walls
    for (int i = 1; i < board_size-1; i++) {
        PVector p = gridToPos(i, 0);
        Integer k = posToInt(p);
        global_food.put(k, new Food(p));

        PVector p2 = gridToPos(i, board_size-1);
        Integer k2 = posToInt(p2);
        global_food.put(k2, new Food(p2));
    }

    // // right wall
    // for (int i = 0; i < board_size; i++) {
    //     PVector p = gridToPos(board_size-1, i);
    //     Integer k = posToInt(p);
    //     global_food.put(k, new Food(p));
    // }
}
