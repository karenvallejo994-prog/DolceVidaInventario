package com.dolcevida.test;

import com.dolcevida.model.Usuario;
import com.dolcevida.util.HibernateUtil;
import org.hibernate.Session;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class AutenticacionCoreTest {

    @Test
    public void testVerificarConexionYLoginReal() {
        System.out.println("INICIANDO PRUEBA UNITARIA AUTOMATIZADA JUNIT JUPITER...");
        
        // 1. Apertura experimental de la sesión de base de datos
        Session session = HibernateUtil.getSessionFactory().openSession();
        
        // 2. Variables que coinciden con los datos de MySQL
        String usuarioEsperado = "karen_vallejo";
        String claveEsperada = "admin123";
        
        // 3. Ejecución de la consulta HQL
        Usuario usuarioRecuperado = (Usuario) session.createQuery("FROM Usuario WHERE usuario = :u AND contrasena = :p")
                .setParameter("u", usuarioEsperado)
                .setParameter("p", claveEsperada)
                .uniqueResult();
        
        session.close();
        
        // 4. Afirmaciones de control JUnit
        Assertions.assertNotNull(usuarioRecuperado, "Fallo Crítico: No se pudo extraer el registro desde MySQL.");
        Assertions.assertEquals("Administrador", usuarioRecuperado.getRol(), "Fallo Crítico: El rol no coincide.");
        
        System.out.println("✅ INFORME DE PRUEBAS JUNIT: Módulo validado con éxito.");
    }
}
