public class Game {
    TableOutline tableOutline;            // This file has the "map" objects
    boolean gameOver = false;
    boolean gameStarted = false;
    int score = 0;
    float dt = 1/frameRate;
    PApplet parent;

    Game(PApplet p) {
        this.parent = p;
        tableOutline = new TableOutline();
    }

    void update() {
        if (!gameStarted || gameOver) return;  // Do not update if game hasn't started yet

        if (gameStarted && !gameOver) {
            tableOutline.makeTable();
        }
    }

    void display() {
        if (!gameStarted) {
            displayStartPrompt();  // Display the "START" text
        } else if (gameOver) {
            displayEndPrompt();
        } else {
            ball.display();
            displayScore();
        }
    }

    void displayStartPrompt() {
        pushMatrix();
        fill(255); // White color
        textSize(48);
        textAlign(CENTER, CENTER);
        text("START", 200, 350);
        popMatrix();
    }

    void displayEndPrompt() {
        pushMatrix();
        fill(255,0,0);
        textSize(45);
        text("GAME OVER", 200, 250);

        fill(255);
        textSize(35);
        text("RESTART", 200, 450);
        popMatrix();
    }

    boolean checkStartClicked() {
        if (textButton("START", 48, new Vec2(200, 350)) && !gameStarted) {
            return true;
        }
        return false;
    }

    boolean checkRestartClicked() {
        if (textButton("RESTART", 35, new Vec2(200, 450)) && gameOver) {
            return true;
        }
        return false;
    }
    /*
      void checkStartClicked() {
        if (textButton("START", 48, new Vec2(200, 350)) && !gameStarted) {
          gameStarted = true;
        }
      }

      void checkRestartClicked() {
        if (textButton("RESTART", 35, new Vec2(200, 450)) && gameOver) {
          gameOver = false;
          gameStarted = false;
          score = 0;
        }
      }
    */

    // Add points to the score
    void updateScore(int points) {
        score += points;
    }

    // Display the score on the screen
    void displayScore() {
        pushMatrix();
        fill(255, 255, 255);  // Set color to white
        textSize(20);  // Set font size
        text("Score: " + score, 55, 30);  // Display the score at the top left corner
        popMatrix();
    }

    boolean textButton(String text, int size, Vec2 pos) {
        textSize(size);                 // Set textSize to measure width
        float textW = textWidth(text);

        return (mouseX > pos.x - textW / 2 && mouseX < pos.x + textW / 2 && mouseY > pos.y - size / 2 && mouseY < pos.y + size / 2);
    }
}
