class GridMap {
    GridMap() {}

    void show() {
        for (int i = 0; i < board_size; i++) {
            for (int j = 0; j < board_size; j++) {
                int x = i*scale;
                int y = j*scale;

                fill(255, 255, 255, 0);
                stroke(0);

                rect(x, y, scale, scale);
            }
        }
    }

}