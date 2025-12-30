import java.awt.event.*;
import javax.swing.JFrame;

public class Dice {
    public static int getCh() {
        final JFrame frame = new JFrame();
        final int[] keyHolder = new int[1]; // mutable holder

        synchronized (frame) {
            frame.setUndecorated(true);
            frame.setSize(1, 1);
            frame.setLocationRelativeTo(null);
            frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);

            frame.addKeyListener(new KeyListener() {
                @Override
                public void keyPressed(KeyEvent e) {
                    synchronized (frame) {
                        keyHolder[0] = e.getKeyCode();
                        frame.setVisible(false);
                        frame.dispose();
                        frame.notify();
                    }
                }

                @Override public void keyReleased(KeyEvent e) {}
                @Override public void keyTyped(KeyEvent e) {}
            });

            frame.setVisible(true);

            try {
                frame.wait();
            } catch (InterruptedException ignored) {}
        }

        return keyHolder[0];
    }

    public static void clearScreen() {
        System.out.print("\033[2J\033[H");
        System.out.flush();
    }

    public enum State {
        DICE,
        ROLL,
        EXIT
    }

    public State currentState = State.DICE;
    public int diceValue = 1;
    public boolean roll = true;
    public void showDice() {
        System.out.println("\n    +---+");
        System.out.println("    | " + diceValue + " |");
        System.out.println("    +---+\n");
    }

    public void shakeDice() {
        int n = (int)(Math.random() * 10 + 5);
        for (int i = 0; i < n; i++)
        {
            diceValue = (int)(Math.random() * 6 + 1);
            clearScreen();
            showDice();
            System.out.println(" > Rolling the dice...");
            System.out.println("   Exit");
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                System.exit(0);
            }
        }
        currentState = State.DICE;
    }

    public void diceMenu() {
        showDice();
        System.out.println((roll ? " > " : "   ") + "Roll the dice");
        System.out.println((!roll ? " > " : "   ") + "Exit");

        int inp = getCh();
        handleInput(inp);
    }

    public void handleInput(int inp) {
        switch (inp) {
            case KeyEvent.VK_ENTER: 
                currentState = roll ? State.ROLL : State.EXIT;
                return;

            case KeyEvent.VK_W:
            case KeyEvent.VK_S:
            case KeyEvent.VK_UP:
            case KeyEvent.VK_DOWN:
                roll = !roll;
                currentState = State.DICE;
                return;

            default: return;
        }
    }

    public void start() {
        while (true) { 
            clearScreen();
            if (currentState == State.DICE) diceMenu();
            else if (currentState == State.ROLL) shakeDice();
            else if (currentState == State.EXIT) System.exit(0);
        }
    }

    public static void main(String[] args) {
        Dice game = new Dice();
        game.start();
    }
}
