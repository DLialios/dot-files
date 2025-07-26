import sys
import serial

def main():
    if len(sys.argv) < 2:
        print("Error: Serial port not specified.")
        print("Usage: python serial.py <COM_PORT> [BAUD_RATE]")
        return

    port = sys.argv[1]
    baudrate = int(sys.argv[2]) if len(sys.argv) > 2 else 115200

    try:
        with serial.Serial(port, baudrate, timeout=1) as ser:
            print(f"--- Listening on {ser.name} at {baudrate} baud ---")
            while True:
                line = ser.readline()
                if line:
                    print(line.decode('utf-8', errors='ignore'), end='')
    except serial.SerialException as e:
        print(f"\nSerial Error: {e}")
    except KeyboardInterrupt:
        print("\n--- Exiting ---")

if __name__ == "__main__":
    main()
