import java.io.*;
import java.lang.*;
import roombacomm.*;

/**
 *  Read sensors to detect bumps and turn away from them while driving
 * <p>
 *  Run it with something like: <pre>
 *   java roombacomm.BumpTurn /dev/cu.KeySerial1
 *  </pre>
 *
 */
public class ejroomba {

    static String usage =
    static boolean debug = false;
    static boolean hwhandshake = false;

    //Calibración de la longitud de la roomba y del giro de la misma
    public static class roombaspecs{
    	public static int roombasize=340;
    	public static int fullspin=350;
    }

    public static void main(String[] args) {

		//Conexión con el dispositivo roomba mediante puerto serie
        String portname = "/dev/tty.FireFly-112A-SPP";  // e.g. "/dev/cu.KeySerial1"

        RoombaCommSerial roombacomm = new RoombaCommSerial();
        roombacomm.setProtocol("OI"); //Si es un modelo nuevo 5XX negro
        roombacomm.debug = debug;
        roombacomm.waitForDSR = hwhandshake;


        if( ! roombacomm.connect( portname ) ) {
            System.out.println("Couldn't connect to "+portname);
            System.exit(1);
        }

        System.out.println("Roomba startup");
        // Inicializar el roomba en modo seguro
        roombacomm.startup();
        roombacomm.control();
        // Poner el roomba en modo control total
        roombacomm.full();
        roombacomm.pause(100);

        // Enciende el botï¿½n central en rojo para saber que estamos ejecutandolo
        roombacomm.setLEDs(false, true, false, false, false, false, 255, 255);

        int d_front=0; 	//Distancia frontal máxima
        int d_lat=0;	//Distancia lateral máxima
        int d_min=0;	//Mínimo entre ambas

        //Calculo distancia frontal máxima
        d_front=get_front_dist(roombacomm);
        System.out.println("D Front= " + d_front);

        roombacomm.updateSensors();

        //Calculo distancia lateral máxima
        d_lat=get_lat_dist(roombacomm,d_front);
        System.out.println("D Lateral= " + d_lat);

        //Calculo distancia lateral máxima
        d_min=checkmindist(d_front,d_lat);

        //Ejecución de la función de dibujo del cuadrado
        square(roombacomm, d_min);
        roombacomm.delay(500);
        roombacomm.stop();

        //Ejecución de la función de dibujo del triangulo
        triangle(roombacomm,d_min);
        roombacomm.delay(500);
        roombacomm.stop();

        //Ejecución de la función de dibujo de la equis
        cross(roombacomm,d_min);
        roombacomm.delay(500);
        roombacomm.stop();

        //Ejecución de la función de dibujo del circulo
        circle(roombacomm,d_min);

        roombacomm.stop();

		//Desconexión del dispositivo
        System.out.println("Disconnecting");
        roombacomm.powerOff();
        roombacomm.disconnect();

        System.out.println("Done");
    }

    /** check for keypress, return true if so */
    public static boolean keyIsPressed() {
        boolean press = false;
        try {
            if( System.in.available() != 0 ) {
                System.out.println("key pressed");
                press = true;
            }
        } catch( IOException ioe ) { }
        return press;
    }

	//Función de cálculo del factor de conversión
	public static int fconv(int x) {
		return (1000/131)*x;
	}

	//Función para el cálculo de la distancia frontal máxima
	public static int get_front_dist(RoombaCommSerial roombacomm) {
		boolean bump=false;
		boolean first=false;
        int dist_total=0;
        int absdist=0;
        int d_front=0;

        while(bump==false) {
			roombacomm.goForward();

			if (first==true) {
				dist_total+=roombacomm.distance();
			}
			first=true;

			roombacomm.updateSensors();
			bump=roombacomm.bump();


			if (bump==true) {
				roombacomm.stop();
	        		roombacomm.updateSensors();
	            		absdist=Math.abs(dist_total);
	            		roombacomm.goBackward(fconv(absdist)+roombaspecs.roombasize);
	            		d_front=fconv(absdist);
	        	}

        }
        return d_front;
	}

