package com.dolcevida.control;

import com.dolcevida.model.Usuario;
import com.dolcevida.util.HibernateUtil;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.hibernate.Session;

// Ruta URL asignada para invocar el Servicio Web de Autenticación
@WebServlet(name = "LoginController", urlPatterns = {"/LoginController"})
public class LoginController extends HttpServlet {

    // Procesa las solicitudes de credenciales mediante el método seguro POST
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        // Extracción de datos del servicio web enviados desde el formulario index.html
        String txtUser = request.getParameter("usuario");
        String txtPass = request.getParameter("contrasena");
        
        Session hibernateSession = null;
        try {
            // Conexión dinámica a la base de datos utilizando el motor centralizado de Hibernate
            hibernateSession = HibernateUtil.getSessionFactory().openSession();
            
            // Consulta HQL parametrizada para buscar al usuario y validar su contraseña
            Usuario userObj = (Usuario) hibernateSession.createQuery("FROM Usuario WHERE usuario = :u AND contrasena = :p")
                    .setParameter("u", txtUser)
                    .setParameter("p", txtPass)
                    .uniqueResult();
            
            // CONDICIONAL DE AUTENTICACIÓN
            if (userObj != null) {
                // Caso Correcto: Inicialización de sesión HTTP e impresión de mensaje de éxito satisfactorio
                HttpSession session = request.getSession();
                session.setAttribute("usuarioLogueado", userObj.getUsuario());
                
                response.getWriter().println("<script>"
                        + "alert('¡Mensaje de autenticación satisfactoria! ✨ Accediendo al sistema...');"
                        + "window.location.href='principal.jsp';"
                        + "</script>");
            } else {
                // Caso Incorrecto: Retorno explícito del mensaje de error en la autenticación
                response.getWriter().println("<script>"
                        + "alert('Error en la autenticación: Usuario o contraseña incorrectos. ❌');"
                        + "window.location.href='index.html';"
                        + "</script>");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error crítico en el servicio de login: " + e.getMessage());
        } finally {
            // Cierre preventivo del túnel de persistencia
            if (hibernateSession != null && hibernateSession.isOpen()) {
                hibernateSession.close();
            }
        }
    }
}
