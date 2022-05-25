class GatheringAnt extends Ant {
    GatheringAnt(PVector init_pos, PVector last_pos) {
        super(init_pos, last_pos);

        carry_amnt = 2;
    }

    void printStatus() {
        println("Gathering Ant {");
        // PVector p = posToGrid(pos);
        // println("\tPos: (" + ceil(p.x) + "," + floor(p.y) + ")");
        println("\tHas Food: " + has_food);
        println("\tqA: " + q_A);
        println("\tqB: " + q_B);
        println("\tPhero sense: " + phero_sense);
        println("}");
    }

    @Override
    void update() {
        // printStatus();

        if (has_food) {
            Anthill hill = hillInReach();

            if (hill == null) {
                moveTo(pheroGradMove(phero_direction, 'A'));
                // steps_no_hill++;

            } else {
                // steps_no_hill = 0;
                dropFood(hill);
            }

        } else {
            Food fd = foodInReach();

            if (fd == null) {
                moveTo(pheroGradMove(phero_direction, 'B'));

                // steps_no_food++;
                // steps_no_hill++;
            } else {
                // steps_no_food = 0;  // reset food step counter
                takeFood(fd);
                // phero_sense = s0;
            }
        }

        
        super.update();
    }

    void show() {
        // fill(47,79,79); // "darkslategray" dot, who comes up with color names, i want that job
        fill(255,0,255);  // magenta dot
        super.show();
    }

}