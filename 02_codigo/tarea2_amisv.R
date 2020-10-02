###################################
# Descarga de datos desde RStudio #
# Tarea 2 - Vis 2020              #
# Ami Gabriela Sosa Vera          #
###################################


# Definición de un loop o bucle ----

# Un bucle o loop es una secuencia que ejecuta un mismo chunk de código las veces que sean necesarias hasta que la condición lógica se cumpla. 

# Descripción del ejemplo de clase CONAGUA ----

# Paso 1: Definir qué queremos hacer, en este caso queremos bajar los registros de lluvias históricos del SMN para la CDMX. 

# Paso 2: Entrar a la página de CONAGUA y localizar la sección en la que podamos descargar las bases de datos que nos interesan. En este caso están en la seccion de información estadistica climatológica. 

# Pagina de consulta:
# https://smn.conagua.gob.mx/es/climatologia/informacion-climatologica/informacion-estadistica-climatologica

# Paso 3: Al seleccionar un punto georreferenciado de interés, se despliega un popup con varios tipos de información. De ahí seleccionar la información que te interesa, que es climatología diaria. En una nueva página se despliega la base de datos de precipitación histórica de ese punto en específico.

# Paso 4: Como es un archivo .txt, copio la url y la pego en el script de RStudio para ver los componentes de la dirección, ya que eso necesitaremos para la descarga automática.

# Links de descarga de la climatologia diaria (Estación Meteorológica Tláhuac):
# https://smn.conagua.gob.mx/tools/RESOURCES/Diarios/9051.txt 

# Paso 5: Cargamos nuestro setup y las librerías necesarias. Abrimos Import Dataset > From Text (readr) y en File/Url pegamos la ruta del archivo sin comillas. Si la base de datos tiene símbolos raros, vamos a Locale > Configure y  seleccionamos UTF-8. Luego podemos cambiar el Delimitador por espacios en blanco en lugar de comas.Copiamos el Code Preview y lo guardamos en un objeto llamado bd.

# Setup ----
Sys.setlocale("LC_ALL", "es_ES.UTF-8") 
options(scipen=999)

# Librerias ----
library(tidyverse)
library(curl)
library(zip)

# Descarga n = 1
bd <- read_table2("https://smn.conagua.gob.mx/tools/RESOURCES/Diarios/9051.txt", 
                  skip = 20) %>% 
  mutate(Estacion = "9051") # Creamos una nueva columna con el número de la estación 9051 que corresponde la Estación Meteorológica Tláhuac.  

# Paso 6: Escribir un nuevo archivo csv con la funcion write.csv. Tenemos cuatro argumentos: el primero es el nombre de nuestra base de datos (bd), después está la ruta del archivo .csv, establecemos FALSE en row.names y le decimos a R que queremos que use el encoding UTF-8 para eliminar caracteres extraños. 

write.csv(bd, file = "01_Datos/Datos Conagua/9051.csv", row.names = F, na = "", fileEncoding = "UTF-8")

# Paso 7: Repetimos el proceso con otro punto geográfico para identificar las partes que varian en la dirección de las bases datos y desde ahí automatizar el proceso.

# Descarga n = 2
# bd2 <- read_table2("https://smn.conagua.gob.mx/tools/RESOURCES/Diarios/9008.txt", 
#                   skip = 20) %>% 
#   mutate(Estacion = "9008") 

# Paso 8: Vemos que el común denomindor de las estaciones de la CDMX es el 9 y que los números que le siguen representan el número de la estación específica que estamos viendo. 

# Paso 9: Sustituímos la parte variable por un objeto llamado estacion.

# Crear un objeto para la estación de Tlahuac. 
estacion <- "9051"

# Repetimos el proceso de descargar la base de datos, pero en este caso vamos a sustituir el codigo de la estacion por el objeto estacion y ponemos la terminación ".txt" antes de cerrar el paréntesis. 

bd <- read_table2(paste0("https://smn.conagua.gob.mx/tools/RESOURCES/Diarios/", estacion , ".txt"), 
                  skip = 20) %>% # Lo usamos para seleccionar 20 renglones para que no se tomen en cuenta
  mutate(Estacion = estacion) # Ahora cambiamos el valor de la columna Estacion por el contenido del objeto estacion 

write.csv(bd, file = paste0("01_Datos/Datos Conagua/", estacion,".csv"), row.names = F, na = "", fileEncoding = "UTF-8")

# Generamos un archivo .csv con los argumentos de arriba, con la diferencia de que ahora en la ruta del archivo pegamos con paste0() la cadena de texto de la ruta, los valores del objeto estacion y la terminación ".csv"

# Paso 10: Generamos el loop. 

# Serie: Todos los valores entre el 9001 y el 9100. 
# Decidimos que este es el universo del loop 
# Creamos un objeto con este universo de valores.

serie <- 9001:9100

# Abrimos el loop con la función for y le decimos que el objeto estacion (contador) trabaje dentro de la secuencia serie 
# Abrimos corchetes y escribimos el codigo que queremos repetir varias veces

