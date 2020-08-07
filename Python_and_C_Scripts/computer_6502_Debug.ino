// By Ben Grudzien, refer to Ben Eater

const char ADDR[] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52}; // A0 to A15
const char DATA[] = {39, 41, 43, 45, 47, 49, 51, 53}; // D0 to D7
#define CLOCK 2 // Only some pins support interrupts
#define READ_WRITE 3 // Check data bus stats

void setup() {
  // put your setup code here, to run once:
  for (int n = 0; n < 16; n += 1){ // Address read
    pinMode(ADDR[n], INPUT);
  }
  for (int n = 0; n < 8; n += 1){ // Data read
    pinMode(DATA[n], INPUT);
  }  
  pinMode(CLOCK, INPUT);
  pinMode(READ_WRITE, INPUT);
  
  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING); // This allows for single step
  
  Serial.begin(57600); // Standard baud rate
}

void onClock(){

   char output[15];
   
   unsigned int address = 0; // To get address as number to convert to hex or whatever
   for (int n = 0; n < 16; n += 1){
    int bit = digitalRead(ADDR[n]) ? 1 : 0; // If True 1, else 0
    Serial.print(bit);
    address = (address << 1) + bit; // Shifts to left
  }
   Serial.print("   "); 

   unsigned int data = 0;
   for (int n = 0; n < 8; n += 1){
    int bit = digitalRead(DATA[n]) ? 1 : 0; // If True 1, else 0
    Serial.print(bit);
    data = (data << 1) + bit;
  }  

  sprintf(output, "   %04x %c %02x", address, digitalRead(READ_WRITE) ? 'R' : 'W', data); // address = 4 digit hex, data = 2 digit hex
  Serial.println(output); // New line
}


void loop() {
  // put your main code here, to run repeatedly:

}
