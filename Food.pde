class Food {
    PVector pos;
    float amount_left;

    Food(PVector init_pos) {
        pos = init_pos;
        amount_left = init_food_amnt;

    }

    void update() {
        // println(amount_left);
    }

    void show() {
        int opacity = int((amount_left / init_food_amnt)*255);
        // println((amount_left));
        // int opacity = 255;
        fill(255, 127, 0, opacity);
        rect(pos.x - scale/2, pos.y - scale/2, scale, scale);
    }

    void updateAndShow() {
        update();
        show();
    }


    void takeFood(int amount) {
        amount_left -= amount;
        food_reached = true;
    }
}