# Con - c() eliminamos de la secuencia los valores que nos dan error
for (estacion in serie[-c(18, 27, 35, 53, 57, 60)]){
  print(estacion) # selecciona un número de la secuencia
  
  # Copiamos la descarga de datos con las partes variables que representa el objeto estacion y cerramos corchetes para correr el loop. 
  bd <- read_table2(paste0("https://smn.conagua.gob.mx/tools/RESOURCES/Diarios/", estacion , ".txt"), 
                    skip = 20) %>% 
    mutate(Estacion = estacion) 
  
  write.csv(bd, file = paste0("01_Datos/Datos Conagua/", estacion,".csv"), row.names = F, na = "", fileEncoding = "UTF-8")
}

# Paso 11: Con la función tryCatch() podemos sistematizar la detección de errores en el loop. 

for (estacion in serie){
  
  # tryCatch() corre el código y si encuentra un error lo ignora y continúa corriendo la secuencia. 
  # Es la forma de evitar el paso de seleccionar con -c() los datos del objeto serie para los que R nos marca un error.
  # Debemos especificar el proceso que va a ejecutar y la función a realizar en caso de que ocurra un error con el argumento error. 
  
  tryCatch({
    bd <- read_table2(paste0("https://smn.conagua.gob.mx/tools/RESOURCES/Diarios/", estacion , ".txt"), 
                      skip = 20) %>% 
      mutate(Estacion = estacion)  
    
    write.csv(bd, file = paste0("01_Datos/Datos Conagua/", estacion,".csv"), row.names = F, na = "", fileEncoding = "UTF-8")  
  }, 
  # Si algo sale mal podemos decirle a R que nos despliegue un mensaje de error para avisarnos para qué estación no corrió el loop. En este caso le decimos que depliegue el mensaje "Error en la estacion " y el número de estación. 
  error = function(e){
    print(paste0("Error en la estacion ", estacion))
  })
  
}

# Descripción de pasos para descarga de datos de INEGI ----

# Paso 1: En este caso queremos conocer el porcentaje de viviendas con televisión en México del censo 2015 del INEGI

# Paso 2: Nos metemos a la sección de tabulados del censo 2015 del INEGI para buscar la base de datos y descargamos dos archivos diferentes para ubicar las partes del URL que son diferentes.

# Url de consulta:
# https://www.inegi.org.mx/programas/intercensal/2015/default.html#Tabulados

# Url de descarga n = 1:
# https://www.inegi.org.mx/contenidos/programas/intercensal/2015/tabulados/14_vivienda_mor.xls

# Url de descarga n = 2:
# https://www.inegi.org.mx/contenidos/programas/intercensal/2015/tabulados/14_vivienda_ags.xls

# Paso 3: Utilizamos la función curl_download() para poder descargar archivos de excel directamente desde internet sin tener que descargarlos a nuestra computadora.

# Caso n = 1: 
curl::curl_download(url = "https://www.inegi.org.mx/contenidos/programas/intercensal/2015/tabulados/14_vivienda_mor.xls", 
                    destfile =  "01_Datos/Datos Censo /HogaresMorelos.xls")
# Con este argumento le indicamos a R la ruta para guardar nuestro archivo. Aquí podemos especificar el nombre del archivo después de la carpeta en la que lo vamos a guardar.

# Paso 4: La parte variable de la URL es la terminación que identifica a cada estado, entonces creamos un objeto que se llame estado al que le asignamos el contenido "mor" porque es como finaliza el primer URL que descargamos. 

# Paso 5: Después podemos sustutir esta parte en la URL con el objeto estado. 

# Reemplazamos la parte variable con objetos: 
estado = "mor"
curl::curl_download(url = paste0("https://www.inegi.org.mx/contenidos/programas/intercensal/2015/tabulados/14_vivienda_", estado, ".xls"), 
                    destfile = "01_Datos/Datos Censo /HogaresMorelos.xls")

# Paso 6: Creamos la secuencia que queremos que use nuestro loop y la guardamos en un objeto que se llame edos que contenga las abreviaturas de todos los estados del país. 

# Conseguimos los demás estados: 
edos <- c("ags", "bc", "bcs", "camp","coah", "col","chis", "chih", "DF", 
          "dgo", "gto", "gro", "hgo", "jal", "mex", "mich","mor", "nay", "nl", 
          "oax_D", "pue", "qro", "qroo","slp", "sin", "son","tab","tamps","tlax","ver","yuc","zac")

# Paso 7: Creamos nuestro loop para que reemplaze el valor del objeto estado con cada uno de los valores de nuestra secuencia y despues pegamos el rpoceso de descarga de datos con los objetos sustituyendo a los valores variables

# Juntamos todo y construimos el loop de descarga: 
for(estado in edos){
  print(estado)
  curl::curl_download(url = paste0("https://www.inegi.org.mx/contenidos/programas/intercensal/2015/tabulados/14_vivienda_", estado, ".xls"), 
                      destfile = paste0("01_Datos/Datos Censo /Hogares", estado, ".xls"))
}
