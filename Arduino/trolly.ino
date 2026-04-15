#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Servo.h>
#include <SoftwareSerial.h>

// LCD
LiquidCrystal_I2C lcd(0x27, 16, 2);

// Servo
Servo doorServo;
const int servoPin = 6;

// Bluetooth
SoftwareSerial bt(10, 11); // RX, TX

// IR Sensor
const int irSensorPin = 2;

// Variables
int count = 0;
bool btAddRequest = false;   // BT sent '1'
bool irDetected   = false;

bool irLastState = HIGH;
unsigned long lastIRTime = 0;
const int debounceDelay = 500;

void setup() {
  pinMode(irSensorPin, INPUT);

  doorServo.attach(servoPin);
  doorClose();

  lcd.init();
  lcd.backlight();

  bt.begin(9600);

  showWelcome();
  displayCount();
}

void loop() {

  // -------- BLUETOOTH --------
  if (bt.available()) {
    char cmd = bt.read();

    // User wants to ADD item
    if (cmd == '1') {
      btAddRequest = true;
    }

    // REMOVE item
    else if (cmd == '2') {
      if (count > 0) count--;
      displayCount();
      doorOpen(); // stay open
    }

    // CLOSE door
    else if (cmd == '3') {
      doorClose();
    }

    // FINAL COUNT
    else if (cmd == '4') {
      showFinalCountAndReset();
    }
  }

  // -------- IR SENSOR --------
  bool irState = digitalRead(irSensorPin);

  if (irState == LOW && irLastState == HIGH &&
      (millis() - lastIRTime > debounceDelay)) {

    irDetected = true;
    lastIRTime = millis();
  }
  irLastState = irState;

  // -------- BOTH CONDITIONS CHECK --------
  if (btAddRequest && irDetected) {
    count++;
    displayCount();
    servoAddItem();

    // reset flags
    btAddRequest = false;
    irDetected = false;
  }
}

// -------- WELCOME --------
void showWelcome() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Welcome");

  String msg = "Smart Trolley System ";
  for (int i = 0; i < msg.length() - 15; i++) {
    lcd.setCursor(0, 1);
    lcd.print(msg.substring(i, i + 16));
    delay(250);
  }
  delay(2000);
  lcd.clear();
}

// -------- DISPLAY COUNT --------
void displayCount() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Smart Trolley");
  lcd.setCursor(0, 1);
  lcd.print("Count: ");
  lcd.print(count);
}

// -------- FINAL COUNT --------
void showFinalCountAndReset() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Final Count:");
  lcd.setCursor(0, 1);
  lcd.print(count);

  delay(10000);

  count = 0;
  btAddRequest = false;
  irDetected = false;

  showWelcome();
  displayCount();
}

// -------- SERVO --------
void doorOpen() {
  doorServo.write(90);
}

void doorClose() {
  doorServo.write(0);
}

// Add item → open 2s → close
void servoAddItem() {
  doorOpen();
  delay(2000);
  doorClose();
  delay(2000);
}