	//Función para el cálculo de la distancia lateral máxima
	public static int get_lat_dist(RoombaCommSerial roombacomm,int d_front) {
	  	boolean bump=false;
	  	boolean first=false;
        int dist_total=0;
        int absdist=0;
        int d_lat=0;

        roombacomm.spinLeft(roombaspecs.fullspin/4);

        while(bump==false && fconv(Math.abs(dist_total))<d_front) {
			roombacomm.goForward();

			if (first==true) {
				dist_total+=roombacomm.distance();
			}
			first=true;

			roombacomm.updateSensors();
			bump=roombacomm.bump();


			if (bump==true || fconv(Math.abs(dist_total))>=d_front) {
				roombacomm.stop();
	        	roombacomm.updateSensors();
	            absdist=Math.abs(dist_total);
	            roombacomm.goBackward(fconv(absdist)+roombaspecs.roombasize);
	            d_lat=fconv(absdist);
	        }

        }

        roombacomm.spinRight(roombaspecs.fullspin/4);
        return d_lat;
	}

	//Función para el cálculo de la distancia mínima
	public static int checkmindist(int d_front, int d_lat) {

		int d_min=0;

		if (d_front < d_lat) {
        	d_min=(int)(d_front);
        	}
        else {
        	d_min=(int)(d_lat);
        	}

		return d_min;
	}

	//Función de dibujo del cuadrado
	public static void square(RoombaCommSerial roombacomm, int d_min) {
		for (int i=0;i<4;i++) {
			roombacomm.goForward(d_min);
			roombacomm.spinLeft(roombaspecs.fullspin/4);
		}
	}

	//Función de dibujo del triangulo
	public static void triangle(RoombaCommSerial roombacomm, int d_min) {
		for (int i=0;i<3;i++) {
			roombacomm.goForward(d_min);
			roombacomm.spinLeft(roombaspecs.fullspin/2-roombaspecs.fullspin/6);
		}
	}

	//Función de dibujo de la equis
	public static void cross(RoombaCommSerial roombacomm, int d_min) {
		int hip=((int)Math.sqrt(2))*d_min;
		roombacomm.spinLeft(roombaspecs.fullspin/8);
		roombacomm.goForward(hip);
		roombacomm.goBackward(hip/2);
		roombacomm.spinLeft(roombaspecs.fullspin/4);
		roombacomm.goForward(hip/2);
		roombacomm.goBackward(hip);
		roombacomm.goForward(hip/2);
		roombacomm.spinLeft(roombaspecs.fullspin/4);
		roombacomm.goForward(hip/2);
		roombacomm.spinLeft(roombaspecs.fullspin/4+roombaspecs.fullspin/8);
	}

	//Función de dibujo del circulo
	public static void circle(RoombaCommSerial roombacomm, int d_min) {
		boolean firstp=false;
		int perimetro=(int)(Math.PI*d_min);
		int p_recorr=0;
		int tiempo = time_conver(d_min);
		long tiempo_ini=System.currentTimeMillis();
		long tiempo_final=0;
		float angle = 0;

		roombacomm.goForward(d_min/2);
		roombacomm.updateSensors();
		roombacomm.drive(200, d_min/2);
		while (tiempo_final<tiempo) {
			if (firstp==true) {
				p_recorr+=fconv(Math.abs(roombacomm.distance()));
				tiempo_final=System.currentTimeMillis()-tiempo_ini;

			}
			firstp=true;
			roombacomm.updateSensors();
		}

	}

	//Función de conversión del tiempo y la distancia
	public static int time_conver(int distance) {
		int factor;
		double auxfactor;
		factor = (int) auxfactor;
		auxfactor = 1.312*Math.pow(10, -5)*Math.pow(distance, 3) - 0.0081*Math.pow(distance, 2) + 10.101* distance + 3118.5;
		return factor;
	}
}



