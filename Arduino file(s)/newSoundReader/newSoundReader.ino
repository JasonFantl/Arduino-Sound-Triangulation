
#define arraySize 80 
//This will depend on the size of the space you are working in
#define sensorNum 3
#define soundThresh 500

int lastTimes[arraySize];
int sensorReadings[sensorNum][arraySize];
int sensorPins[] = {A0, A1, A2};

unsigned long prevReading = 0;

void setup()
{
  //Initalize each sensors array
  for (int i = 0; i < sensorNum; i++) {
    for (int j = 0; j < arraySize; j++) {
      sensorReadings[i][j] = 0;
    }
  }

  Serial.begin(2000000);
}


boolean found = false;

void loop() {
  while (true) { //while true is supposed to be faster then running in loop

    boolean newSound = true;
    boolean endSound = true;
    
    for (int i = 0; i < sensorNum; i++) {
      updateReadings(i);
      if (indexOfMax(i) == -1) {
        newSound = false;
      }
      else {
        endSound = false;
      }
    }
    updateTime();

    //Construct and send data packet
    if (!found && newSound) {
      found = true;
      String sendVal = String(lastTimes[indexOfMax(0)]);
      for (int i = 1; i < sensorNum; i++) {
        sendVal += "," + String(lastTimes[indexOfMax(i)]);
      }
      Serial.println(sendVal);

    }
    else if (endSound) {
      found = false;
    }
  }
}

//Reads and stores all the new values
void updateReadings(int sensorIndex) {
  long audio1 = analogRead(sensorPins[sensorIndex]);
  for (int i = 0; i < arraySize - 1; i++) {
    sensorReadings[sensorIndex][i] = sensorReadings[sensorIndex][i + 1];
  }
  sensorReadings[sensorIndex][arraySize - 1] = audio1;
}

//Returns the first time the pre-determined threshhold value was met
int indexOfMax(int sensorIndex) {
  for (int i = 1; i < arraySize; i++) {
    if (sensorReadings[sensorIndex][i] > soundThresh && sensorReadings[sensorIndex][i - 1] < soundThresh) {
      return i;
    }
  }
  return -1;
}

//Update time isn't constant, and so it is stored in an array every update as the time difference from the last update
void updateTime() {
  int tem = lastTimes[1];
  for (int i = 0; i < arraySize - 1; i++) {
    lastTimes[i] = lastTimes[i + 1] - tem;
  }
  lastTimes[arraySize - 1] = micros() - prevReading + lastTimes[arraySize - 2];
  prevReading = micros();
}
