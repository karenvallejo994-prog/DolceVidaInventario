package com.dolcevida.control;

import com.dolcevida.model.Usuario;
import com.dolcevida.util.HibernateUtil;
import java.io.IOException;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.hibernate.Session;
import org.hibernate.Transaction;

// Definición de la ruta URL mediante la cual se invocará este Servicio Web
@WebServlet(name = "RegistroController", urlPatterns = {"/RegistroController"})
public class RegistroController extends HttpServlet {

    // El método doPost se encarga de recibir de forma segura las peticiones del formulario de registro
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Configuración de la codificación para soportar caracteres especiales y tildes
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // RECUPERACIÓN DE LOS PARÁMETROS ENVIADOS POR EL CLIENTE EN EL SERVICIO WEB
        String nombre = request.getParameter("nombre");
        String usuarioTxt = request.getParameter("usuario");
        String contrasena = request.getParameter("contrasena");
        String rol = request.getParameter("rol");

        Session hibernateSession = null;
        Transaction tx = null;
        
        try {
            // Se abre un canal de conexión o túnel a través de la factoría de sesiones de Hibernate
            hibernateSession = HibernateUtil.getSessionFactory().openSession();
            
            // Se inicializa una transacción controlada para asegurar la consistencia en la inserción
            tx = hibernateSession.beginTransaction();
            
            // INSTANCIACIÓN DE LA ENTIDAD MODELO USUARIO (MAPEADO CON ORM)
            Usuario nuevoUsuario = new Usuario();
            nuevoUsuario.setNombre(nombre);
            nuevoUsuario.setUsuario(usuarioTxt);
            nuevoUsuario.setContrasena(contrasena); // En un entorno real se aplicaría Hash
            nuevoUsuario.setRol(rol);
            nuevoUsuario.setFechaRegistro(new Date()); // Asignación automática de la fecha actual
            
            // FUNCIÓN DE PERSISTENCIA CRUD: Guardar físicamente el objeto mapeado en la tabla de MySQL
            hibernateSession.save(nuevoUsuario);
            
            // Se confirma la transacción de manera definitiva en el servidor de base de datos
            tx.commit();
            
            // RESPUESTA DEL SERVICIO WEB: Notificación de autenticación / registro satisfactorio en pantalla
            response.getWriter().println("<script>"
                    + "alert('¡Servicio Web: Registro de usuario completado satisfactoriamente! 🎉');"
                    + "window.location.href='index.html';"
                    + "</script>");
            
        } catch (Exception e) {
            // En caso de fallas (como un usuario duplicado), se revierte la transacción para evitar corrupción de datos
            if (tx != null) tx.rollback();
            e.printStackTrace();
            
            // RESPUESTA DE ERROR DEL SERVICIO WEB
            response.getWriter().println("<script>"
                    + "alert('Error en el Servicio Web: No se pudo completar el registro. El usuario ya existe o los datos son inválidos. ❌');"
                    + "window.location.href='registro.jsp';"
                    + "</script>");
        } finally {
            // Clausura obligatoria del canal de sesión de Hibernate para liberar memoria en el servidor
            if (hibernateSession != null && hibernateSession.isOpen()) {
                hibernateSession.close();
            }
        }
    }
}
