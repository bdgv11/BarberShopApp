library globals;

// Variables para agendar la cita y no estar recargando todo el widget al usar
// el setState() cuando se seleccionan los servicios..

//Appointment
String servicioSeleccionado = '';
int indexServicio = 100;
int precioServicio = 0;

//
bool isAdmin = false;

//
double totalFinalizadas = 0;
double totalGeneralDelDia = 0;
int cantCitas = 0;
int cantCitasFinalizadas = 0;

// History
int cantHistCitas = 0;
