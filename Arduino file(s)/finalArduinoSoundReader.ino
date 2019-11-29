#define arraySize 50
#define sensorNum 3

int newSens = A0;

class soundSensor {
  public:
    int lastReading[arraySize];
    int myPin;
    int maxIndex;

    soundSensor(int in) {
      myPin = newSens + in;
    }

    void updateReadings() {
      long audio1 = analogRead(myPin);
      for (int i = 0; i < arraySize - 1; i++) {
        lastReading[i] = lastReading[i + 1];
      }
      lastReading[arraySize - 1] = audio1;
      maxIndex = indexOfMax();
    }
    int indexOfMax() {
      int maxN = 0;
      int arrayIndex = 0;
      for (int i = 1; i < arraySize; i++) {
        if (lastReading[i] > 500 && lastReading[i - 1] < 500) {
          return i;
        }
      }
      return -1;
    }
};


int lastTimes[arraySize];
soundSensor sensors[sensorNum] = {
  soundSensor(A0), soundSensor(A0), soundSensor(A0)
};

unsigned long prevReading = 0;

void setup()
{
  for (int i = i; i < sensorNum; i++) {
    sensors[i].myPin = ('A' + (String)i).toInt();
  }

  Serial.begin(2000000);
  establishConnection();
}


boolean found = false;

void loop() {
  while (true) {

    boolean newSound = true;
    boolean endSound = true;
    for (soundSensor s : sensors) {
      s.updateReadings();
      if (s.maxIndex == -1) newSound = false;
      if (s.maxIndex != -1) endSound = false;
    }
    updateTime();

    if (!found && newSound) {
      found = true;
      String sendVal = String(lastTimes[sensors[0].maxIndex]);
      for (int i = 1; i < sensorNum; i++) {
        sendVal += "," + String(lastTimes[sensors[i].maxIndex]);
      }
      Serial.print(sendVal);
    }
    else if (endSound) {
      found = false;
    }
  }
}


void updateTime() {

  int tem = lastTimes[1];
  for (int i = 0; i < arraySize - 1; i++) {
    lastTimes[i] = lastTimes[i + 1] - tem;
  }
  lastTimes[arraySize - 1] = micros() - prevReading + lastTimes[arraySize - 2];
  prevReading = micros();
}
void establishConnection() {
  while (Serial.available() <= 0) {
    Serial.println("A");   // send a capital A
    delay(100);
  }
}

