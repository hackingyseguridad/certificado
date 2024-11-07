INTRODUCCION:
La computación cuántica representara una amenaza significativa para los sistemas de seguridad actuales. Las computadoras cuánticas, gracias a su capacidad de realizar cálculos exponencialmente más rápidos que las computadoras clásicas, podrían romper de forma rapida algoritmos de cifrado actuales.

RIESGOS:
1.- Actualmente dependemos de la PKI, que es la infraestructura que verifica la confianza, esta basada en cifrados rotos como RSA o curva elipita DH; RSA y DH se basan en la vasan en la factorización, que requeriria años de computo con la tecnologias actual. Con computacion cuantica sera facilmente romper en poco tiempo, ya que se sabe como.
2.- Diccionarios HASH, se podria comprobar diccionarios con milones de HASES en pocos segudos hasta dar con la palabra cifrada = HASH
3.- La capacidad mayor de cpmputo podria facilitar romper cifrados con nuevas vulnerabilidades, por inyección u otras nuevas tecnicas que estan aun por descubrirse.
por ej.: aLgoritmo de Grover (1996) sera una amenaza en la critptografia simetrica, en la busqueda de claves, como AES o SHA256 con HASES, quiza como posible solución es  aumentar el algoritmo de la claves. Algoritmo de Shor (1994) que permite descomponer en factores primos un numero compuesto en un tiempo. la amenaza seria en la criptografia asimetrica con claves privadas de la PKI.

NUEVOS CIFRADOS:
1.- ML-KEM (Module Lattice Key Encapsulation Mechanism) o crystal - KYBER, basada en una estructura compleja o reticulos,  se utiliza principalmente para el intercambio seguro de claves encriptadas. Esto significa que si dos dispositivos quieren comunicarse de forma segura, pueden usar ML-KEM para generar una clave secreta que solo ellos conozcan, y luego usar esa clave para cifrar sus mensajes. Resistencia a ataques cuánticos: . Eficiencia: ML-KEM es relativamente eficiente en términos de tiempo de cálculo y tamaño de clave, lo que lo hace adecuado para su implementación en una amplia variedad de dispositivos. Seguridad: ML-KEM se basa en problemas matemáticos que se consideran difíciles de resolver, incluso para las computadoras cuánticas.
 - se integrara en OpenSSH, en las suite cifrados ofrecidas para la versión de TLS 1.X: como firma, intercambio seguro de claves;  este proceso permite a dos partes establecer una comunicación segura sin compartir una clave secreta de antemano. Esto se hace actualmente  mediante algoritmos rotos Diffie-Hellman, ECDH, RSA que utilizan pares de claves: una pública y otra privada.
p.ej. TLS 1.3  ( AES_256_CGM +  SHA384 ) Protocolo ( Cifrado y modo + HASH algoritm ) ; cifrado AES, tamaño cadena HASH 256, modo CGM +  HASH algotimo SHA384, que hace de control de integridad  - sera  ML-KEM-512 el que se encargara del intercambio de claves segura, combinado en conjunto con AES-256-GCM

2- ML-DSA (Module Lattice Digital Signature Algorithm) o Cristal Dilitium, basada en una estructura compleja o reticulos,  se utiliza principalmente para la firma digital de documentos. Esto significa que se emplea para:
Autenticar la identidad del firmante: Al firmar un documento digitalmente con ML-DSA, se garantiza que la persona que lo firmó es quien dice ser.
Verificar la integridad del documento: ML-DSA permite verificar si un documento ha sido alterado desde que fue firmado. Esto es fundamental para garantizar la confiabilidad de los documentos digitales.

3- SLH-DSA, o Stateless Hash-Based Digital Signature Algorithm, p SPHINICS +, basado en HASH,  se utiliza principalmente para la firma digital de documentos, pero con una característica distintiva: no requiere un estado interno. Esto significa que cada firma es independiente de las anteriores, lo que lo hace especialmente útil en situaciones donde:
La seguridad a largo plazo es crucial: SLH-DSA ofrece una mayor resistencia a ataques a largo plazo, ya que cada firma es independiente y no compromete la seguridad de firmas anteriores.
Se requiere una alta eficiencia: Al no requerir un estado interno, SLH-DSA puede ser más eficiente en términos de tiempo de cálculo y tamaño de clave en ciertas aplicaciones.
Se necesita una alta seguridad en entornos con recursos limitados: SLH-DSA es una buena opción para dispositivos con recursos limitados, como tarjetas inteligentes o dispositivos IoT.

4.- Falcon - es un algoritmo de firma digital que ha sido seleccionado por el Instituto Nacional de Estándares y Tecnología (NIST) de Estados Unidos como uno de los nuevos estándares de criptografía post-cuántica. Esto significa que Falcon está diseñado para resistir los ataques de las futuras computadoras cuánticas, que se espera que sean capaces de romper los sistemas de cifrado actuales con relativa facilidad.
La principal función de Falcon es garantizar la autenticidad y la integridad de los datos digitales. En términos más sencillos, Falcon se utiliza para:
- Firmar digitalmente documentos: Esto permite verificar la identidad del firmante y asegurar que el documento no ha sido alterado desde que se firmó.
- Autenticar transacciones: En el comercio electrónico, Falcon puede utilizarse para verificar la identidad de las partes involucradas en una transacción y garantizar que los datos no hayan sido manipulados.
- Proteger la comunicación: Falcon puede utilizarse para asegurar la confidencialidad de las comunicaciones al garantizar que solo las partes autorizadas puedan acceder a los mensajes.

HACKINGYSEGURIDAD.COM 2024