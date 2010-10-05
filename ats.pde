

#define DISPLAYS 2
#define WRITEDELAY 0
#define UPDATEFREQ 1
#define READFREQ 100
#define RESETDELAY 0
#define TOLERANCE 10


int clockPin = 2;
int resetPin = 3;
int dataPin = 4;
int displayPins[DISPLAYS] = {6,5};
int potPin = 0;
int tempPin = 1;
int relayPin = 7;

int numberSegments[][9] = 
{
  {HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,LOW,LOW},
  {LOW,LOW,LOW,LOW,HIGH,HIGH,LOW,LOW},
  {HIGH,HIGH,LOW,HIGH,HIGH,LOW,HIGH,LOW},
  {HIGH,HIGH,HIGH,HIGH,LOW,LOW,HIGH,LOW},
  {LOW,HIGH,HIGH,LOW,LOW,HIGH,HIGH,LOW},
  {HIGH,LOW,HIGH,HIGH,LOW,HIGH,HIGH,LOW},
  {HIGH,LOW,HIGH,HIGH,HIGH,HIGH,HIGH,LOW},
  {HIGH,HIGH,HIGH,LOW,LOW,LOW,LOW,LOW},
  {HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,HIGH,LOW},
  {HIGH,HIGH,HIGH,HIGH,LOW,HIGH,HIGH,LOW},
};

void setup()   {       

  Serial.begin(9600);  
  pinMode(clockPin, OUTPUT);     
  pinMode(resetPin, OUTPUT);     
  pinMode(dataPin, OUTPUT);
  pinMode(relayPin, OUTPUT);
  
  setDisplayMode();
  disableAllDisplays();
 
 digitalWrite(clockPin, LOW);
 digitalWrite(dataPin, LOW);
 digitalWrite(relayPin, LOW);
 
 resetShiftRegister();
}

void loop()                     
{
  int potVal = analogRead(potPin);
  int tempVal = analogRead(tempPin);
  Serial.println(potVal);
  Serial.println(tempVal);
  setRelay(potVal, tempVal);
  int i = potVal / 100;
    displayNumber(i,READFREQ);
  //resetShiftRegister();
}

void resetShiftRegister()
{
 digitalWrite(resetPin, LOW);
 //delay(RESETDELAY);
 digitalWrite(resetPin, HIGH);
}


void writeData(int level)
{
    digitalWrite(dataPin, level);
    digitalWrite(clockPin, HIGH);
    //delay(WRITEDELAY);
    digitalWrite(clockPin, LOW);
}

void displayNumber(int number, int time)
{
  Serial.println(number);
  if(number >= 100){
    number %= 100;
  }
  
  int firstDigit = number - (number % 10);
  int secondDigit = number % 10;
    
  for(int i = time/UPDATEFREQ;i>0;i--){
  //resetShiftRegister();
  for(int i=0;i<8;i++)
  {
    writeData(numberSegments[firstDigit][i]);
  }
  enableDisplay(0);
  delay(UPDATEFREQ);
  disableDisplay(0);
  
  for(int i=0;i<8;i++)
  {
    writeData(numberSegments[secondDigit][i]);
  }
  enableDisplay(1);
  delay(UPDATEFREQ);
  disableDisplay(1);
  }
}

void disableDisplay(int displayNum){
  digitalWrite(displayPins[displayNum], HIGH);
}

void enableDisplay(int displayNum){
  digitalWrite(displayPins[displayNum], LOW);
}

void disableAllDisplays(){
  for(int i=0;i<DISPLAYS;i++){
    disableDisplay(i);
  }
}

void setDisplayMode(){
  for(int i=0;i<DISPLAYS;i++){
    pinMode(displayPins[i], OUTPUT);    
  }
}

void setRelay(int potVal, int tempVal){
  if((potVal + TOLERANCE) > tempVal)
    digitalWrite(relayPin, LOW);
  
  if((tempVal - TOLERANCE) > potVal)
    digitalWrite(relayPin, HIGH);
}


