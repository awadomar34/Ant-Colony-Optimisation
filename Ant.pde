import java.util.*;


class Ant {
    PVector pos;
    PVector orientation;
    boolean has_food;
    int carry_amnt;
    float q_A;
    float q_B;
    int steps_no_food;
    int steps_no_hill;
    float phero_sense;


    ArrayList<PVector> directions;
    
    Ant(PVector init_pos, PVector last_pos) {
        pos = init_pos;
        orientation = PVector.sub(pos, last_pos);
        has_food = false;
        carry_amnt = 0;
        q_A = q0_A;
        q_B = q0_B;
        steps_no_food = 0;
        steps_no_hill = 0;
        phero_sense = s0;

        
        // addPheromon(new Pheromon(pos, q_A, has_food));


        directions = new ArrayList<PVector>();
        directions.add(new PVector(scale, 0));
        directions.add(new PVector(-scale, 0));
        directions.add(new PVector(0, scale));
        directions.add(new PVector(0, -scale));
    }



    void update() {
        steps_no_food++;
        steps_no_hill++;

        // update drop rate 
        updateDropRates();

        // update phero sense
        updateSensitivity();
    }

    void updateDropRates() {
        q_A = q0_A*exp(-beta*steps_no_hill);
        q_B = q0_B*exp(-beta*steps_no_food);
    }

    void updateSensitivity() {
        // if (steps_no_food > 0) {
        //     phero_sense = s0 - ds*steps_no_hill;
        // } else {
        //     phero_sense = s0;
        // }
        phero_sense = s0 - ds*steps_no_hill; 
        
    }

    void show() {
        // fill(255); // white dot
        ellipse(pos.x, pos.y, 8, 8);
    }

    void updateAndShow() {
        update();
        show();
    }


    // movement functions
    void moveTo(PVector new_pos) {
        // drop phero
        if (has_food) {
            addPheromon(new Pheromon(pos, q_B, has_food));
            // addPheromon(new Pheromon(pos, q_A, !has_food));
        } else {
            addPheromon(new Pheromon(pos, q_A, has_food));
        }

        orientation = PVector.sub(new_pos, pos);
        pos = new_pos;
    }

    
    PVector pheroGradMove(String setting, char phero_type) {
        // get pheromons near by
        ArrayList<Pheromon> pheros_in_sight = new ArrayList<Pheromon>();
        for (PVector d : directions) {
            Integer k = posToInt(PVector.add(pos, d));

            if (phero_type == 'A') {
                if (global_A_pheromons.containsKey(k)) {
                    pheros_in_sight.add(global_A_pheromons.get(k));
                }
            } else {
                if (global_B_pheromons.containsKey(k)) {
                    pheros_in_sight.add(global_B_pheromons.get(k));
                }
            }
        }

        // if no pheros => next_move = randomMove()
        // else:
        //   sort pheros
        //   
        //   if "min" => phero_dir = first phero, others = pheros tail
        //   if "max" => phero_dir = last phero, others = pheros head
        //   
        //   r = random()
        //   if r < phero_sense => next_move = phero_dir
        //   else:
        //      if others is empty: => next_move = randomMove()
        //      else:
        //         next_move = random.choice(others)
        PVector next_move;
        if (pheros_in_sight.size() == 0) {
            next_move = randomMove();
        } else {
            Collections.sort(pheros_in_sight);

            Pheromon phero_dir;
            List<Pheromon> others;
            if (setting.toLowerCase().equals("min")) {
                phero_dir = pheros_in_sight.get(0);
                others = pheros_in_sight.subList(1, pheros_in_sight.size());

            } else {
                phero_dir = pheros_in_sight.get(pheros_in_sight.size() - 1);
                others = pheros_in_sight.subList(0, pheros_in_sight.size() - 1);
                
            }

            float r = random(1);
            if (r < phero_sense) {
                next_move = phero_dir.pos;
            } else {
                if (others.size() == 0) {
                    next_move = randomMove();
                } else {
                    next_move = others.get(int(random(others.size()))).pos;
                }
            }

        }

        return next_move;

    }
    
    PVector randomMove() {
        ArrayList<PVector> not_forward = new ArrayList<PVector>();
        for (PVector d : directions) {
            if (!d.equals(orientation) && !d.equals(PVector.mult(orientation,-1))) {
            // if (!d.equals(orientation)) {
                not_forward.add(PVector.add(pos, d));
            }
        }
        not_forward = removeOutOfBounds(not_forward);

        PVector forward = PVector.add(pos, orientation);

        if (isOutOfBounds(forward)) {
            return not_forward.get(int(random(not_forward.size())));
        } else {
            float r = random(1);
            if (r < 1 - not_forward.size()*alpha/(not_forward.size()+1)) {
                return forward;
            } else {
                return not_forward.get(int(random(not_forward.size())));
            }

        }

    }

    ArrayList<PVector> getViableMoves() {
        // get all the moves
        ArrayList<PVector> options = new ArrayList<PVector>();
        options.add(PVector.add(pos, new PVector(scale, 0)));
        options.add(PVector.add(pos, new PVector(-scale, 0)));
        options.add(PVector.add(pos, new PVector(0, scale)));
        options.add(PVector.add(pos, new PVector(0, -scale)));

        // remove last move
        PVector last_move = PVector.sub(pos, orientation);
        ArrayList<PVector> options2 = new ArrayList<PVector>();
        for (int i = 0; i < options.size(); i++) {
            if (!options.get(i).equals(last_move)) {
                options2.add(options.get(i));
            }
        }

        // remove out of bounds
        return removeOutOfBounds(options2);
    }

    // enviroment observing functions
    Anthill hillInReach() {
        ArrayList<PVector> reach = new ArrayList<PVector>();
        reach.add(PVector.add(pos, new PVector(scale, 0)));
        reach.add(PVector.add(pos, new PVector(-scale, 0)));
        reach.add(PVector.add(pos, new PVector(0, scale)));
        reach.add(PVector.add(pos, new PVector(0, -scale)));

        for (PVector p : reach) {
            int key = posToInt(p);
            Anthill hill = global_hill.get(key);

            if (hill != null) {
                return hill;
            }

        }

        return null;
    }

    Food foodInReach() {
        ArrayList<PVector> reach = new ArrayList<PVector>();
        reach.add(PVector.add(pos, new PVector(scale, 0)));
        reach.add(PVector.add(pos, new PVector(-scale, 0)));
        reach.add(PVector.add(pos, new PVector(0, scale)));
        reach.add(PVector.add(pos, new PVector(0, -scale)));

        for (PVector p : reach) {
            int key = posToInt(p);
            Food fd = global_food.get(key);

            if (fd != null) {
                return fd;
            }

        }

        return null;
    }

    // enviroment interacting functions
    void takeFood(Food fd) {
        addPheromon(new Pheromon(pos, q_A, false));

        steps_no_food = 0;  // reset food step counter

        fd.takeFood(carry_amnt);
        has_food = true;
 
        
    }

    void dropFood(Anthill hill) {
        addPheromon(new Pheromon(pos, q_B, true));
        steps_no_hill = 0;
        hill.addFood(carry_amnt);
        has_food = false;
    }

    

}