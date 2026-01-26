import java.awt.event.*;
import java.util.concurrent.TimeUnit;

public class Dice {
    public static int getCh() {
        final int[] keyHolder = new int[1];
        final java.util.concurrent.CountDownLatch latch = new java.util.concurrent.CountDownLatch(1);

        try {
            javax.swing.SwingUtilities.invokeAndWait(() -> {
                javax.swing.JDialog dialog = new javax.swing.JDialog();
                dialog.setUndecorated(true);
                dialog.setSize(1, 1);
                dialog.setLocationRelativeTo(null);
                dialog.setDefaultCloseOperation(javax.swing.JDialog.DO_NOTHING_ON_CLOSE);

                dialog.addKeyListener(new KeyListener() {
                    @Override
                    public void keyPressed(KeyEvent e) {
                        keyHolder[0] = e.getKeyCode();
                        dialog.setVisible(false);
                        dialog.dispose();
                        latch.countDown();
                    }
                    @Override public void keyReleased(KeyEvent e) {}
                    @Override public void keyTyped(KeyEvent e) {}
                });
                dialog.setVisible(true);
                dialog.toFront();
                dialog.requestFocus();
            });

            latch.await();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Interrupted while waiting for key input.");
        } catch (java.lang.reflect.InvocationTargetException e) {
            Throwable cause = e.getCause();
            System.err.println("Invocation error while waiting for key input: " + cause);
            if (cause != null) {
                System.err.println("Stack trace:");
                cause.printStackTrace(System.err);
            }
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
        for (int i = 0; i < n; i++) {
            diceValue = (int)(Math.random() * 6 + 1);
            clearScreen();
            showDice();
            System.out.println(" > Rolling the dice...");
            System.out.println("   Exit");
            try {
                TimeUnit.MILLISECONDS.sleep(100);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
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
            case KeyEvent.VK_ENTER -> currentState = roll ? State.ROLL : State.EXIT;
            case KeyEvent.VK_W, KeyEvent.VK_S, KeyEvent.VK_UP, KeyEvent.VK_DOWN -> {
                roll = !roll;
                currentState = State.DICE;
            }
        }
    }

    public void start() {
        while (true) { 
            clearScreen();
            switch (currentState) {
                case DICE -> diceMenu();
                case ROLL -> shakeDice();
                case EXIT -> System.exit(0);
            }
        }
    }

    public static void main(String[] args) {
        Dice game = new Dice();
        game.start();
    }
}
