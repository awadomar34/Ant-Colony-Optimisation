class Pheromon implements Comparable {
    PVector pos;
    float strength;
    char type;

    Pheromon(PVector init_pos, float init_strgth, boolean isTypeB) {
        pos = init_pos;
        strength = init_strgth;
        if (isTypeB) {
            type = 'B';
        } else {
            type = 'A';
        }
    }

    void update() {
        // strength -= gamma*strength;
        strength -= gamma;
    }

    void show() {
        if (this.strength > 0) {
            color c = color(255, 255, 255);  // white

            int opacity = max(min(int(strength*255), 255), 0);

            if (type == 'A') {
                // c = color(255, 255, 0, opacity);  // yellow
                c = color(0, 0, 255, opacity);
            } else {
                c = color(0, 255, 0, opacity);  // green
            }

            fill(c);
            noStroke();
            ellipse(pos.x, pos.y, 5, 5);
        }
    }

    void updateAndShow() {
        update();
        show();
    }

    @Override
    int compareTo(Object  other) {
        if (this.strength > ((Pheromon) other).strength) {
            return 1;
        } else {
            return -1;
        }
    }

}