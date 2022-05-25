class ScoutingAnt extends Ant {


    ScoutingAnt(PVector init_pos, PVector last_pos) {
        super(init_pos, last_pos);

        carry_amnt = 1;
    }
    
    void printStatus() {
        println("Soucting Ant {");
        // PVector p = posToGrid(pos);
        // println("\tPos: (" + p.x + "," + p.y + ")");
        println("\tHas Food: " + has_food);
        println("\tqA: " + q_A);
        println("\tqB: " + q_B);
        println("\tPhero sense: " + phero_sense);
        println("}");
    }

    @Override
    void update() {
        

        // move
        if (has_food) {
            Anthill hill = hillInReach();

            if (hill == null) {
                moveTo(pheroGradMove(phero_direction, 'A'));

            } else {   
                dropFood(hill);
                
            }
        } else {
            Food fd = foodInReach();

            if (fd == null) { moveTo(randomMove());} 
            else { takeFood(fd);}
        }

        super.update(); 

    }

    void show() {
        fill(0); // black dot
        super.show();
    }


    // @Override
    // void moveTo(PVector pos) {
    //     super.moveTo(pos);


    // }
}