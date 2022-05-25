class Anthill {
    PVector pos;
    int food_stored;
    int gatherer_count;
    int scouts_count;
    ArrayList<GatheringAnt> waiting_ants;
    boolean release_ants;
    PVector spawn_direction;


    Anthill(PVector init_pos) {
        pos = init_pos;
        food_stored = init_anthill_food;
        gatherer_count = 0;
        scouts_count = 0;
        waiting_ants = new ArrayList<GatheringAnt>();
        release_ants = false;
        ArrayList<PVector> spawn_directions = initSpawnDirections();
        if (map_setup.equals("alw")) {
            spawn_direction = PVector.add(pos, new PVector(scale, 0));
        } else {
            spawn_direction = spawn_directions.get(int(random(spawn_directions.size())));
        }

    }

    void update() {
        if (print_anthill_status) {
            printStatus();
        }

        if (release_ants && waiting_ants.size() > 0) {
            releaseAnts();
            release_ants = false;

        } else {
            while (food_stored >= 10) {
                addAnt();
                food_stored -= 10;
            }
        }
    }

    void show() {
        int opacity = int(255);  // hopes & dreams: make this lower with HP
        fill(139, 69, 19, opacity);  // "saddlebrown" apperently 
        rect(pos.x - scale/2, pos.y - scale/2, scale, scale);
    }

    void updateAndShow() {
        update();
        show();
    }

    // actions
    void addAnt() {
        PVector ant_pos = spawn_direction; // s.get(int(random(spawn_directions.size())));

        if (scouts_count < min_amnt_scouts) {
            scouting_ants_on_map.add(new ScoutingAnt(ant_pos, pos));
            scouts_count++;
            num_of_scouting_ants_produced++;

        } else {
        float r = random(1);
            // if (scouts_count/(max(scouts_count + gatherer_count, 1)) < 0.1) {
            if (r < 0.1) {
                // we can change this to a probabilistic condition
                scouting_ants_on_map.add(new ScoutingAnt(ant_pos, pos));
                scouts_count++;
                num_of_scouting_ants_produced++;
            } else {
                waiting_ants.add(new GatheringAnt(ant_pos, pos));
                gatherer_count++;
                num_of_gathering_ants_produced++;
            }
        }
    }

    void releaseAnts() {
        // GatheringAnt free_ant = waiting_ants.get(0);
        // waiting_ants.remove(0);
        // gathering_ants_on_map.add(free_ant);
        for (GatheringAnt a : waiting_ants) {
            gathering_ants_on_map.add(a);
        }

        // waiting_ants.clear();
        waiting_ants = new ArrayList<GatheringAnt>();
    }

    void addFood(int amount) {
        food_stored += amount;
        total_food_return_to_hill += amount;
        release_ants = true;
        food_returned = true;
        // releaseAnts();
    }

    void printStatus() {
        println("Anthill {");
        print("\tFood: "); println(food_stored);
        print("\tWaiting Ants: "); println(waiting_ants.size());
        print("\tRelease Ants: "); println(release_ants);
        print("\tNum Scouts: " + scouts_count + '\n');
        print("\tNum Gatherers: " + gatherer_count + '\n');
        println("}\n");
    }

    // private stuff
    private ArrayList<PVector> initSpawnDirections() {
        ArrayList<PVector> options = new ArrayList<PVector>();
        options.add(PVector.add(pos, new PVector(scale, 0)));
        options.add(PVector.add(pos, new PVector(-scale, 0)));
        options.add(PVector.add(pos, new PVector(0, scale)));
        options.add(PVector.add(pos, new PVector(0, -scale)));

        return removeOutOfBounds(options);
    }


}